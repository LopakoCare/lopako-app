import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lopako_app_lis/core/services/family_circles_service.dart';
import 'package:lopako_app_lis/core/services/routines_service.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';

import 'service_manager.dart';
import 'user_service.dart';

class AuthService extends BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  /* ──────────── SIGN UP ──────────── */
  Future<UserCredential> signup({
    required String email,
    required String password,
    required String name,
    required int age,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await cred.user!.updateDisplayName(name);
    await cred.user!.sendEmailVerification();

    // Crea el documento en “users”
    final userSvc = serviceManager.getService<UserService>('user');
    await userSvc.create(
      uid: cred.user!.uid,
      email: email,
      name: name,
      age: age,
    );

    return cred;
  }

  /* ──────────── LOGIN ──────────── */
  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);

    // Recuperamos y cacheamos los datos del usuario si quieres
    final userSvc = serviceManager.getService<UserService>('user');
    await userSvc.get(uid: cred.user!.uid);

    final familyCircles = await userSvc.getFamilyCircles(cred.user!.uid);
    if (familyCircles.isNotEmpty) {
      final familyCircleSvc = serviceManager.getService<FamilyCirclesService>('familyCircles');
      final familyCircle = familyCircleSvc.getFamilyCircle(familyCircles.first);
      await familyCircleSvc.switchFamilyCircle(familyCircle as FamilyCircle);
    }

    return cred.user;
  }

  /* ────── GOOGLE SSO (alta o login) ────── */
  Future<User?> signinWithGoogle() async {
    final gUser = await _google.signIn();
    if (gUser == null) return null;
    final gAuth = await gUser.authentication;
    final cred = await _auth.signInWithCredential(
      GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      ),
    );
    final isNew = cred.additionalUserInfo?.isNewUser ?? false;
    if (isNew) {
      final displayName = gUser.displayName ?? gUser.email.split('@').first;
      int? age;
      await serviceManager.getService<UserService>('user')
          .create(uid: cred.user!.uid, email: gUser.email, name: displayName, age: age);
    }
    return cred.user;
  }

  /* ──────────── LOGOUT ──────────── */
  Future<void> logout() async {
    await _google.signOut();
    await _auth.signOut();
    final familyCirclesSvc = serviceManager.getService<FamilyCirclesService>('familyCircles');
    final routinesSvc = serviceManager.getService<RoutinesService>('routines');
    await familyCirclesSvc.clearCache();
    await routinesSvc.clearCache();
  }

  /* ──────────── PROVEEDOR ──────────── */
  Future<List<String>> getProviders(String email) async {
    List<String> providers = [];
    try {
      providers = await _auth.fetchSignInMethodsForEmail(email);
    } catch (e) {
      print('Error checking email: $e');
    }
    return providers;
  }

  /* ──────────── VERIFICAR CUENTA LOGGEADA ──────────── */
  bool isLogged() {
    return _auth.currentUser != null;
  }
}
