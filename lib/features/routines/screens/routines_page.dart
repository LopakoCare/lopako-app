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
                            if (snapshot.hasData){
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
                            }
                            else{
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
      body: _searchController.text.isNotEmpty
          ? FutureBuilder<List<Map<String, dynamic>>>(
        future: _obtenerDatosRutinasPorRef(_searchResults),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final rutinas = snapshot.data ?? [];
          if (rutinas.isEmpty) {
            return const Center(child: Text('No se encontraron rutinas.'));
          }
          return ListView.builder(
            itemCount: rutinas.length,
            itemBuilder: (context, index) {
              return _buildRutinaCard(rutinas[index], index, rutinasRef.snapshots());
            },
          );
        },
      )
          : StreamBuilder<QuerySnapshot>(
        stream: rutinasRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final rutinas = snapshot.data?.docs ?? [];
          if (rutinas.isEmpty) {
            return const Center(child: Text('No hay rutinas disponibles.'));
          }
          return ListView.builder(
            itemCount: rutinas.length,
            itemBuilder: (context, index) {
              final rutina = rutinas[index].data() as Map<String, dynamic>;
              return _buildRutinaCard(rutina, index, rutinasRef.snapshots());
            },
          );
        },
      ),
    );
  }
}