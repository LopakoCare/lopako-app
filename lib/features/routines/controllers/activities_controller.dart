import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/routines/models/actividad.dart';

class ActivitiesController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Carga las actividades referenciadas en una rutina
  Future<List<Map<String, dynamic>>> cargarActividadesDesdeRutina(Map<String, dynamic> rutina) async {
    final referencias = rutina['activities'] as List<dynamic>? ?? [];
    List<Map<String, dynamic>> actividades = [];

    for (String activityPath in referencias) {
      try {
        final doc = await _firestore.doc(activityPath).get();
        if (doc.exists && doc.data() != null) {
          actividades.add(doc.data()!);
        }
      } catch (e) {
        print('Error cargando actividad: $e');
      }
    }

    return actividades;
  }
}
