import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lopako_app_lis/features/familiar_circles/controllers/familiar_circles_controllers.dart';

class FamilyCircleDetailsScreen extends StatefulWidget {
  final bool isCreating;
  final String? patientName;
  final String? familyId;
  final int userAge;

  const FamilyCircleDetailsScreen({
    super.key,
    required this.isCreating,
    this.patientName,
    this.familyId,
    required this.userAge
  });

  @override
  State<FamilyCircleDetailsScreen> createState() => _FamilyCircleDetailsScreenState();
}

class _FamilyCircleDetailsScreenState extends State<FamilyCircleDetailsScreen> {
  final _nameController = TextEditingController();
  String? _selectedRole;

  final _controller = FamiliarCircleController();

  @override
  void initState() {
    super.initState();
    //Si viene del flujo "unirse", rellenamos el nombre automáticamente
    if (!widget.isCreating && widget.patientName != null) {
      _nameController.text = widget.patientName!;
    }
  }

  Future<void> _onSubmit() async {
    print('[DEBUG] familyId recibido: ${widget.familyId}');

    //Validación de campos
    if (_nameController.text.trim().isEmpty || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    //Obtenemos el usuario actual
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay usuario autenticado')),
      );
      return;
    }

    try {
      final name = user.displayName ?? 'Usuario';

      if (widget.isCreating) { // Caso creación de círculo familiar

        await _controller.createFamilyCircle(
          patientName: _nameController.text.trim(),
          bond: _selectedRole!,
          userName: name,
          userAge: widget.userAge,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Círculo creado con éxito')),
        );
      } else { //Caso unión a un círculo familiar

        if (widget.familyId == null) {
          throw Exception('Falta el familyId para unirse');
        }

        await _controller.joinFamilyCircle(
          familyId: widget.familyId!,
          bond: _selectedRole!,
          userName: name,
          userAge: widget.userAge,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Te has unido al círculo')),
        );
      }

      //Navegar a pantalla principal
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      //Captura de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryText = widget.isCreating ? 'Crear círculo' : 'Unirse al círculo';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCreating ? 'Crear círculo' : 'Unirse a círculo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // ✅ Mostrar el campo del paciente siempre, solo editable si estás creando
            const Text('Nombre del paciente:'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              readOnly: !widget.isCreating, // solo editable si estás creando
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: Juan Pérez',
              ),
            ),
            const SizedBox(height: 24),

            const Text('¿Qué relación tienes con el paciente?'),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('Cuidador'),
              value: 'cuidador',
              groupValue: _selectedRole,
              onChanged: (value) => setState(() => _selectedRole = value),
            ),
            RadioListTile<String>(
              title: const Text('Familiar'),
              value: 'familiar',
              groupValue: _selectedRole,
              onChanged: (value) => setState(() => _selectedRole = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(primaryText),
            )
          ],
        ),
      ),
    );
  }
}
