import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class SettingsService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final BuildContext context;

  SettingsService(this.context);

  Future<Map<String, dynamic>> getUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data() ?? {};
  }

  // Método para verificar si existe un family_id
  Future<bool> checkFamilyIdExists(String id) async {
    try {
      // Primero obtenemos todos los documentos de la colección
      final querySnapshot = await _firestore
          .collection('familiar_circle_routines')
          .get();
      
      // Iteramos sobre cada documento para buscar el family_id
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['family_id'] == id) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error al verificar family_id: $e');
      return false;
    }
  }

  Future<String?> updateUserProfile({String? name, int? age, String? password, String? familyId}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return S.of(context).userNotAuthenticated;
    try {
      Map<String, dynamic> dataToUpdate = {};
      if (name != null) {
        await _auth.currentUser?.updateDisplayName(name);
        dataToUpdate['name'] = name;
      }
      if (age != null) {
        dataToUpdate['age'] = age;
      }
      if (familyId != null) {
        // Verificar si el family_id existe antes de actualizarlo
        if (await checkFamilyIdExists(familyId)) {
          dataToUpdate['family_id'] = familyId;
        } else {
          return 'El ID de familia no existe';
        }
      }
      if (dataToUpdate.isNotEmpty) {
        // Asegura que el email nunca se borre del documento
        final user = _auth.currentUser;
        if (user != null && !dataToUpdate.containsKey('email')) {
          dataToUpdate['email'] = user.email;
        }
        await _firestore.collection('users').doc(uid).set(dataToUpdate, SetOptions(merge: true));
      }
      if (password != null && password.isNotEmpty) {
        await _auth.currentUser?.updatePassword(password);
      }
      return null;
    } catch (e) {
      return '${S.of(context).profileUpdateError}${e.toString()}';
    }
  }
}
