import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Función que obiene el family_id del usuario a partir del correo con el que ha iniciado sesión
Future<String?> obtenerFamilyIdActual() async {
  final email = FirebaseAuth.instance.currentUser?.email;
  if (email == null) return null;

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.first.data()['family_id'];
  }
  return null;
}
