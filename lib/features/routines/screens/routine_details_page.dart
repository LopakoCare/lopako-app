import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/routines/controllers/routines_controller.dart';

class RoutineDetailsPage extends StatefulWidget {
  final DocumentReference rutinaRef;
  final Map<String, dynamic> rutinaData;
  final RoutinesController controller;

  const RoutineDetailsPage({
    Key? key,
    required this.rutinaRef,
    required this.rutinaData,
    required this.controller,
  }) : super(key: key);

  @override
  State<RoutineDetailsPage> createState() => _RoutineDetailsPageState();
}

class _RoutineDetailsPageState extends State<RoutineDetailsPage> {
  late Future<List<Map<String, dynamic>>> _actividadesFuture;

  @override
  void initState() {
    super.initState();
    final referenciasActividades = widget.rutinaData['activities'] as List<dynamic>? ?? [];

    // 🔍 LOG para comprobar el tipo y valor real de cada referencia
    for (var ref in referenciasActividades) {
      print('🔍 Tipo de referencia: ${ref.runtimeType}, valor: $ref');
    }

    _actividadesFuture = widget.controller.cargarActividadesDesdeReferencias(referenciasActividades);
  }


  @override
  Widget build(BuildContext context) {
    final categorias = widget.rutinaData['category'] as Map<String, dynamic>? ?? {};
    final secondCategories = widget.rutinaData['secondary_categories'] as Map<String, dynamic>? ?? {};
    final information = widget.rutinaData['information'] as String?;
    final schedule = widget.rutinaData['schedule'] as String?;
    final duration = widget.rutinaData['duration'] as String?;
    final iconUrl = widget.rutinaData['icon'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles rutina'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _actividadesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error cargando actividades: ${snapshot.error}'));
          }

          final actividades = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (iconUrl != null && iconUrl.isNotEmpty)
                  Center(
                    child: Image.network(
                      iconUrl,
                      height: 100,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 80),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  widget.rutinaData['title'] ?? 'Sin título',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (information != null && information.isNotEmpty)
                  Text(information, style: const TextStyle(fontSize: 16)),
                if (schedule != null && schedule.isNotEmpty)
                  Text('Horario: $schedule', style: const TextStyle(fontSize: 16)),
                if (duration != null && duration.isNotEmpty)
                  Text('Duración: $duration', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                if (categorias.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text('Categoría principal:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: categorias.entries.map((entry) {
                          return Chip(label: Text('${entry.key}: ${entry.value}'));
                        }).toList(),
                      ),
                    ],
                  ),
                if (secondCategories.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Text('Categorías secundarias:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: secondCategories.entries.map((entry) {
                          return Chip(label: Text('${entry.key}: ${entry.value}'));
                        }).toList(),
                      ),
                    ],
                  ),
                if (actividades.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text('Actividades:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      ...actividades.map((actividad) {
                        final title = actividad['title'] ?? 'Sin título';
                        return Text('- $title');
                      }).toList(),
                    ],
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final mensaje = await widget.controller.anadirRutinaAFamilia(widget.rutinaRef);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Añadir a mi familia'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
