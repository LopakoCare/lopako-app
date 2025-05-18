import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/routines/controllers/routines_controller.dart';
import 'package:lopako_app_lis/features/routines/models/actividad.dart';
import 'package:lopako_app_lis/features/routines/widgets/youtube_video_player_widget.dart';

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
    final activities = widget.rutinaData['activities'] as List<dynamic>? ?? [];
    _actividadesFuture = _controller.obtenerActividades(activities);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.rutinaData['category'] as Map<String, dynamic>?;
    final secondaryCategories = widget.rutinaData['secondary_categories'] as List<dynamic>?;
    final videoId = widget.rutinaData['videoId'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles rutina'),
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
                Text(widget.rutinaData['information'] ?? 'Sin información'),
                const SizedBox(height: 8),
                Text('Duración: ${widget.rutinaData['duration'] ?? 'N/A'}'),
                Text('Frecuencia: ${widget.rutinaData['schedule'] ?? 'N/A'}'),
                if (widget.rutinaData['icon'] != null)
                  Text('Icono: ${widget.rutinaData['icon']}'),
                const SizedBox(height: 16),

                // Video de YouTube si existe videoId
                if (videoId != null && videoId.isNotEmpty) ...[
                  Text(
                    'Vídeo explicativo:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  YouTubeVideoPlayer(
                    videoId: videoId,
                    autoPlay: false,
                  ),
                  const SizedBox(height: 16),
                ],

                if (category != null && category.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: category.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: const TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                if (secondaryCategories != null && secondaryCategories.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: secondaryCategories.map((cat) {
                        final entry = (cat as Map<String, dynamic>).entries.first;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.purple.withOpacity(0.3)),
                          ),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: TextStyle(
                              color: Colors.purple.withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                if (actividades.isNotEmpty) ...[
                  const Text(
                    'Actividades:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...actividades.map((actividad) => Text('- ${actividad.title}')).toList(),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final mensaje = await _controller.anadirRutinaAFamilia(widget.rutinaRef);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(mensaje)));
                    }
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
