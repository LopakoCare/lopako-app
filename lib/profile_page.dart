import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserData() async {
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mi Perfil')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No se encontraron datos del usuario.'));
          }

          final userData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Correo electrónico:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(userData['email'] ?? 'Sin correo'),
                SizedBox(height: 20),
                Text('Nombre:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(userData['name'] ?? 'Sin nombre'),
                SizedBox(height: 20),
                Text('Edad:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${userData['age'] ?? 'Sin edad'} años'),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit-profile');
                  },
                  child: Text('Editar Perfil'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
