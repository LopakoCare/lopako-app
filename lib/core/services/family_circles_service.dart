import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lopako_app_lis/core/services/routines_service.dart';
import 'package:lopako_app_lis/core/services/user_service.dart';
import 'package:lopako_app_lis/features/routines/models/routine_model.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'service_manager.dart';
import 'auth_service.dart';


class FamilyCirclesService extends BaseService {
  static const _kPrefCurrentCircleId = 'current_circle_id';

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Random _rand = Random();

  final maxRoutines = 3;

  FamilyCircle? _current;
  FamilyCircle? get currentFamilyCircle => _current;

  final questionnaire = [
    {
      'id': 'relation',
      'type': 'user',
      'description': '¿Cuál es tu vínculo con la persona?',
      'required': true,
      'options': [
        {
          'value': 'family',
          'icon': 'heart',
          'label': 'Familiar',
          'description': 'Pertenece a tu familia, de forma cercana o indirecta',
        },
        {
          'value': 'caregiver',
          'icon': 'girl',
          'label': 'Cuidador/a',
          'description': 'Soy quien le cuida principalmente'
        },
        {
          'value': 'companion',
          'icon': 'chat-bubbles',
          'label': 'Acompañante o voluntario',
          'description': 'Le acompaño de forma puntual o compartida'
        },
      ]
    },
    {
      'id': 'age',
      'type': 'patient',
      'description': '¿Qué edad tiene el paciente?',
      'required': false,
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
    },
    {
      'id': 'concerns',
      'type': 'user',
      'multiple': true,
      'required': false,
      'description': '¿Qué te preocupa?',
      'options': [
        {
          'value': 'cognitive-decline',
          'icon': 'puzzle',
          'label': 'Su mente está cambiando'
        },
        {
          'value': 'emotional-distance',
          'icon': 'chat-bubbles',
          'label': 'Estamos perdiendo la conexión'
        },
        {
          'value': 'overload',
          'icon': 'heart',
          'label': 'Todo recae en mí'
        },
        {
          'value': 'emotional-management',
          'icon': 'fire',
          'label': 'Me cuesta gestionar emociones'
        },
        {
          'value': 'loneliness',
          'icon': 'explorer',
          'label': 'Me siento solo/a'
        },
        {
          'value': 'loss-of-joy',
          'icon': 'notify-heart',
          'label': 'Ya no disfrutamos juntos'
        }
      ]
    },
    {
      'id': 'dependency-level',
      'type': 'user',
      'required': false,
      'description': '¿Cuánto apoyo necesita la persona que cuidas?',
      'options': [
        {
          'value': 'autonomous',
          'label': 'Bastante autónomo/a',
          'description': 'Hace cosas solo/a, pero olvida detalles'
        },
        {
          'value': 'partial-support',
          'label': 'Ayuda en algunas tareas',
          'description': 'Se desorienta o necesita guía'
        },
        {
          'value': 'high-dependency',
          'label': 'Depende mucho de mí',
          'description': 'Olvida rutinas y se frustra solo/a'
        }
      ]
    }
];

  FamilyCirclesService() {
    _loadPersistedCurrentCircle();
  }

  Future<void> _loadPersistedCurrentCircle() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kPrefCurrentCircleId);
    if (id != null) {
      try {
        _current = await _loadCircleFromFirestore(id);
      } catch (_) {
        await prefs.remove(_kPrefCurrentCircleId);
        _current = null;
      }
    }
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
    _current = updatedCircle;
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
    return Future.wait(
        query.docs.map((doc) =>
            _loadCircleFromFirestore(doc.id)
        )
    );
  }

  /// Cambia el círculo actual (desde Ajustes)
  Future<FamilyCircle> switchFamilyCircle(FamilyCircle familyCircle) async {
    final circle = await getFamilyCircle(familyCircle.id);
    if (circle == null) throw Exception('Círculo no existe');
    _current = circle;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefCurrentCircleId, circle.id);
    return circle;
  }

  /// Obtener círculo actual
  Future<FamilyCircle?> getCurrentFamilyCircle({bool forceRefresh = false}) async {
    if (_current == null && forceRefresh) {
      await _loadPersistedCurrentCircle();
    }
    return _current;
  }

  /// Añade una rutina al círculo actual (usa getCurrentCircle(forceRefresh: true))
  Future<FamilyCircle> addRoutine(Routine routine, {DateTime? startsAt}) async {
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
    routine = routine.copyWith(startsAt: startsAt);
    circle.routines.add(routine);
    return circle;
  }

  /// Inicia una rutina en el círculo actual (usa getCurrentCircle(forceRefresh: true))
  Future<FamilyCircle> startRoutine(Routine routine) async {
    FamilyCircle? circle = await getCurrentFamilyCircle(forceRefresh: true);
    if (circle == null) throw Exception('Círculo familiar no encontrado');
    if (circle.currentRoutine != null) {
      throw Exception('Ya hay una rutina activa');
    }
    if (!circle.routines.any((r) => r.id == routine.id)) {
      circle = await addRoutine(routine);
    }
    await _db.collection('family_circles').doc(circle.id).update({
      'currentRoutine': routine.id,
    });
    circle.currentRoutine = routine;
    return circle;
  }

  /// Termina la rutina activa en el círculo actual (usa getCurrentCircle(forceRefresh: true))
  Future<FamilyCircle> finishRoutine(FamilyCircle familyCircle) async {
    final circle = await getFamilyCircle(familyCircle.id);
    if (circle == null) throw Exception('Círculo familiar no encontrado');
    if (circle.currentRoutine == null) {
      throw Exception('No hay ninguna rutina activa');
    }
    final routine = circle.currentRoutine!;
    final routines = circle.routines
        .where((r) => r.id != routine.id)
        .map((r) =>
    {
      'routineId': r.id,
      'startsAt': r.startsAt?.millisecondsSinceEpoch,
    });
    await _db.collection('family_circles').doc(circle.id).update({
      'currentRoutine': null,
      'routines': routines,
    });
    circle.currentRoutine = null;
    circle.routines.removeWhere((r) => r.id == routine.id);
    return circle;
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
    _current = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefCurrentCircleId);
  }
}
