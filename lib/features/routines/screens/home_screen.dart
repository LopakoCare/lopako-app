import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/intl_localizations.dart';
import 'package:lopako_app_lis/features/routines/screens/activities_page.dart';
import 'package:lopako_app_lis/features/routines/screens/routines_page.dart';
import 'package:lopako_app_lis/features/familiar_circles/controllers/familiar_circles_controllers.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({Key? key}) : super(key: key);

  @override
  _RoutinesScreenState createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final FamiliarRoutinesController _controller = FamiliarRoutinesController(); //Declaramos controlador de famliar_circles para usar funciones
  late Future<List<Map<String, dynamic>>> _rutinasFuturas;

  @override
  void initState() {
    super.initState();
    _rutinasFuturas = _controller.cargarRutinasAsignadas(); // Usamos el controlador
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
              ...rutinas.map((rutina) => ListTile(
                title: Text(rutina['title'] ?? 'Sin título'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActivitiesPage(rutina: rutina),
                    ),
                  );
                },
              )),

            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RoutinesPage()),
          );
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.search),
      ),
    );
  }
}
