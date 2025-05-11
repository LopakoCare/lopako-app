import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  int? _age;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            _nameController.text = data['name'] ?? '';
            _age = data['age'];
          });
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final name = _nameController.text.trim();
      final password = _passwordController.text.trim();

      try {
        // Actualizar Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'name': name,
          'age': _age ?? 0,
        });

        // Actualizar displayName en Firebase Auth
        await user.updateDisplayName(name);

        // Si se ingresó una nueva contraseña, actualizarla
        if (password.isNotEmpty) {
          await user.updatePassword(password);
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Perfil actualizado con éxito.')));
        Navigator.pop(context); // Volver atrás
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: _age,
              decoration: InputDecoration(labelText: 'Edad'),
              items: List.generate(96, (index) {
                int age = 5 + index; // Desde 5 hasta 100
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
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Nueva Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
