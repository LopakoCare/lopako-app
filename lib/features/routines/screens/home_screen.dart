import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/intl_localizations.dart';
import 'package:lopako_app_lis/features/routines/screens/activities_page.dart';
import 'package:lopako_app_lis/features/routines/screens/routines_page.dart';
import 'package:lopako_app_lis/features/familiar_circles/controllers/familiar_circles_controllers.dart';
import 'package:lopako_app_lis/features/routines/controllers/routines_controller.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FamiliarRoutinesController _controller = FamiliarRoutinesController(); //Instancia de controlador de familiar circle
  final RoutinesController _routinesController = RoutinesController(); //Instancia de controlador de rutinas
  late Future<List<Map<String, dynamic>>> _rutinasFuturas;

  @override
  void initState() {
    super.initState();
    _rutinasFuturas = _controller.cargarRutinasAsignadas();
  }

  // Refresh de lista de rutinas
  void _actualizarRutinas() {
    setState(() {
      _rutinasFuturas = _controller.cargarRutinasAsignadas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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

          final rutinas = snapshot.data ?? [];

          if (rutinas.isEmpty) {
            return Center(child: Text(localizations.world));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Tus rutinas asignadas:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...rutinas.map((rutina) {
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
                          final mensaje = await _routinesController.completarRutinaYEliminar(docRef);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(mensaje)),
                          );
                          _actualizarRutinas();
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
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navega a la pantalla de exploración de rutinas
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RoutinesPage()),
          );

          // Al volver (cuando se hace "back"), recarga las rutinas
          _actualizarRutinas();
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.search),
      ),
    );
  }
}

