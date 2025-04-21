import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if email exists in Firebase Auth from an [email] field
  Future<List<String>> checkEmailExists(String email) async {
    List<String> providers = [];
    try {
      providers = await _auth.fetchSignInMethodsForEmail(email);
    } catch (e) {
      print('Error checking email: $e');
    }
    return providers;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in with email and password: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailPassword(
      String email,
      String password,
      String name,
      int age
      ) async {
    try {
      // Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with name
      await userCredential.user?.updateDisplayName(name);

      // Store additional user data in Firestore
      // This would typically be done in a separate user service
      // await _firestoreService.createUserProfile(
      //   userCredential.user!.uid,
      //   {
      //     'name': name,
      //     'email': email,
      //     'age': age,
      //     'createdAt': DateTime.now(),
      //   },
      // );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      return userCredential;
    } catch (e) {
      print('Error registering with email and password: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign in with Apple
  Future<UserCredential> signInWithApple() async {
    try {
      // Request credentials
      final AuthorizationCredentialAppleID appleCredential =
      await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuthCredential
      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Update user profile if name is available and user is new
      if (appleCredential.givenName != null &&
          appleCredential.familyName != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        await userCredential.user?.updateDisplayName(
            '${appleCredential.givenName} ${appleCredential.familyName}'
        );
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Apple: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
