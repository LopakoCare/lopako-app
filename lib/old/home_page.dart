import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'routines_page.dart';
import 'calendar_page.dart';

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

  int _selectedIndex = 0; //Estado para la barra de navegación

  //Lista de páginas que se muestran según la pestaña seleccionada
  final List<Widget> _pages = [
    // Página de inicio
    Padding(
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
    //Página de rutinas
    const RoutinesPage(),
    CalendarPage(),  // Add calendar page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Página Principal"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            tooltip: 'Ver Perfil',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: signOut,
          ),
        ],
      ),
      //Muestra la página seleccionada dinámicamente
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar( //BARRA FIJA ABAJO
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; //Actualiza la pestaña seleccionada
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
