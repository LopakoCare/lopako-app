import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Pantalla que muestra las actividades asociadas a una rutina
class ActivitiesPage extends StatelessWidget {
  final Map<String, dynamic> rutina;

  // Constructor que recibe los datos de la rutina como un mapa
  const ActivitiesPage({Key? key, required this.rutina}) : super(key: key);

  // Función que obtiene las actividades referenciadas en la rutina desde Firestore
  Future<List<Map<String, dynamic>>> _cargarActividades() async {
    // Accede al campo 'activities' de la rutina, que es una lista de referencias
    final referencias = rutina['activities'] as List<dynamic>? ?? [];

    // Lista que almacenará los datos de cada actividad
    List<Map<String, dynamic>> actividades = [];

    // Recorremos las referencias y obtenemos los datos de cada actividad
    for (final ref in referencias) {
      if (ref is DocumentReference) {
        final doc = await ref.get(); // Consulta al documento
        final data = doc.data() as Map<String, dynamic>?; // Convertimos a mapa
        if (data != null) actividades.add(data); // Si tiene datos válidos, los añadimos a la lista
      }
    }

    return actividades; // Devolvemos la lista completa de actividades
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con el título de la rutina
      appBar: AppBar(
        title: Text(rutina['title'] ?? 'Rutina'),
      ),

      // El cuerpo de la pantalla se construye con FutureBuilder para esperar los datos
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cargarActividades(), // Llamada a la función que carga las actividades
        builder: (context, snapshot) {
          // Mientras se cargan los datos, se muestra un indicador de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Una vez cargados los datos, los extraemos o usamos una lista vacía
          final actividades = snapshot.data ?? [];

          // Si no hay actividades, mostramos un mensaje informativo
          if (actividades.isEmpty) {
            return const Center(child: Text('Esta rutina no tiene actividades.'));
          }

          // Mostramos la lista de actividades usando ListView.builder
          return ListView.builder(
            itemCount: actividades.length,
            itemBuilder: (context, index) {
              final actividad = actividades[index];

              // Cada actividad se muestra dentro de una tarjeta visual
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título de la actividad
                      Text(
                        actividad['title'] ?? 'Sin título',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Descripción si existe
                      if (actividad['description'] != null)
                        Text(actividad['description']),

                      // Tipo de actividad si está definido
                      if (actividad['tipo'] != null)
                        Text('Tipo: ${actividad['tipo']}'),

                      // Imagen de icono si está disponible
                      if (actividad['icono'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.network(
                            actividad['icono'],
                            height: 50,
                            // Si la imagen no carga, muestra un icono alternativo
                            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                          ),
                        ),

                      // Enlaces si existen (se muestran como texto por ahora)
                      if (actividad['enlaces'] != null)
                        Text('Enlaces: ${actividad['enlaces']}'),

                      // Audios si existen
                      if (actividad['audios'] != null)
                        Text('Audios: ${actividad['audios']}'),

                      // Imágenes adicionales si existen
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
