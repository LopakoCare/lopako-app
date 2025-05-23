import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/familiar_circles/controllers/familiar_circles_controllers.dart';

class Actividad {
  final String title;

  Actividad({required this.title});

  factory Actividad.fromFirestore(Map<String, dynamic> data) {
    return Actividad(
      title: data['title'] ?? 'Sin título',
    );
  }
}

class RoutinesController {
  final FamiliarRoutinesController _familiarController = FamiliarRoutinesController();

  // Obtiene todas las rutinas
  Future<List<Actividad>> obtenerTodasLasRutinas() async{
    final querySnapshot = await FirebaseFirestore.instance.collection('old_routines').get();
    final List<Actividad> actividades = querySnapshot.docs.map((doc) => Actividad.fromFirestore(doc.data())).toList();

    return actividades;
  }

  // Busca rutinas por título (directamente en Firestore)
  Future<List<DocumentReference>> buscarRutinasPorTitulo(String query) async {
    final collectionRef = FirebaseFirestore.instance.collection('old_routines');
    final querySnapshot = await collectionRef
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + 'z')
        .get();

    final List<DocumentReference> resultados = querySnapshot.docs.map((doc) => doc.reference).toList();
    return resultados;
  }
  
  List<Actividad> buscarRutinasPorTituloLocal(List<Actividad> rutinas, String query) {
    query = query.toLowerCase();
    return rutinas.where((rutina) => rutina.title.toLowerCase().contains(query)).toList();
  }

  // Carga las actividades referenciadas en una rutina
  Future<List<Actividad>> obtenerActividades(List<dynamic> referencias) async {
    List<Actividad> actividades = [];

    for (final ref in referencias) {
      if (ref is DocumentReference) {
        final doc = await ref.get();
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['title'] != null) {
          actividades.add(Actividad.fromFirestore(data));
        }
      }
    }

    return actividades;
  }

  // Añade una rutina al grupo familiar del usuario autenticado
  Future<String> anadirRutinaAFamilia(DocumentReference rutinaRef) async {
    final familyId = await _familiarController.obtenerFamilyIdActual();

    if (familyId == null) {
      return 'No se pudo obtener el ID familiar';
    }

    final collectionRef = FirebaseFirestore.instance.collection('familiar_circle_routines');

    final querySnapshot = await collectionRef
        .where('family_id', isEqualTo: familyId)
        .limit(1)
        .get();

    DocumentReference? docRef;
    List<dynamic> actuales = [];

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      docRef = doc.reference;
      actuales = doc.data()['associated_routines'] ?? [];
    } else {
      docRef = collectionRef.doc();
    }

    if (actuales.length >= 3) {
      return 'Ya hay 3 rutinas asociadas.';
    }

    final yaExiste = actuales.any((ref) => ref is DocumentReference && ref.id == rutinaRef.id);

    if (yaExiste) {
      return 'Esta rutina ya está añadida.';
    }

    await docRef.set({
      'family_id': familyId,
      'associated_routines': FieldValue.arrayUnion([rutinaRef])
    }, SetOptions(merge: true));

    return 'Rutina añadida correctamente';
  }

  // Elimina una rutina del grupo familiar del usuario autenticado
  Future<String> completarRutinaYEliminar(DocumentReference rutinaRef) async {
    // Obtiene el ID del grupo familiar del usuario autenticado
    final familyId = await _familiarController.obtenerFamilyIdActual();

    // Si no se pudo obtener el ID, retorna un mensaje de error
    if (familyId == null) {
      return 'No se pudo obtener el ID familiar';
    }

    // Referencia a la colección donde se almacenan las rutinas familiares
    final collectionRef = FirebaseFirestore.instance.collection('familiar_circle_routines');

    // Busca el documento correspondiente al family_id en la colección
    final querySnapshot = await collectionRef
        .where('family_id', isEqualTo: familyId)
        .limit(1)
        .get();

    // Si no se encuentra un documento para ese family_id, retorna error
    if (querySnapshot.docs.isEmpty) {
      return 'No se encontró ninguna rutina asociada al grupo familiar';
    }

    // Obtiene la referencia del documento que contiene las rutinas asociadas
    final docRef = querySnapshot.docs.first.reference;

    // Actualiza el documento eliminando la rutina referenciada del array
    await docRef.update({
      'associated_routines': FieldValue.arrayRemove([rutinaRef])
    });

    // Retorna un mensaje de éxito
    return 'Rutina marcada como completada';
  }

}