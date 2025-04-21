import 'package:flutter/material.dart';
import 'package:lopako_app_lis/features/routines/controllers/activities_controller.dart';

class ActivitiesPage extends StatefulWidget {
  final Map<String, dynamic> rutina;

  const ActivitiesPage({Key? key, required this.rutina}) : super(key: key);

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late Future<List<Map<String, dynamic>>> _actividadesFuturas;
  final ActivitiesController _controller = ActivitiesController(); // Declaramos el controlador

  @override
  void initState() {
    super.initState();
    _actividadesFuturas = _controller.cargarActividadesDesdeRutina(widget.rutina); // Usamos el controlador
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rutina['title'] ?? 'Rutina'),
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

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actividad['title'] ?? 'Sin título',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (actividad['description'] != null)
                        Text(actividad['description']),
                      if (actividad['tipo'] != null)
                        Text('Tipo: ${actividad['tipo']}'),
                      if (actividad['icono'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.network(
                            actividad['icono'],
                            height: 50,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                          ),
                        ),
                      if (actividad['enlaces'] != null)
                        Text('Enlaces: ${actividad['enlaces']}'),
                      if (actividad['audios'] != null)
                        Text('Audios: ${actividad['audios']}'),
                      if (actividad['imagenes'] != null)
                        Text('Imágenes: ${actividad['imagenes']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
