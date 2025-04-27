import 'package:flutter/material.dart';
import 'package:lopako_app_lis/generated/l10n.dart';
import '../controllers/edit_routines_controller.dart';

class EditRoutinesScreen extends StatefulWidget {
  final BuildContext context;

  const EditRoutinesScreen({Key? key, required this.context}) : super(key: key);

  @override
  State<EditRoutinesScreen> createState() => _EditRoutinesScreenState();
}

class _EditRoutinesScreenState extends State<EditRoutinesScreen> {
  late final _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditRoutinesController(widget.context);
    _controller.loadRoutines();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    
    return Scaffold(
      appBar: AppBar(title: Text(localizations.editRoutines)),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: _controller.routines.length,
            itemBuilder: (context, i) {
              final routine = _controller.routines[i];
              return ListTile(
                title: TextFormField(
                  initialValue: routine,
                  onChanged: (v) => _controller.updateRoutine(i, v),
                  decoration: InputDecoration(labelText: localizations.routine),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: localizations.delete,
                  onPressed: () => _controller.removeRoutine(i),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.addRoutine,
        child: const Icon(Icons.add),
        tooltip: localizations.addRoutine,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            final result = await _controller.saveRoutines();
            if (result == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(localizations.routinesUpdated))
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
            }
          },
          child: Text(localizations.saveChanges),
        ),
      ),
    );
  }
}
