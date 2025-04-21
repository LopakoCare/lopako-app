import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/routines/controllers/routines_controller.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({Key? key}) : super(key: key);

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  final RoutinesController _controller = RoutinesController();

  @override
  Widget build(BuildContext context) {
    final rutinasRef = FirebaseFirestore.instance.collection('routines');

    return Scaffold(
      appBar: AppBar(title: const Text("Explorar Rutinas")),
      body: StreamBuilder<QuerySnapshot>(
        stream: rutinasRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rutinas = snapshot.data?.docs ?? [];

          if (rutinas.isEmpty) {
            return const Center(child: Text('No hay rutinas disponibles.'));
          }

          return ListView.builder(
            itemCount: rutinas.length,
            itemBuilder: (context, index) {
              final rutina = rutinas[index].data() as Map<String, dynamic>;
              final categorias = rutina['categories'] as Map<String, dynamic>?;
              final referenciasActividades = rutina['activities'] as List<dynamic>? ?? [];

              return FutureBuilder<List<Actividad>>(
                future: _controller.obtenerActividades(referenciasActividades),
                builder: (context, actividadesSnapshot) {
                  final actividades = actividadesSnapshot.data ?? [];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rutina['title'] ?? 'Sin título',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(rutina['description'] ?? 'Sin descripción'),
                          const SizedBox(height: 8),
                          Text('Duración: ${rutina['duration'] ?? 'N/A'}'),
                          Text('Frecuencia: ${rutina['frequency'] ?? 'N/A'}'),
                          const SizedBox(height: 8),
                          if (categorias != null && categorias.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              children: categorias.entries.map((entry) {
                                return Chip(
                                  label: Text('${entry.key}: ${entry.value}'),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 8),
                          if (actividades.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Actividades:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                ...actividades.map((actividad) => Row(
                                  children: [Text(actividad.title)],
                                )),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final rutinaRef = rutinas[index].reference;
                                    final mensaje = await _controller.anadirRutinaAFamilia(rutinaRef);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(mensaje)),
                                    );
                                  },
                                  child: const Text('Añadir'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
