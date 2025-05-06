import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FamiliarCircleController {
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

  Future<void> createFamilyCircle({
    required String patientName,
    required String bond, // 'cuidador' o 'familiar'
    required String userName,
    required int userAge,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final email = user.email!;
    final familyId = await _generateUniqueFamilyId();

    final userRef = _firestore.collection('users').doc(user.uid);

    // Guardar en colección users
    await userRef.set({
      'email': email,
      'name': userName,
      'age': userAge,
      'family_id': familyId,
      'bond': bond,
    });

    // Crear documento en familiar_circle_routines con referencia al usuario
    await _firestore.collection('familiar_circle_routines').add({
      'family_id': familyId, // lo sigues guardando como campo dentro del documento
      'patientName': patientName,
      'associated_routines': [],
      'associated_users': [userRef],
    });

  }

  /// Se une a un círculo familiar existente usando el `familyId`
  Future<void> joinFamilyCircle({
    required String familyId,
    required String bond,
    required String userName,
    required int userAge,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final userRef = _firestore.collection('users').doc(user.uid);
    final email = user.email!;

    //Buscar el documento del círculo familiar por campo family_id
    final query = await _firestore
        .collection('familiar_circle_routines')
        .where('family_id', isEqualTo: familyId)
        .limit(1)
        .get();

    final circleDoc = query.docs.first;

    //Guardar los datos del usuario en la colección users
    await userRef.set({
      'email': email,
      'name': userName,
      'age': userAge,
      'family_id': familyId,
      'bond': bond,
    });

    //Añadir la referencia del usuario al array associated_users del documento del círculo
    await _firestore
        .collection('familiar_circle_routines')
        .doc(circleDoc.id)
        .update({
      'associated_users': FieldValue.arrayUnion([userRef]),
    });
  }


  // Genera un código de 6 dígitos único
  Future<String> _generateUniqueFamilyId() async {
    final rand = Random();
    String code;
    bool exists = true;

    do {
      code = (100000 + rand.nextInt(900000)).toString(); // 6 dígitos

      final query = await _firestore
          .collection('familiar_circle_routines')
          .where('family_id', isEqualTo: code)
          .limit(1)
          .get();

      exists = query.docs.isNotEmpty;
    } while (exists);

    return code;
  }
}
