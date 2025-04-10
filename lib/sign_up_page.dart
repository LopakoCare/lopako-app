import 'package:flutter/material.dart';
import 'package:lopako_app_lis/auth_service.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  final String email;

  SignUpPage({required this.email});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  int? _age; // Definir la edad seleccionada
  final auth = AuthService();

  // Función para verificar si el correo es válido
  bool isValidEmail(String email) {
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  // Función de registro de usuario
  void handleSignUp() async {
    final email = widget.email;
    final password = passwordController.text;
    final name = nameController.text;

    if (!isValidEmail(email)) {
      showErrorDialog("Por favor ingresa un correo electrónico válido.");
      return;
    }
    if (password.isEmpty) {
      showErrorDialog("Por favor ingresa una contraseña.");
      return;
    }
    if (_age == null || _age! < 5 || _age! > 100) {
      showErrorDialog("Por favor selecciona una edad válida entre 5 y 100.");
      return;
    }

    try {
      final user = await auth.register(email, password);
      if (user != null) {
        await auth.saveUserData(user, name, _age!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      }
    } catch (e) {
      showErrorDialog("Error al registrarse: $e");
    }
  }

  // Función para mostrar el mensaje de error
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
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("¡Encantados de conocerte!", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            // Mostrar correo electrónico pre-llenado y deshabilitado
            TextField(
              controller: TextEditingController(text: widget.email),
              decoration: InputDecoration(labelText: 'Correo electrónico'),
              enabled: false, // Deshabilitar campo
            ),
            SizedBox(height: 20),
            // Campo para la contraseña
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            // Campo para el nombre
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: 20),
            // Dropdown de edad
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Edad'),
              value: _age,
              items: List.generate(20, (index) {
                int age = 5 * (index + 1); // Edad en múltiplos de 5
                return DropdownMenuItem<int>(
                  value: age,
                  child: Text('$age años'),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _age = value;
                });
              },
              validator: (value) {
                if (value == null || value < 5 || value > 100) {
                  return 'Por favor selecciona una edad válida entre 5 y 100';
                }
                return null;
              },
            ),
            SizedBox(height: 60),
            // Botón para registrar
            ElevatedButton(
              onPressed: handleSignUp,
              child: Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
