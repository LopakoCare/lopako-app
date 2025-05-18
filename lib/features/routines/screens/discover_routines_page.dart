import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/routines/controllers/routines_controller.dart';
import 'package:lopako_app_lis/features/routines/screens/routine_details_page.dart';
import 'package:lopako_app_lis/features/routines/widgets/youtube_video_player_widget.dart';

Color parseNamedColor(String? colorName) {
  const colorMap = {
    'red': Colors.red,
    'blue': Colors.blue,
    'teal': Colors.teal,
    'green': Colors.green,
    'yellow': Colors.yellow,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'pink': Colors.pink,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'black': Colors.black,
    'white': Colors.white,
  };

  if (colorName == null) return Colors.grey;

  return colorMap[colorName.toLowerCase()] ?? Colors.grey;
}

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({Key? key}) : super(key: key);

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  final TextEditingController _searchController = TextEditingController();
  final CollectionReference _catsRef = FirebaseFirestore.instance.collection('routine_categories');
  final CollectionReference _rutasRef = FirebaseFirestore.instance.collection('routines');

  Set<String> _categoriasSeleccionadas = {};
  Map<String, String> _categoryLabels = {}; // id -> label

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explorar Rutinas"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _catsRef.snapshots(),
        builder: (ctx, catSnap) {
          if (!catSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // 1) construimos el mapa id->label
          _categoryLabels = {
            for (var doc in catSnap.data!.docs)
              doc.id: (doc.data() as Map<String, dynamic>)['label'] as String
          };

          return Column(
            children: [
              // 2) filtro horizontal
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: catSnap.data!.docs.map((doc) {
                      final id    = doc.id;
                      final data  = doc.data() as Map<String, dynamic>;
                      final label = data['label'] ?? 'Sin nombre';
                      final color = parseNamedColor(data['color']);
                      final sel   = _categoriasSeleccionadas.contains(id);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(label),
                          selected: sel,
                          backgroundColor: color,
                          selectedColor: Colors.purple[200],
                          showCheckmark: false,
                          onSelected: (yes) {
                            setState(() {
                              if (yes) _categoriasSeleccionadas.add(id);
                              else     _categoriasSeleccionadas.remove(id);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // 3) lista de rutinas
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _rutasRef.snapshots(),
                  builder: (ctx2, rutaSnap) {
                    if (rutaSnap.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());
                    if (rutaSnap.hasError)
                      return Center(child: Text('Error: ${rutaSnap.error}'));

                    final docs = rutaSnap.data?.docs ?? [];
                    // 4) filtrado AND sobre principal+secundarias
                    final filtradas = docs.where((doc) {
                      final d      = doc.data() as Map<String, dynamic>;
                      final title  = (d['title'] ?? '').toString().toLowerCase();
                      final query  = _searchController.text.toLowerCase();
                      if (query.isNotEmpty && !title.contains(query)) return false;

                      // si no hay filtro, pasamos todo
                      if (_categoriasSeleccionadas.isEmpty) return true;

                      // categorías principales
                      final mainMap = (d['category'] as Map<String, dynamic>?) ?? {};
                      // secundarias
                      final secList = (d['secondary_categories'] as List<dynamic>?)
                          ?.map((e) => (e as Map<String,dynamic>).keys.first)
                          .toList() ?? [];

                      // **AND** lógico: cada catId seleccionada debe estar en mainMap.keys ∪ secList
                      return _categoriasSeleccionadas.every((catId) =>
                      mainMap.keys.contains(catId) || secList.contains(catId)
                      );
                    }).toList();

                    if (filtradas.isEmpty) {
                      return const Center(child: Text('No hay rutinas que coincidan.'));
                    }

                    return ListView.builder(
                      itemCount: filtradas.length,
                      itemBuilder: (_, i) {
                        final doc = filtradas[i];
                        final d   = doc.data() as Map<String, dynamic>;

                        // mostramos label y valor, no id
                        final mainMap = (d['category'] as Map<String, dynamic>?) ?? {};
                        final secList = (d['secondary_categories'] as List<dynamic>?)
                            ?.map((e) => e as Map<String,dynamic>)
                            .toList() ?? [];

                        return ListTile(
                          title: Text(
                            d['title'] ?? 'Sin título',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (mainMap.isNotEmpty)
                                Wrap(
                                  spacing: 6, runSpacing: 6,
                                  children: mainMap.entries.map((entry) {
                                    final label = _categoryLabels[entry.key] ?? entry.key;
                                    return Chip(
                                      label: Text('$label: ${entry.value}'),
                                      backgroundColor: Colors.purple.withOpacity(0.1),
                                      labelStyle: const TextStyle(color: Colors.purple),
                                    );
                                  }).toList(),
                                ),
                              if (secList.isNotEmpty)
                                Wrap(
                                  spacing: 6, runSpacing: 6,
                                  children: secList.map((m) {
                                    final key   = m.keys.first;
                                    final val   = m.values.first;
                                    final label = _categoryLabels[key] ?? key;
                                    return Chip(
                                      label: Text('$label: $val'),
                                      backgroundColor: Colors.purple.withOpacity(0.05),
                                      side: BorderSide(color: Colors.purple.withOpacity(0.3)),
                                      labelStyle:
                                      TextStyle(color: Colors.purple.withOpacity(0.8)),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RoutineDetailsPage(
                                  rutinaRef: doc.reference,
                                  rutinaData: d,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

