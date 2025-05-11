import 'package:flutter/material.dart';

class ActivityDetailsPage extends StatelessWidget {
  final Map<String, dynamic> actividad;

  const ActivityDetailsPage({Key? key, required this.actividad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la actividad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              actividad['title'] ?? 'Sin título',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (actividad['description'] != null)
              Text(actividad['description']),
            const SizedBox(height: 12),
            if (actividad['tipo'] != null)
              Text('Tipo: ${actividad['tipo']}'),
            const SizedBox(height: 8),
            if (actividad['icono'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.network(
                  actividad['icono'],
                  height: 50,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                ),
              ),
            const SizedBox(height: 12),
            if (actividad['enlaces'] != null)
              Text('Enlaces: ${actividad['enlaces']}'),
            const SizedBox(height: 8),
            if (actividad['audios'] != null)
              Text('Audios: ${actividad['audios']}'),
            const SizedBox(height: 8),
            if (actividad['imagenes'] != null)
              Text('Imágenes: ${actividad['imagenes']}'),
          ],
        ),
      ),
    );
  }
}
