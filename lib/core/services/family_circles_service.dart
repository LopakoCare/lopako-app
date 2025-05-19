// core/services/family_circles_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_manager.dart';
import 'auth_service.dart';

class FamilyCirclesService extends BaseService {
  final _db = FirebaseFirestore.instance;
  final _rand = Random();

  // Hardcoded JSON
  final initialQuestionnaire = [
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

  /* ───── CREATE ───── */
  Future<String> create(String patientName, Map<String, dynamic> questionary) async {
    final auth = serviceManager.getService<AuthService>('auth');
    final uid = auth.currentUser!.uid;

    final pin = await _generateUniquePin();

    final doc = await _db.collection('family_circles').add({
      'patientName': patientName,
      'createdBy': uid,
      'members': [uid],
      'pin': pin,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id; // id del círculo
  }

  /* ───── JOIN ───── */
  Future<void> join(String pin) async {
    final auth = serviceManager.getService<AuthService>('auth');
    final uid = auth.currentUser!.uid;

    final q = await _db
        .collection('family_circles')
        .where('pin', isEqualTo: pin)
        .limit(1)
        .get();

    if (q.docs.isEmpty) throw Exception('PIN no encontrado');

    await q.docs.first.reference.update({
      'members': FieldValue.arrayUnion([uid]),
    });
  }

  /* ───── getFamilyCircle ───── */
  Future<Map<String, dynamic>?> getFamilyCircle(String id) async {
    final doc = await _db.collection('family_circles').doc(id).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  /* ───── helper para PIN único ───── */
  Future<String> _generateUniquePin() async {
    String pin;
    bool exists;
    do {
      pin = (_rand.nextInt(900000) + 100000).toString(); // 100000-999999
      exists = (await _db
          .collection('family_circles')
          .where('pin', isEqualTo: pin)
          .limit(1)
          .get())
          .docs
          .isNotEmpty;
    } while (exists);
    return pin;
  }
}
