import 'package:flutter/material.dart';
import 'package:lopako_app_lis/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final String email;

  LoginPage({required this.email});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final passwordController = TextEditingController();
  final auth = AuthService();

  void handleLogin() async {
    final email = widget.email;
    final password = passwordController.text;

    try {
      final user = await auth.login(email, password);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      }
    } catch (e) {
      showErrorDialog("Error al iniciar sesión");
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
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Inicia sesión con tu correo electrónico", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: widget.email),
              decoration: InputDecoration(labelText: 'Correo electrónico'),
              enabled: false,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleLogin,
              child: Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
