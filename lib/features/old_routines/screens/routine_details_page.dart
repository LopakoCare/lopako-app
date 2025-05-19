import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/routines/controllers/routines_controller.dart';


class RoutineDetailsPage extends StatefulWidget {
  final DocumentReference rutinaRef;
  final Map<String, dynamic> rutinaData;

  const RoutineDetailsPage({Key? key, required this.rutinaRef, required this.rutinaData}) : super(key: key);

  @override
  State<RoutineDetailsPage> createState() => _RoutineDetailsPageState();
}

class _RoutineDetailsPageState extends State<RoutineDetailsPage> {
  final RoutinesController _controller = RoutinesController();
  late Future<List<Actividad>> _actividadesFuture;

  @override
  void initState() {
    super.initState();
    final referenciasActividades = widget.rutinaData['activities'] as List<dynamic>? ?? [];
    _actividadesFuture = _controller.obtenerActividades(referenciasActividades);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = widget.rutinaData['categories'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles rutina'),
      ),
      body: FutureBuilder<List<Actividad>>(
        future: _actividadesFuture,
        builder: (context, actividadesSnapshot) {
          final actividades = actividadesSnapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.rutinaData['title'] ?? 'Sin título',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(widget.rutinaData['description'] ?? 'Sin descripción'),
                const SizedBox(height: 8),
                Text('Duración: ${widget.rutinaData['duration'] ?? 'N/A'}'),
                Text('Frecuencia: ${widget.rutinaData['frequency'] ?? 'N/A'}'),
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
                if (actividades.isNotEmpty) ...[
                  const Text(
                    'Actividades:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...actividades.map((actividad) => Text('- ${actividad.title}')),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final mensaje = await _controller.anadirRutinaAFamilia(widget.rutinaRef);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
                    // Opcional: podrías setState si quieres cambiar la UI tras añadir
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Añadir'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
