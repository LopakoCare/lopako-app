import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/familiar_circles/controllers/familiar_circles_controllers.dart';
import 'package:lopako_app_lis/features/routines/models/actividad.dart';

class RoutinesController {
  final FamiliarCircleController _familiarController = FamiliarCircleController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtiene todas las rutinas
  Future<List<Actividad>> obtenerTodasLasRutinas() async {
    final querySnapshot = await _firestore.collection('routines').get();
    return querySnapshot.docs
        .map((doc) => Actividad.fromMap(doc.data()))
        .toList();
  }

  // Busca rutinas por título
  Future<List<DocumentReference>> buscarRutinasPorTitulo(String query) async {
    final querySnapshot = await _firestore.collection('routines')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + 'z')
        .get();

    return querySnapshot.docs.map((doc) => doc.reference).toList();
  }
  
  List<Actividad> buscarRutinasPorTituloLocal(List<Actividad> rutinas, String query) {
    query = query.toLowerCase();
    return rutinas.where((rutina) => rutina.title.toLowerCase().contains(query)).toList();
  }

  // Carga las actividades referenciadas en una rutina
  Future<List<Actividad>> obtenerActividades(List<dynamic> activityRefs) async {
    List<Actividad> actividades = [];
    
    for (String activityPath in activityRefs) {
      try {
        final docRef = _firestore.doc(activityPath);
        final snapshot = await docRef.get();
        
        if (snapshot.exists && snapshot.data() != null) {
          actividades.add(Actividad.fromMap(snapshot.data()!));
        }
      } catch (e) {
        print('Error al obtener actividad: $e');
      }
    }
    
    return actividades;
  }

  // Añade una rutina al grupo familiar del usuario autenticado
  Future<String> anadirRutinaAFamilia(DocumentReference rutinaRef) async {
    try {
      final familyId = await _familiarController.obtenerFamilyIdActual();
      if (familyId == null) {
        return 'No se pudo obtener el ID familiar';
      }

      final collectionRef = _firestore.collection('familiar_circle_routines');
      final querySnapshot = await collectionRef
          .where('family_id', isEqualTo: familyId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        await collectionRef.add({
          'family_id': familyId,
          'associated_routines': [rutinaRef]
        });
      } else {
        await querySnapshot.docs.first.reference.update({
          'associated_routines': FieldValue.arrayUnion([rutinaRef])
        });
      }
      
      return 'Rutina añadida exitosamente';
    } catch (e) {
      return 'Error al añadir la rutina: $e';
    }
  }

  // Elimina una rutina del grupo familiar
  Future<String> completarRutinaYEliminar(DocumentReference rutinaRef) async {
    final familyId = await _familiarController.obtenerFamilyIdActual();
    if (familyId == null) {
      return 'No se pudo obtener el ID familiar';
    }

    final collectionRef = _firestore.collection('familiar_circle_routines');
    final querySnapshot = await collectionRef
        .where('family_id', isEqualTo: familyId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return 'No se encontró ninguna rutina asociada al grupo familiar';
    }

    await querySnapshot.docs.first.reference.update({
      'associated_routines': FieldValue.arrayRemove([rutinaRef])
    });

    return 'Rutina marcada como completada';
  }
}