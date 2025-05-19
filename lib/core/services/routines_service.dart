// ✅ NUEVO ARCHIVO
import 'package:cloud_firestore/cloud_firestore.dart';
import 'service_manager.dart';

class RoutinesService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> obtenerTodasLasRutinas() async {
    final querySnapshot = await _firestore.collection('routines').get();
    return querySnapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, '__ref__': doc.reference})
        .toList();
  }

  Future<List<Map<String, dynamic>>> cargarActividadesDesdeReferencias(List<dynamic> referencias) async {
    List<Map<String, dynamic>> actividades = [];

    for (final ref in referencias) {
      if (ref is DocumentReference) {
        final doc = await ref.get();
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          print('Actividad encontrada en ${ref.path}: $data'); // 🔄 LOG DETALLADO
          actividades.add({...data, '__ref__': ref});
        } else {
          print('⚠ Actividad vacía en ${ref.path}');
        }
      } else {
        print('⚠ Referencia inválida: $ref');
      }
    }

    print('➡ Total actividades cargadas: ${actividades.length}');
    return actividades;
  }

}
