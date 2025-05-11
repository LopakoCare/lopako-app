import 'package:flutter/material.dart';
import 'package:lopako_app_lis/features/routines/controllers/activities_controller.dart';
import 'activity_details_page.dart'; // Importa la nueva página de detalles

class ActivitiesPage extends StatefulWidget {
  final Map<String, dynamic> rutina;

  const ActivitiesPage({Key? key, required this.rutina}) : super(key: key);

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late Future<List<Map<String, dynamic>>> _actividadesFuturas;
  final ActivitiesController _controller = ActivitiesController();

  @override
  void initState() {
    super.initState();
    _actividadesFuturas = _controller.cargarActividadesDesdeRutina(widget.rutina);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades de la rutina'),
      ),
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
                title: Text(
                  actividad['title'] ?? 'Sin título',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityDetailsPage(
                        actividad: actividad,
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
