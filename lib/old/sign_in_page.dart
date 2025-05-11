import 'package:flutter/material.dart';
import 'package:lopako_app_lis/old/auth_service.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final auth = AuthService();

  // Función para verificar si el correo es válido
  bool isValidEmail(String email) {
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Future<void> checkEmail() async {
    final email = emailController.text.trim();

    // Validación del correo electrónico
    if (!isValidEmail(email)) {
      showErrorDialog("Por favor ingresa un correo electrónico válido.");
      return;
    }

    try {
      print("Verificando si el correo existe en Firebase Authentication...");
      // Verificamos si el correo está registrado en Firebase Authentication
      bool emailInFirestore = await auth.checkIfEmailInFirestore(email);

      if (emailInFirestore) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage(email: email)),
        );

      } else {
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SignUpPage(email: email)),
        );
      }
    } catch (e) {
      print("Error al verificar el correo: $e");
      showErrorDialog("Error al verificar el correo: $e");
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            Text("¡Vamos a empezar!", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkEmail,
              child: Text('Continuar'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                print("Iniciando sesión con Google...");
                final user = await auth.signInWithGoogle();
                if (user != null) {
                  print("Google sign-in exitoso, redirigiendo a HomePage...");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomePage()),
                  );
                } else {
                  print('Error al iniciar sesión con Google');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al iniciar sesión con Google')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/google_logo.png',
                    height: 24.0,
                  ),
                  SizedBox(width: 12.0),
                  Text('Sign in with Google'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
