import 'package:flutter/material.dart';
import 'package:lopako_app_lis/auth_service.dart';
import 'login_page.dart';
import 'profile_page.dart';  // Asegúrate de tener esta página si es necesaria

class HomePage extends StatelessWidget {
  final AuthService _authService = AuthService();

  // Método para cerrar sesión
  Future<void> signOut(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(email: '',)),  // Redirige al LoginPage
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
              Navigator.pushNamed(context, '/profile');  // Asegúrate de tener la ruta '/profile' configurada
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
            // Mensaje de bienvenida
            Text(
              '¡Has iniciado sesión correctamente!',
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            // Campo para agregar tareas
            TextField(
              decoration: InputDecoration(
                labelText: "Nueva Tarea",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Botón para agregar tarea
            ElevatedButton(
              onPressed: () {
                // Aquí va la lógica para añadir tareas en el futuro
              },
              child: Text('Añadir Tarea'),
            ),
          ],
        ),
      ),
    );
  }
}
