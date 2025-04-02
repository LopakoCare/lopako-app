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
          // Botón para cerrar sesión
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => signOut(context), // Llamando a la función de logout
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mensaje de bienvenida
            Text(
              '¡Has iniciado sesión correctamente!',
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            // Campo para agregar tarea
            TextField(
              decoration: InputDecoration(
                labelText: "Nueva Tarea",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Botón para añadir tarea
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
