import 'package:cloud_firestore/cloud_firestore.dart';

class ActivitiesController {
  // Carga las actividades referenciadas en una rutina
  Future<List<Map<String, dynamic>>> cargarActividadesDesdeRutina(Map<String, dynamic> rutina) async {
    final referencias = rutina['activities'] as List<dynamic>? ?? [];

    List<Map<String, dynamic>> actividades = [];

    for (final ref in referencias) {
      if (ref is DocumentReference) {
        final doc = await ref.get();
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) actividades.add(data);
      }
    }

    return actividades;
  }
}
