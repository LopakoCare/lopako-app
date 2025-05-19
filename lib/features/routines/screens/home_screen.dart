import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/routines/screens/activities_page.dart';
import 'package:lopako_app_lis/features/routines/screens/discover_routines_page.dart';
import 'package:lopako_app_lis/features/routines/controllers/routines_controller.dart';
// 🔄 Necesitas estos imports para el ServiceManager y services
import 'package:lopako_app_lis/core/services/service_manager.dart';
import 'package:lopako_app_lis/core/services/routines_service.dart';
import 'package:lopako_app_lis/core/services/family_circles_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🔄 Ahora el controller se declara e inicializa dentro del estado
  late final RoutinesController _controller;

  late Future<List<Map<String, dynamic>>> _rutinasFuturas;

  @override
  void initState() {
    super.initState();
    _controller = RoutinesController(
      ServiceManager.instance.getService<RoutinesService>('routines'),
      ServiceManager.instance.getService<FamilyCirclesService>('familyCircles'),
    );
    _rutinasFuturas = _controller.obtenerTodasLasRutinas();
  }

  void _actualizarRutinas() {
    setState(() {
      _rutinasFuturas = _controller.obtenerTodasLasRutinas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _rutinasFuturas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print('❌ Error: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final rutinas = snapshot.data ?? [];
            print('✅ Rutinas cargadas: ${rutinas.length}');
            if (rutinas.isEmpty) {
              return const Center(child: Text('No hay rutinas disponibles.'));
            }

            // 🔄 Vista simplificada SOLO para test: lista de títulos
            return ListView(
              children: rutinas.map((rutina) {
                final title = rutina['title'] ?? 'Sin título';
                final category = rutina['category'] as Map<String, dynamic>? ?? {};
                final secondary = rutina['secondary_categories'] as Map<String, dynamic>? ?? {};
                final ref = rutina['__ref__'];

                // ⚠ Validación para evitar errores si falta __ref__
                if (ref == null || ref is! DocumentReference) {
                  return const SizedBox(); // o muestra una tarjeta inválida
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActivitiesPage(
                            rutina: rutina,
                            controller: _controller,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          if (category.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              children: category.entries.map((entry) {
                                return Chip(label: Text('${entry.key}: ${entry.value}'));
                              }).toList(),
                            ),

                          if (secondary.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Wrap(
                                spacing: 8,
                                children: secondary.entries.map((entry) {
                                  return Chip(label: Text('${entry.key}: ${entry.value}'));
                                }).toList(),
                              ),
                            ),

                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                final mensaje = await _controller.completarRutinaYEliminar(ref);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
                                _actualizarRutinas();
                              },
                              child: const Text('Completar', style: TextStyle(color: Colors.green)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoutinesPage(controller: _controller), // 🔄 Pasamos el controller interno a la otra vista
            ),
          );
          _actualizarRutinas();
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
