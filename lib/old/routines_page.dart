import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lopako_app_lis/services/firebase_user_utils.dart';


//Modelo de una actividad
class Actividad {
  final String title;

  //Constructor de la clase Actividad
  Actividad({required this.title});

  //Crea una instancia de Actividad a partir de un documento Firestore
  factory Actividad.fromFirestore(Map<String, dynamic> data) {
    return Actividad(
        title: data['title'] ?? 'Sin título'
    );
  }
}

class RoutinesPage extends StatelessWidget {
  const RoutinesPage({Key? key}) : super(key: key);

  //Carga las actividades referenciadas desde Firestore.
  //Cada referencia en la lista apunta a un documento en la colección `activities`.
  //Esta función devuelve una lista de objetos `Actividad` con el título de cada una.
  Future<List<Actividad>> obtenerActividades(List<dynamic> referencias) async {
    List<Actividad> actividades = [];

    for (final ref in referencias) {
      if (ref is DocumentReference) {
        //Obtener el documento referenciado
        final doc = await ref.get();
        final data = doc.data() as Map<String, dynamic>?;

        //Si el documento contiene un campo 'title', se crea un objeto Actividad
        if (data != null && data['title'] != null) {
          actividades.add(Actividad.fromFirestore(data));
        }

        //TODO: en el futuro, puedes extender esta clase para incluir más campos como descripción, icono, tipo, etc.
      }
    }

    return actividades;
  }


  Future<void> anadirRutinaAFamilia(DocumentReference rutinaRef, BuildContext context) async {
    // Se obtiene el ID del grupo familiar del usuario autenticado
    final familyId = await obtenerFamilyIdActual();

    if (familyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener el ID familiar')),
      );
      return;
    }

    final collectionRef = FirebaseFirestore.instance.collection('familiar_circle_routines');

    // Busca el documento donde el campo family_id coincida
    final querySnapshot = await collectionRef
        .where('family_id', isEqualTo: familyId)
        .limit(1)
        .get();

    DocumentReference? docRef;
    List<dynamic> actuales = [];

    // Si ya existe un documento para ese family_id
    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      docRef = doc.reference;
      actuales = doc.data()['associated_routines'] ?? [];
    } else {
      // Si no existe, se prepara para crear un nuevo documento
      docRef = collectionRef.doc(); // nuevo ID automático
    }

    // Si ya hay 3 rutinas asociadas, no se permite añadir más
    if (actuales.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ya hay 3 rutinas asociadas.')),
      );
      return;
    }

    // Verifica si la rutina ya está añadida
    final yaExiste = actuales.any((ref) => ref is DocumentReference && ref.id == rutinaRef.id);

    if (yaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Esta rutina ya está añadida.')),
      );
      return;
    }

    // Actualiza el documento existente o crea uno nuevo con el campo family_id
    await docRef.set({
      'family_id': familyId,
      'associated_routines': FieldValue.arrayUnion([rutinaRef])
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rutina añadida correctamente')),
    );
  }



  @override
  Widget build(BuildContext context) {
    //Referencia a la colección 'routines' en Firestore
    final rutinasRef = FirebaseFirestore.instance.collection('routines');

    return StreamBuilder<QuerySnapshot>(
      //Se suscribe a los cambios en tiempo real de la colección 'routines'
      stream: rutinasRef.snapshots(),
      builder: (context, snapshot) {
        //Muestra un loader mientras se obtienen los datos
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        //Obtiene la lista de documentos (rutinas)
        final rutinas = snapshot.data?.docs ?? [];

        //Si no hay rutinas, muestra un mensaje
        if (rutinas.isEmpty) {
          return const Center(child: Text('No hay rutinas disponibles.'));
        }

        //Construye una lista de tarjetas con cada rutina
        return ListView.builder(
          itemCount: rutinas.length,
          itemBuilder: (context, index) {
            final rutina = rutinas[index].data() as Map<String, dynamic>;

            //Mapa de categorías (ej. felicidad: 4)
            final categorias = rutina['categories'] as Map<String, dynamic>?;

            //Lista de referencias a actividades
            final referenciasActividades = rutina['activities'] as List<dynamic>? ?? [];

            //Usa FutureBuilder para cargar las actividades asociadas (consulta adicional)
            return FutureBuilder<List<Actividad>>(
              future: obtenerActividades(referenciasActividades),
              builder: (context, actividadesSnapshot) {
                final actividades = actividadesSnapshot.data ?? [];

                //Estructura visual de una tarjeta para cada rutina
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Título de la rutina
                        Text(
                          rutina['title'] ?? 'Sin título',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        //Descripción, duración y frecuencia
                        Text(rutina['description'] ?? 'Sin descripción'),
                        const SizedBox(height: 8),
                        Text('Duración: ${rutina['duration'] ?? 'N/A'}'),
                        Text('Frecuencia: ${rutina['frequency'] ?? 'N/A'}'),
                        const SizedBox(height: 8),

                        //Visualización de categorías como chips (si existen)
                        if (categorias != null && categorias.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: categorias.entries.map((entry) {
                              return Chip(
                                label: Text('${entry.key}: ${entry.value}'),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 8),

                        //Visualización de actividades asociadas a esta rutina
                        if (actividades.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Actividades:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              ...actividades.map((actividad) => Row(
                                children: [
                                  Text('${actividad.title}'),
                                ],
                              )),
                              const SizedBox(height: 16),

                              // 🟣 Botón "Añadir" debajo de las actividades
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple, // Lila
                                  foregroundColor: Colors.white,  // Texto en blanco
                                ),
                                onPressed: () async {
                                  final rutinaRef = rutinas[index].reference;
                                  await anadirRutinaAFamilia(rutinaRef, context);
                                },
                                child: Text('Añadir'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
