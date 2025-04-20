import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lopako_app_lis/auth_service.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'routines_page.dart';
import 'calendar_page.dart';
import 'services/firebase_user_utils.dart'; // Importa la función reutilizable obtenerFamilyIdActual

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  Future<void> signOut() async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(email: '')),
    );
  }

  int _selectedIndex = 0; // Estado para la barra de navegación

  // Función que carga las rutinas asociadas al grupo familiar del usuario autenticado
  Future<List<Map<String, dynamic>>> _cargarRutinasAsignadas() async {
    final familyId = await obtenerFamilyIdActual(); // Usa la función desde firebase_user_utils.dart
    if (familyId == null) return [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('familiar_circle_routines')
        .where('family_id', isEqualTo: familyId) // Busca por el campo family_id, no por ID de documento
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return [];

    final doc = querySnapshot.docs.first;
    final referencias = doc['associated_routines'] as List<dynamic>? ?? [];

    List<Map<String, dynamic>> rutinas = [];

    for (final ref in referencias) {
      if (ref is DocumentReference) {
        final doc = await ref.get();
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) rutinas.add(data);
      }
    }

    return rutinas;
  }

  // Lista de páginas que se muestran según la pestaña seleccionada
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();

    _pages.addAll([
      // Página de inicio
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Usamos ListView para permitir scroll si hay muchas rutinas
          children: [
            // Mensaje de bienvenida
            const Text(
              '¡Has iniciado sesión correctamente!',
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Campo para agregar tareas
            const TextField(
              decoration: InputDecoration(
                labelText: "Nueva Tarea",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Botón para agregar tarea
            ElevatedButton(
              onPressed: () {
                // Aquí va la lógica para añadir tareas en el futuro
              },
              child: const Text('Añadir Tarea'),
            ),

            // Sección que muestra las rutinas asociadas al grupo familiar del usuario
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _cargarRutinasAsignadas(), // Llama a la función que obtiene las rutinas
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(child: CircularProgressIndicator()), // Muestra loader mientras se carga
                  );
                }

                final rutinas = snapshot.data ?? [];

                if (rutinas.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('No hay rutinas asignadas.'), // Muestra mensaje si no hay datos
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Tus rutinas asignadas:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    // Lista de rutinas asociadas al grupo familiar
                    //TODO: Hacer q al clicar en la rutina parezcan las actividades asignadas a esta
                    ...rutinas.map((rutina) => ListTile(
                      title: Text(rutina['title'] ?? 'Sin título'),
                      subtitle: Text(rutina['description'] ?? ''),
                    )),
                  ],
                );
              },
            ),
          ],
        ),
      ),

      // Página de rutinas
      const RoutinesPage(),

      // Página de calendario
      CalendarPage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Página Principal"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Ver Perfil',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: signOut,
          ),
        ],
      ),
      // Muestra la página seleccionada dinámicamente
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Rutinas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
        ],
      ),
    );
  }
}
