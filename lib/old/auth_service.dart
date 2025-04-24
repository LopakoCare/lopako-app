import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método de registro de usuario
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': 'Default Name',
          'age': 18,
        });
      }

      return user;
    } catch (e) {
      print('Error en el registro: $e');
      throw e;
    }
  }

  // Método de inicio de sesión
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } catch (e) {
      print('Error en el inicio de sesión: $e');
      throw e;
    }
  }

  // Método de inicio de sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web implementation
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        
        try {
          final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
          final user = userCredential.user;
          
          if (user != null && userCredential.additionalUserInfo?.isNewUser == true) {
            await _firestore.collection('users').doc(user.uid).set({
              'email': user.email,
              'name': user.displayName ?? 'Default Name',
              'age': 18,
            });
          }
          return user;
        } catch (e) {
          print('Error during web sign in: $e');
          // Fallback to redirect if popup is blocked
          await _auth.signInWithRedirect(googleProvider);
          // Get redirect result
          final userCred = await _auth.getRedirectResult();
          return userCred.user;
        }
      } else {
        // Mobile implementation
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final user = userCredential.user;

        // Save user data to Firestore if it's a new user
        if (user != null && userCredential.additionalUserInfo?.isNewUser == true) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName ?? 'Default Name',
            'age': 18,
          });
        }

        return user;
      }
    } catch (e) {
      print('Error en el inicio de sesión con Google: $e');
      throw e;
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Método para guardar datos del usuario
  Future<void> saveUserData(User user, String name, int age) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': name,
        'age': age,
      });
    } catch (e) {
      print("Error guardando los datos del usuario en Firestore: $e");
      throw e;
    }
  }

  Future<bool> checkIfEmailInFirestore(String email) async {
    try {
      // Realizamos una consulta en Firestore para buscar el correo
      var snapshot = await _firestore.collection('users')
          .where('email', isEqualTo: email) // Comparamos con el campo 'email'
          .get();

      // Si el tamaño del snapshot es mayor que 0, significa que el correo está en la colección
      return snapshot.docs.isNotEmpty; // Si existe al menos un documento con el correo, devolvemos true
    } catch (e) {
      print("Error al verificar el correo en Firestore: $e");
      return false; // Si ocurre un error, devolvemos false
    }
  }

  // Verificar si el correo está registrado en Firebase Authentication
  Future<bool> verifyEmailInFirebase(String email) async {
    try {
      // Intentamos realizar una consulta a Firebase Authentication para ver si el correo está registrado
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isEmpty) {
        return false; // El correo no está registrado en Firebase Authentication
      }
      return true; // El correo está registrado
    } catch (e) {
      print("Error al verificar el correo en Firebase Authentication: $e");
      return false;
    }
  }
}
  
  
  

