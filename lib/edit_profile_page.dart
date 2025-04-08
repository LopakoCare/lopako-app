import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _passwordController = TextEditingController();

  String _statusMessage = '';

  void _updatePassword() async {
    User? user = _auth.currentUser;
    String newPassword = _passwordController.text;

    try {
      if (newPassword.isNotEmpty) {
        await user?.updatePassword(newPassword);
        setState(() {
          _statusMessage = 'Contraseña actualizada correctamente.';
        });
      } else {
        setState(() {
          _statusMessage = 'Por favor introduce una nueva contraseña.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error inesperado: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Nueva contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePassword,
              child: Text('Cambiar contraseña'),
            ),
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(_statusMessage, style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
