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
