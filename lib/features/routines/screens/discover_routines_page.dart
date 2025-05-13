import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/routines/controllers/routines_controller.dart';
import 'package:lopako_app_lis/features/routines/screens/routine_details_page.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({Key? key}) : super(key: key);

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  final RoutinesController _controller = RoutinesController();
  final TextEditingController _searchController = TextEditingController();
  Set<String> _categoriasSeleccionadas = {};

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
    setState(() {}); // Para que se actualice al escribir
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
          _buildCategoryFilters(),
          Expanded(child: _buildRutinasList(rutinasRef)),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator());

        final categoriesDocs = snapshot.data!.docs;
        if (categoriesDocs.isEmpty) return const SizedBox();

        return Container(
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categoriesDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final categoryName = data['name'] ?? 'Sin nombre';
                final isSelected = _categoriasSeleccionadas.contains(categoryName);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(categoryName),
                    selected: isSelected,
                    selectedColor: Colors.purple[200],
                    showCheckmark: false,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
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
    );
  }

  Widget _buildRutinasList(CollectionReference rutinasRef) {
    return StreamBuilder<QuerySnapshot>(
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

        final filteredRutinas = rutinasDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final categorias = data['categories'] as Map<String, dynamic>?;
          final title = (data['title'] ?? '').toString().toLowerCase();
          final query = _searchController.text.toLowerCase();

          if (query.isNotEmpty && !title.contains(query)) {
            return false;
          }

          if (_categoriasSeleccionadas.isEmpty) {
            return true;
          }
          if (categorias == null) return false;

          return _categoriasSeleccionadas.every((cat) => categorias.keys.contains(cat));
        }).toList();

        if (filteredRutinas.isEmpty) {
          return const Center(child: Text('No hay rutinas que coincidan con la búsqueda o filtros.'));
        }

        return ListView.builder(
          itemCount: filteredRutinas.length,
          itemBuilder: (context, index) {
            final rutinaDoc = filteredRutinas[index];
            final rutinaData = rutinaDoc.data() as Map<String, dynamic>;
            final rutinaRef = rutinaDoc.reference;

            final categorias = rutinaData['categories'] as Map<String, dynamic>? ?? {};

            return ListTile(
              title: Text(rutinaData['title'] ?? 'Sin título', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: categorias.isNotEmpty
                  ? Wrap(
                spacing: 6,
                runSpacing: 6,
                children: categorias.entries.map((entry) {
                  final nombreCategoria = entry.key;
                  final valorCategoria = entry.value;
                  return Chip(
                    label: Text('$nombreCategoria $valorCategoria'),
                  );
                }).toList(),
              )
                  : null,
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoutineDetailsPage(
                      rutinaRef: rutinaRef,
                      rutinaData: rutinaData,
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
