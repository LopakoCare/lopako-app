import 'package:flutter/material.dart';

class ActivityDetailsPage extends StatelessWidget {
  final Map<String, dynamic> actividad;

  const ActivityDetailsPage({Key? key, required this.actividad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = actividad['category'] as Map<String, dynamic>?;
    final secondaryCategories = actividad['secondary_categories'] as List<dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la actividad'),
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

            if (actividad['information'] != null)
              Text(actividad['information']),
            const SizedBox(height: 12),

            Text('Duración: ${actividad['duration'] ?? 'N/A'}'),
            Text('Frecuencia: ${actividad['schedule'] ?? 'N/A'}'),
            if (actividad['caregivers'] != null)
              Text('Cuidadores: ${actividad['caregivers']}'),
            const SizedBox(height: 8),

            if (actividad['icon'] != null) ...[
              const SizedBox(height: 12),
              Icon(
                IconData(
                  int.parse(actividad['icon'].toString()),
                  fontFamily: 'MaterialIcons',
                ),
                size: 48,
                color: Colors.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
