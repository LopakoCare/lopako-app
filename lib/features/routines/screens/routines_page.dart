import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/routines/controllers/routines_controller.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({Key? key}) : super(key: key);

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  final RoutinesController _controller = RoutinesController();
  final TextEditingController _searchController = TextEditingController();
  List<DocumentReference> _searchResults = [];
  Set<String> _categoriasSeleccionadas = {}; // <-- CAMBIA: ahora es un Set para múltiples categorías

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _buscarRutinas();
  }

  void _buscarRutinas() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    final results = await _controller.buscarRutinasPorTitulo(query);
    setState(() {
      _searchResults = results;
    });
  }

  Future<List<Map<String, dynamic>>> _obtenerDatosRutinasPorRef(List<DocumentReference> refs) async {
    List<Map<String, dynamic>> rutinasData = [];
    for (final ref in refs) {
      final docSnapshot = await ref.get();
      if (docSnapshot.exists) {
        rutinasData.add(docSnapshot.data() as Map<String, dynamic>);
      }
    }
    return rutinasData;
  }

  Widget _buildRutinaCard(Map<String, dynamic> rutina, int index, Stream<QuerySnapshot<Object?>> snapshotStream) {
    final categorias = rutina['categories'] as Map<String, dynamic>?;
    final referenciasActividades = rutina['activities'] as List<dynamic>? ?? [];

    return FutureBuilder<List<Actividad>>(
      future: _controller.obtenerActividades(referenciasActividades),
      builder: (context, actividadesSnapshot) {
        final actividades = actividadesSnapshot.data ?? [];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rutina['title'] ?? 'Sin título',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(rutina['description'] ?? 'Sin descripción'),
                const SizedBox(height: 8),
                Text('Duración: ${rutina['duration'] ?? 'N/A'}'),
                Text('Frecuencia: ${rutina['frequency'] ?? 'N/A'}'),
                const SizedBox(height: 8),
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
                        children: [Text(actividad.title)],
                      )),
                      const SizedBox(height: 16),
                      StreamBuilder<QuerySnapshot>(
                          stream: snapshotStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final rutinaRef = snapshot.data!.docs.elementAt(index).reference;
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () async {
                                  final mensaje = await _controller.anadirRutinaAFamilia(rutinaRef);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(mensaje)),
                                  );
                                },
                                child: const Text('Añadir'),
                              );
                            } else {
                              return Container();
                            }
                          }
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rutinasRef = FirebaseFirestore.instance.collection('routines');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explorar Rutinas"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar rutinas...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // BOTONES DE CATEGORÍAS - Selección múltiple
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                );
              }
              final categoriesDocs = snapshot.data!.docs;
              if (categoriesDocs.isEmpty) {
                return const SizedBox();
              }
              return Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categoriesDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final categoryName = data['name'] ?? 'Sin nombre';
                      final seleccionada = _categoriasSeleccionadas.contains(categoryName);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FilterChip(
                          label: Text(categoryName),
                          selected: seleccionada,
                          selectedColor: Colors.purple[200],
                          showCheckmark: false,
                          onSelected: (isSelected) {
                            setState(() {
                              if (isSelected) {
                                _categoriasSeleccionadas.add(categoryName);
                              } else {
                                _categoriasSeleccionadas.remove(categoryName);
                              }
                            });
                          },
                        ),

                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          // RESULTADOS
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: rutinasRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final rutinasDocs = snapshot.data?.docs ?? [];
                if (rutinasDocs.isEmpty) {
                  return const Center(child: Text('No hay rutinas disponibles.'));
                }

                final rutinasFiltradas = rutinasDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final categorias = data['categories'] as Map<String, dynamic>?;
                  if (categorias == null) return false;

                  if (_categoriasSeleccionadas.isEmpty) {
                    return true; // Si no hay filtros seleccionados, muestra todas
                  }
                  // Si alguna categoría de la rutina coincide con alguna seleccionada
                  return _categoriasSeleccionadas.every((selected) => categorias.keys.contains(selected));
                }).toList();

                if (rutinasFiltradas.isEmpty) {
                  return const Center(child: Text('No hay rutinas para estas categorías.'));
                }

                return ListView.builder(
                  itemCount: rutinasFiltradas.length,
                  itemBuilder: (context, index) {
                    final rutina = rutinasFiltradas[index].data() as Map<String, dynamic>;
                    return _buildRutinaCard(rutina, index, rutinasRef.snapshots());
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
