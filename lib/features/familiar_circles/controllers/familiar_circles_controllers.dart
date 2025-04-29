import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamiliarRoutinesController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Devuelve el family_id del usuario actualmente autenticado
  Future<String?> obtenerFamilyIdActual() async {
    try {
      final email = _auth.currentUser?.email;
      if (email == null) return null;

      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return data['family_id']?.toString();
      }
      return null;
    } catch (e) {
      print('Error obteniendo family_id: $e');
      return null;
    }
  }

  // Carga las rutinas asociadas al family_id del usuario autenticado
  Future<List<Map<String, dynamic>>> cargarRutinasAsignadas() async {
    try {
      final familyId = await obtenerFamilyIdActual();
      if (familyId == null) return [];

      final querySnapshot = await _firestore
          .collection('familiar_circle_routines')
          .where('family_id', isEqualTo: familyId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      final referencias = data['associated_routines'] as List<dynamic>? ?? [];

      List<Map<String, dynamic>> rutinas = [];

      for (final ref in referencias) {
        if (ref is DocumentReference) {
          try {
            final doc = await ref.get();
            final data = doc.data() as Map<String, dynamic>?;
            if (data != null) {
              data['__ref__'] = ref;
              rutinas.add(data);
            }
          } catch (e) {
            print('Error cargando rutina individual: $e');
            continue;
          }
        }
      }

      return rutinas;
    } catch (e) {
      print('Error cargando rutinas asignadas: $e');
      return [];
    }
  }
}
