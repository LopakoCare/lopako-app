import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamiliarRoutinesController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Devuelve el family_id del usuario actualmente autenticado
  Future<String?> obtenerFamilyIdActual() async {
    final email = _auth.currentUser?.email;
    if (email == null) return null;

    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['family_id'];
    }
    return null;
  }

// Carga las rutinas asociadas al family_id del usuario autenticado
  Future<List<Map<String, dynamic>>> cargarRutinasAsignadas() async {
    final familyId = await obtenerFamilyIdActual();
    if (familyId == null) return [];

    final querySnapshot = await _firestore
        .collection('familiar_circle_routines')
        .where('family_id', isEqualTo: familyId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return [];

    final doc = querySnapshot.docs.first;
    final referencias = doc['associated_routines'] as List<dynamic>? ?? [];

    List<Map<String, dynamic>> rutinas = [];

    for (final ref in referencias) {
      if (ref is DocumentReference) {
        final doc = await ref.get();
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          data['__ref__'] = ref; //Añade la referencia como campo especial
          rutinas.add(data);
        }
      }
    }

    return rutinas;
  }

}
