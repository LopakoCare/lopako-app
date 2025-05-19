import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/routines/models/routine_activity_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lopako_app_lis/features/routines/models/routine_category_model.dart';
import 'package:lopako_app_lis/features/routines/models/routine_model.dart';
import 'service_manager.dart';

class RoutinesService extends BaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Random _random = Random();

  static const _kRoutineKeyPrefix      = 'routine_';
  static const _kAllRoutinesKey        = 'routines_all';
  static const _kCategoriesKey         = 'categories_all';

  /// Get a routine by its [id]. Use [forceRefresh] to force a refresh from Firestore.
  Future<Routine?> getRoutine(String id, {bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = prefs.getString('$_kRoutineKeyPrefix$id');
      if (cached != null) {
        final jsonMap = json.decode(cached) as Map<String, dynamic>;
        return Routine.fromJson(jsonMap);
      }
    }

    final doc = await _db.collection('routines').doc(id).get();
    if (!doc.exists) return null;
    final routine = Routine.fromJson(doc.data()!);
    prefs.setString(
      '$_kRoutineKeyPrefix$id',
      json.encode(routine.toJson()),
    );
    return routine;
  }

  /// Get all the routines. Use [forceRefresh] to force a refresh from Firestore.
  Future<List<Routine>> getAllRoutines({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    final categories = await getCategories();
    final categoryCache = {
      for (var c in categories) c.id: c
    };

    if (!forceRefresh) {
      final cached = prefs.getString(_kAllRoutinesKey);
      if (cached != null) {
        final list = json.decode(cached) as List<dynamic>;
        return list.map((e) {
          final map = e as Map<String, dynamic>;

          // Activities
          final activitiesJson = map['activities'] as List<dynamic>;
          final activities = activitiesJson
              .map((a) => RoutineActivity.fromJson(a as Map<String, dynamic>))
              .toList();

          // Category
          final catMap = map['category'] as Map<String, dynamic>;
          final catId = catMap['id'] as String;
          final catScore = (catMap['score'] as num).toInt();
          final baseCat = categoryCache[catId];
          final category = baseCat != null
              ? baseCat.copyWith(score: catScore)
              : RoutineCategory(
            catId,
            label: catMap['label'] as String,
            color: catMap['color'] as String,
            score: catScore,
          );

          // Subcategories
          final subMap = map['subcategories'] as Map<String, dynamic>;
          final subcategories = subMap.entries.map((e) {
            final subId    = e.key;
            final subScore = (e.value as num).toInt();
            final base     = categoryCache[subId];
            return base != null
                ? base.copyWith(score: subScore)
                : RoutineCategory(subId, score: subScore);
          }).toList();

          return Routine(
            map['id'] as String,
            activities: activities,
            category: category,
            subcategories: subcategories,
            duration: map['duration'] as String,
            icon: map['icon'] as String,
            description: map['information'] as String,
            schedule: map['schedule'] as String,
            title: map['title'] as String,
          );
        }).toList();
      }
    }

    // 3) Si llega aquí, forzamos fetch desde Firestore
    final routinesSnap   = await _db.collection('routines').get();
    final activitiesSnap = await _db.collection('activities').get();
    final categoriesSnap = await _db.collection('routine_categories').get();

    // Mapas auxiliares
    final activityMap = {
      for (var a in activitiesSnap.docs)
        a.id: RoutineActivity.fromJson({
          'id': a.id,
          ...a.data(),
        })
    };
    final categoryMap = {
      for (var c in categoriesSnap.docs)
        c.id: RoutineCategory(
          c.id,
          label: c.data()['label']  as String,
          color: c.data()['color']  as String,
        )
    };

    // 4) Construyo lista de rutinas “a mano”
    final routines = routinesSnap.docs.map((rDoc) {
      final data = rDoc.data();

      // activities
      final activityIds = (data['activities'] as List<dynamic>? ?? [])
          .map((e) => e is DocumentReference ? e.id : e as String)
          .toList();
      final activities = activityIds
          .map((id) => activityMap[id])
          .whereType<RoutineActivity>()
          .toList();

      // categoría principal
      final catEntry = (data['category'] as Map<String, dynamic>).entries.first;
      final baseCat = categoryMap[catEntry.key];
      final category = baseCat != null
          ? baseCat.copyWith(score: (catEntry.value as num).toInt())
          : RoutineCategory(catEntry.key, score: (catEntry.value as num).toInt());

      // subcategorías
      final subMap = data['subcategories'] as Map<String, dynamic>? ?? {};
      final subcategories = subMap.entries.map((e) {
        final base = categoryMap[e.key];
        final score = (e.value as num).toInt();
        return base != null
            ? base.copyWith(score: score)
            : RoutineCategory(e.key, score: score);
      }).toList();

      return Routine(
        rDoc.id,
        activities:    activities,
        category:      category,
        subcategories: subcategories,
        duration:      data['duration']    as String,
        icon:          data['icon']        as String,
        description:   data['information'] as String,
        schedule:      data['schedule']    as String,
        title:         data['title']       as String,
      );
    }).toList();

    // 5) Cacheo para la próxima
    await prefs.setString(
      _kAllRoutinesKey,
      json.encode(routines.map((r) => r.toJson()).toList()),
    );

    return routines;
  }

  /// Get all routine categories. Use [forceRefresh] to force a refresh from Firestore.
  Future<List<RoutineCategory>> getCategories({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      final cached = prefs.getString(_kCategoriesKey);
      if (cached != null) {
        final list = json.decode(cached) as List;
        return list.map((e) {
          final m = e as Map<String, dynamic>;
          return RoutineCategory(
            m['id'] as String,
            label: m['label'] as String,
            color: m['color'] as String,
          );
        }).toList();
      }
    }

    // Firestore
    final query = await _db.collection('routine_categories').get();
    final categories = query.docs.map((doc) {
      return RoutineCategory(
        doc.id,
        label: doc.data()['label'] as String,
        color: doc.data()['color'] as String,
      );
    }).toList();

    // Cache
    prefs.setString(
      _kCategoriesKey,
      json.encode(categories.map((c) => c.toJson()).toList()),
    );

    return categories;
  }

  /// List of recommended routines for the user. Use [limit] to limit the number of routines returned.
  /// TODO: Implement this method without a random selection.
  Future<List<Routine>> getRecommendedRoutines({int? limit, bool forceRefresh = false}) async {
    final routines = await getAllRoutines(forceRefresh: forceRefresh);

    routines.shuffle(_random);  // <-- Replace this

    if (limit != null && limit < routines.length) {
      return routines.sublist(0, limit);
    }
    return routines;
  }

  /// List of a filtered routines by a [search] query and a list of [categories].
  Future<List<Routine>> getFilteredRoutines({String? search, List<RoutineCategory>? categories, int? limit, bool forceRefresh = false,}) async {
    final routines = await getAllRoutines(forceRefresh: forceRefresh);
    if (search != null && search.isNotEmpty) {
      routines.retainWhere((r) => r.title.toLowerCase().contains(search.toLowerCase()));
    }
    List<String> selectedIds = [];
    if (categories != null && categories.isNotEmpty) {
      selectedIds = categories.map((c) => c.id).toList();
      routines.retainWhere((r) => selectedIds.contains(r.category.id) ||
          r.subcategories.any((sc) => selectedIds.contains(sc.id)));
    }
    if (selectedIds.isNotEmpty) {
      routines.sort((a, b) {
        final aCat = selectedIds.indexOf(a.category.id);
        final bCat = selectedIds.indexOf(b.category.id);
        if (aCat != bCat) {
          return bCat - aCat;
        }
        final aNCats = a.subcategories.where((sc) => selectedIds.contains(sc.id)).length;
        final bNCats = b.subcategories.where((sc) => selectedIds.contains(sc.id)).length;
        if (aNCats != bNCats) {
          return bNCats - aNCats;
        }
        final aScore = a.subcategories.map((sc) => selectedIds.indexOf(sc.id)).reduce(min);
        final bScore = b.subcategories.map((sc) => selectedIds.indexOf(sc.id)).reduce(min);
        return aScore - bScore;
      });
    }
    if (limit != null && limit < routines.length) {
      return routines.sublist(0, limit);
    }
    return routines;
  }

  /// Forzar actualización manual de todas las colecciones
  Future<void> refreshAllData() async {
    await getAllRoutines(forceRefresh: true);
    await getCategories(forceRefresh: true);
  }
}
