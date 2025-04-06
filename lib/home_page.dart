import 'package:flutter/material.dart';
import 'package:lopako_app_lis/auth_service.dart';
import 'login_page.dart';  // Asegúrate de importar LoginPage

class HomePage extends StatelessWidget {
  final AuthService _authService = AuthService();


  Future<void> signOut(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Página Principal"),
        actions: [
          // Botón para ver perfil
          IconButton(
            icon: Icon(Icons.person),
            tooltip: 'Ver Perfil',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          // Botón para cerrar sesión
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => signOut(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '¡Has iniciado sesión correctamente!',
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              decoration: InputDecoration(
                labelText: "Nueva Tarea",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para añadir tareas en el futuro
              },
              child: Text('Añadir Tarea'),
            ),
          ],
        ),
      ),
    );
  }
}
