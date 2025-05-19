import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/core/services/routines_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lopako_app_lis/core/services/user_service.dart';
import 'package:lopako_app_lis/features/routines/models/routine_model.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';

import 'service_manager.dart';
import 'auth_service.dart';

const _kCacheKey = 'current_family_circle';

class FamilyCirclesService extends BaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Random _rand = Random();

  final maxRoutines = 3;

  FamilyCircle? _current;
  FamilyCircle? get currentFamilyCircle => _current;

  final initialQuestionnaire = [
    {
      'id': 'relation',
      'type': 'user',
      'description': '¿Cuál es tu relación con el paciente?',
      'required': true,
      'options': [
        {
          'value': 'family',
          'icon': 'heart',
          'label': 'Familiar',
          'description': 'Pertenece a tu familia, ya sea de forma cercana como indirecta.',
        },
        {
          'value': 'caregiver',
          'icon': 'girl',
          'label': 'Cuidador/a',
          'description': 'Eres voluntario o te encargas del cuidado del paciente para su bienestar.'
        }
      ]
    },
    {
      'id': 'age',
      'type': 'patient',
      'description': '¿Qué edad tiene el paciente?',
      'required': true,
      'options': [
        {
          'value': '<40',
          'label': 'Menos de 40 años',
        },
        {
          'value': '41-60',
          'label': 'Entre 41 y 60 años',
        },
        {
          'value': '61-80',
          'label': 'Entre 61 y 80 años',
        },
        {
          'value': '>80',
          'label': 'Más de 80 años',
        }
      ]
    },
    {
      'id': 'availability',
      'type': 'user',
      'description': '¿Qué disponibilidad tienes para ayudar?',
      'required': true,
      'options': [
        {
          'value': 'daily',
          'label': 'Todos los días',
        },
        {
          'value': 'weekly',
          'label': '2-3 veces a la semana',
        },
        {
          'value': 'monthly',
          'label': 'Alguna vez al mes',
        },
        {
          'value': 'occasionally',
          'label': 'Ocasionalmente',
        }
      ]
    }
  ];

  FamilyCirclesService() {
    _initCache();
  }

  /// Inicializa caché desde SharedPreferences
  Future<void> _initCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_kCacheKey);
    if (jsonString == null) return;

    try {
      _current = FamilyCircle.fromJson(json.decode(jsonString));
    } catch (_) {
      await prefs.remove(_kCacheKey);
    }
  }

  /// Guarda en caché local y memoria
  Future<void> _saveToCache(FamilyCircle circle) async {
    _current = circle;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCacheKey, json.encode(circle.toJson()));
  }

  /// Crea un nuevo FamilyCircle y lo cachea
  Future<FamilyCircle> create(String patientName, Map<String, dynamic> questionary) async {
    final auth = serviceManager.getService<AuthService>('auth');
    final uid = auth.currentUser!.uid;
    final pin = await _generateUniquePin();

    final docRef = await _db.collection('family_circles').add({
      'patientName': patientName,
      'createdBy': uid,
      'members': [uid],
      'pin': pin,
      'createdAt': FieldValue.serverTimestamp(),
      'routines': [],
      'currentRoutine': null,
    });

    final circle = await _loadCircleFromFirestore(docRef.id);
    await _saveToCache(circle);
    return circle;
  }

  /// Únete a un círculo por PIN, recarga y cachea
  Future<FamilyCircle> join(String pin) async {
    final auth = serviceManager.getService<AuthService>('auth');
    final uid = auth.currentUser!.uid;

    final query = await _db
        .collection('family_circles')
        .where('pin', isEqualTo: pin)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('PIN no encontrado');
    }

    final doc = query.docs.first;
    await doc.reference.update({
      'members': FieldValue.arrayUnion([uid]),
    });

    final circle = await _loadCircleFromFirestore(doc.id);
    await _saveToCache(circle);
    return circle;
  }

  /// Edita un FamilyCircle existente
  Future<FamilyCircle> edit(FamilyCircle familyCircle) async {
    final docRef = _db.collection('family_circles').doc(familyCircle.id);
    await docRef.update({
      'patientName': familyCircle.patientName,
      'members': familyCircle.members.map((m) => m.id).toList(),
    });
    final updatedCircle = await _loadCircleFromFirestore(familyCircle.id);
    await _saveToCache(updatedCircle);
    return updatedCircle;
  }

  /// Recupera un FamilyCircle completo desde Firestore
  Future<FamilyCircle?> getFamilyCircle(String id) async {
    final doc = await _db.collection('family_circles').doc(id).get();
    if (!doc.exists) return null;
    return await _loadCircleFromFirestore(id);
  }

  /// Recupera todos los círculos familiares del usuario
  Future<List<FamilyCircle>> getUserFamilyCircles(String uid) async {
    final query = await _db
        .collection('family_circles')
        .where('members', arrayContains: uid)
        .get();
    return Future.wait(query.docs.map((doc) => _loadCircleFromFirestore(doc.id)));
  }

  /// Cambia el círculo actual (desde Ajustes)
  Future<void> switchFamilyCircle(FamilyCircle familyCircle) async {
    final circle = await getFamilyCircle(familyCircle.id);
    if (circle == null) throw Exception('Círculo no existe');
    await _saveToCache(circle);
  }

  /// Obtener círculo actual (cache o forzando refresh)
  Future<FamilyCircle?> getCurrentFamilyCircle({bool forceRefresh = false}) async {
    if (!forceRefresh && _current != null) {
      return _current;
    }
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_kCacheKey);
    if (jsonString == null) {
      return null;
    }
    final cached = FamilyCircle.fromJson(json.decode(jsonString));
    if (!forceRefresh) {
      _current = cached;
      return _current;
    }
    return await getFamilyCircle(cached.id);
  }

  /// Añade una rutina al círculo actual (usa getCurrentCircle(forceRefresh: true))
  Future<void> addRoutine(Routine routine, DateTime? startsAt) async {
    final circle = await getCurrentFamilyCircle(forceRefresh: true);
    if (circle == null) throw Exception('Círculo familiar no encontrado');
    if (circle.routines.any((r) => r.id == routine.id)) {
      throw Exception('La rutina ya está en la lista');
    }
    if (circle.routines.length >= maxRoutines) {
      throw Exception('Máximo de ${maxRoutines} rutinas alcanzado');
    }
    startsAt ??= DateTime.now();
    final data = {
      'routineId': routine.id,
      'startsAt': startsAt.millisecondsSinceEpoch,
    };
    await _db.collection('family_circles').doc(circle.id).update({
      'routines': FieldValue.arrayUnion([data]),
    });
    final updatedCircle = await getFamilyCircle(circle.id);
    if (updatedCircle == null) {
      throw Exception('Error al actualizar el círculo familiar');
    }
    await _saveToCache(updatedCircle);
  }

  /// Inicia una rutina en el círculo actual (usa getCurrentCircle(forceRefresh: true))
  Future<void> startRoutine(Routine routine) async {
    final circle = await getCurrentFamilyCircle(forceRefresh: true);
    if (circle == null) throw Exception('Círculo familiar no encontrado');
    if (circle.routines.isEmpty) {
      throw Exception('No hay rutinas programadas');
    }
    if (circle.currentRoutine != null) {
      throw Exception('Ya hay una rutina en curso');
    }
    final otherRoutines = circle.routines.where((r) => r.id != routine.id).toList();
    final routines = otherRoutines.map((r) {
      return {
        'routineId': r.id,
        'startsAt': r.startsAt,
      };
    }).toList();
    await _db.collection('family_circles').doc(circle.id).update({
      'currentRoutine': routine.id,
      'routines': routines,
    });
    final updatedCircle = await getFamilyCircle(circle.id);
    if (updatedCircle == null) {
      throw Exception('Error al actualizar el círculo familiar');
    }
    await _saveToCache(updatedCircle);
  }

  /* ───── Helpers ───── */

  /// Crea un PIN único de 6 dígitos
  Future<String> _generateUniquePin() async {
    String pin;
    bool exists;
    do {
      pin = (_rand.nextInt(900000) + 100000).toString();
      final q = await _db
          .collection('family_circles')
          .where('pin', isEqualTo: pin)
          .limit(1)
          .get();
      exists = q.docs.isNotEmpty;
    } while (exists);
    return pin;
  }

  /// Carga y construye un FamilyCircle a partir de Firestore + UserService
  Future<FamilyCircle> _loadCircleFromFirestore(String id) async {
    final doc = await _db.collection('family_circles').doc(id).get();
    final data = doc.data()!;
    final userService = serviceManager.getService<UserService>('user');
    final routinesService = serviceManager.getService<RoutinesService>('routines');

    // CreatedBy
    final createdByUid = data['createdBy'] as String;
    final createdBy = (await userService.get(uid: createdByUid))!;

    // Members
    final rawMembers = data['members'];
    final memberUids = (rawMembers is List)
        ? rawMembers.cast<String>()
        : <String>[];
    final members = await Future.wait(memberUids.map((mUid) async {
      return (await userService.get(uid: mUid))!;
    }));

    FamilyCircle familyCircle = FamilyCircle(
      id,
      patientName: data['patientName'] as String,
      createdBy: createdBy,
      members: members,
      pin: data['pin'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      routines: [],
      currentRoutine: null,
    );

    // Routines
    final routinesData = data['routines'] as List<dynamic>? ?? [];
    final routines = await Future.wait(routinesData.map((routineData) async {
      final routineId = routineData['routineId'] as String;
      final startsAt = DateTime.fromMillisecondsSinceEpoch(routineData['startsAt'] as int);
      final routine = await routinesService.getRoutine(routineId);
      return routine?.copyWith(startsAt: startsAt);
    }));
    familyCircle.routines = routines.whereType<Routine>().toList();

    // CurrentRoutine
    final currentRoutineId = data['currentRoutine'] as String?;
    if (currentRoutineId != null) {
      final currentRoutine = await routinesService.getRoutine(currentRoutineId);
      familyCircle.currentRoutine = currentRoutine;
    }

    return familyCircle;
  }

  /// Limpia el caché local
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCacheKey);
    _current = null;
  }
}
