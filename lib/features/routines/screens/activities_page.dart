import 'package:flutter/material.dart';
import 'package:lopako_app_lis/features/routines/controllers/routines_controller.dart';
import 'activity_details_page.dart';

class ActivitiesPage extends StatefulWidget {
  final Map<String, dynamic> rutina;
  final RoutinesController controller; // 🔄 NUEVO

  const ActivitiesPage({Key? key, required this.rutina, required this.controller}) : super(key: key);

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late Future<List<Map<String, dynamic>>> _actividadesFuturas;

  @override
  void initState() {
    super.initState();
    final referencias = widget.rutina['activities'] as List<dynamic>? ?? [];
    _actividadesFuturas = widget.controller.cargarActividadesDesdeReferencias(referencias);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actividades de la rutina')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _actividadesFuturas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final actividades = snapshot.data ?? [];

          if (actividades.isEmpty) {
            return const Center(child: Text('Esta rutina no tiene actividades.'));
          }

          return ListView.builder(
            itemCount: actividades.length,
            itemBuilder: (context, index) {
              final actividad = actividades[index];
              return ListTile(
                title: Text(actividad['title'] ?? 'Sin título'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActivityDetailsPage(actividad: actividad),
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
