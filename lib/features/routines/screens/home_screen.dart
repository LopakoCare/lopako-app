import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lopako_app_lis/generated/l10n.dart';
import 'package:lopako_app_lis/features/routines/screens/activities_page.dart';
import 'package:lopako_app_lis/features/routines/screens/discover_routines_page.dart';
import 'package:lopako_app_lis/features/routines/screens/routine_details_page.dart';
import 'package:lopako_app_lis/features/familiar_circles/controllers/familiar_circles_controllers.dart';
import 'package:lopako_app_lis/features/routines/controllers/routines_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FamiliarCircleController _controller = FamiliarCircleController();
  final RoutinesController _routinesController = RoutinesController();
  late Future<List<Map<String, dynamic>>> _rutinasFuturas;

  @override
  void initState() {
    super.initState();
    _rutinasFuturas = _initializeRutinas();
  }

  Future<List<Map<String, dynamic>>> _initializeRutinas() async {
    try {
      return await _controller.cargarRutinasAsignadas();
    } catch (e) {
      return [];
    }
  }

  void _actualizarRutinas() {
    setState(() {
      _rutinasFuturas = _initializeRutinas();
    });
  }
  Widget _buildBurbujas(List<Map<String, dynamic>> rutinas) {
    final count = rutinas.length;
    final size = MediaQuery.of(context).size;

    if (count > 3) {
      return const Text(
        'Error: Hay demasiadas rutinas asignadas! El máximo de rutinas a la vez es de 3',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      );
    }

    Widget buildBurbuja(int index, String imagePath, String title) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ActivitiesPage(rutina: rutinas[index]),
            ),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size.width * 0.25,
              height: size.width * 0.25,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Positioned(
              bottom: 12,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (count == 1) {
      return Center(
        child: buildBurbuja(0, 'assets/bubbles/yellow.png', rutinas[0]['title'] ?? 'Sin título'),
      );
    } else if (count == 2) {
      return SizedBox(
        width: size.width,
        height: size.width * 0.375,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: size.width * 0.3 - (size.width * 0.25) / 2,
              child: buildBurbuja(0, 'assets/bubbles/yellow.png', rutinas[0]['title'] ?? 'Sin título'),
            ),
            Positioned(
              top: size.width * 0.08,
              right: size.width * 0.3 - (size.width * 0.25) / 2,
              child: buildBurbuja(1, 'assets/bubbles/blue.png', rutinas[1]['title'] ?? 'Sin título'),
            ),
          ],
        ),
      );
    } else if (count == 3) {
      return SizedBox(
        width: size.width,
        height: size.width * 0.25 * 2.2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              left: size.width * 0.3 - (size.width * 0.25) / 2,
              child: buildBurbuja(0, 'assets/bubbles/yellow.png', rutinas[0]['title'] ?? 'Sin título'),
            ),
            Positioned(
              top: size.width * 0.08,
              right: size.width * 0.3 - (size.width * 0.25) / 2,
              child: buildBurbuja(1, 'assets/bubbles/blue.png', rutinas[1]['title'] ?? 'Sin título'),
            ),
            Positioned(
              bottom: 20,
              left: size.width / 2 - (size.width * 0.25) / 2,
              child: buildBurbuja(2, 'assets/bubbles/red.png', rutinas[2]['title'] ?? 'Sin título'),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }



  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.home),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _rutinasFuturas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar las rutinas: ${snapshot.error}'),
            );
          }

          final rutinas = snapshot.data ?? [];

          if (rutinas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(localizations.world),
                  ElevatedButton(
                    onPressed: _actualizarRutinas,
                    child: const Text('Recargar rutinas'),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: _buildBurbujas(rutinas),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RoutinesPage()),
          );
          _actualizarRutinas();
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildRutinaCard(Map<String, dynamic> rutina) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(rutina['title'] ?? 'Sin título'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ActivitiesPage(rutina: rutina),
            ),
          );
        },
        trailing: TextButton(
          onPressed: () async {
            final docRef = rutina['__ref__'] as DocumentReference?;
            if (docRef != null) {
              try {
                final mensaje = await _routinesController.completarRutinaYEliminar(docRef);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(mensaje)),
                );
                _actualizarRutinas();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No se pudo completar la rutina.')),
              );
            }
          },
          child: const Text(
            'Completar',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ),
    );
  }
}

