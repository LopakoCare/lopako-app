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

  Future<String?> updateUserProfile({String? name, int? age, String? password}) async {
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

  Future<List<String>> getUserRoutines() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null || data['routines'] == null) return [];
    return List<String>.from(data['routines']);
  }

  Future<String?> updateUserRoutines(List<String> routines) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return S.of(context).userNotAuthenticated;
    try {
      await _firestore.collection('users').doc(uid).update({'routines': routines});
      return null;
    } catch (e) {
      return '${S.of(context).routinesUpdateError}${e.toString()}';
    }
  }
}
