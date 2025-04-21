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
}
