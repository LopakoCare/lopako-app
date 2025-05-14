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
      'options': [
        {
          'id': 'family',
          'icon': 'heart',
          'label': 'Familiar',
          'description': 'Pertenece a tu familia, ya sea de forma cercana como indirecta.',
        },
        {
          'id': 'caregiver',
          'icon': 'girl',
          'label': 'Cuidador/a',
          'description': 'Eres voluntario o te encargas del cuidado del paciente para su bienestar.'
        }
      ]
    }
  ];

  /* ───── CREATE ───── */
  Future<String> create(String patientName) async {
    final auth = serviceManager.getService<AuthService>('auth');
    final uid = auth.currentUser!.uid;

    final pin = await _generateUniquePin();

    final doc = await _db.collection('familyCircles').add({
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
        .collection('familyCircles')
        .where('pin', isEqualTo: pin)
        .limit(1)
        .get();

    if (q.docs.isEmpty) throw Exception('PIN no encontrado');

    await q.docs.first.reference.update({
      'members': FieldValue.arrayUnion([uid]),
    });
  }

  /* ───── helper para PIN único ───── */
  Future<String> _generateUniquePin() async {
    String pin;
    bool exists;
    do {
      pin = (_rand.nextInt(900000) + 100000).toString(); // 100000-999999
      exists = (await _db
          .collection('familyCircles')
          .where('pin', isEqualTo: pin)
          .limit(1)
          .get())
          .docs
          .isNotEmpty;
    } while (exists);
    return pin;
  }
}
