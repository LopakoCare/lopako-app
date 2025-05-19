import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lopako_app_lis/features/routines/controllers/routines_controller.dart';
import 'package:lopako_app_lis/features/routines/screens/routine_details_page.dart';

class RoutinesPage extends StatefulWidget {
  final RoutinesController controller;

  const RoutinesPage({Key? key, required this.controller}) : super(key: key);

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> _categoriasSeleccionadas = {};
  List<Map<String, dynamic>> _rutinas = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadAllRoutines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllRoutines() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final rutinas = await widget.controller.obtenerTodasLasRutinas();
      setState(() {
        _rutinas = rutinas;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar rutinas: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {}); // Solo para forzar rebuild
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();

    final filteredRutinas = _rutinas.where((data) {
      final title = (data['title'] ?? '').toString().toLowerCase();
      if (query.isNotEmpty && !title.contains(query)) {
        return false;
      }
      final categorias = data['categories'] as Map<String, dynamic>?;
      if (_categoriasSeleccionadas.isEmpty) {
        return true;
      }
      if (categorias == null) return false;
      return _categoriasSeleccionadas.every((cat) => categorias.keys.contains(cat));
    }).toList();

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : filteredRutinas.isEmpty
          ? const Center(child: Text('No hay rutinas que coincidan.'))
          : ListView.builder(
        itemCount: filteredRutinas.length,
        itemBuilder: (context, index) {
          final rutinaData = filteredRutinas[index];
          final rutinaRef = rutinaData['__ref__'] as DocumentReference;
          final categorias = rutinaData['categories'] as Map<String, dynamic>? ?? {};

          return ListTile(
            title: Text(rutinaData['title'] ?? 'Sin título', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: categorias.isNotEmpty
                ? Wrap(
              spacing: 6,
              runSpacing: 6,
              children: categorias.entries.map((entry) {
                return Chip(label: Text('${entry.key} ${entry.value}'));
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
                    controller: widget.controller,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
