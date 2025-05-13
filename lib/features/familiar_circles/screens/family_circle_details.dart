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
  Set<String> _selectedConcerns = {};
  double _careExperience = 0;
  String? _supportLevel;
  double _careHours = 0;
  Set<String> _likedActivities = {};

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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.isCreating ? 'Crear círculo' : 'Unirse a círculo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              title: const Text('❤️ Es parte de mi familia'),
              //('Dar prioridad a tags que no sean de cuidado directo como comunicación y actividades'),
              value: 'familiar',
              groupValue: _selectedRole,
              onChanged: (value) => setState(() => _selectedRole = value),
            ),
            RadioListTile<String>(
              title: const Text('🙋 Soy quien le cuida principalmente'),
              //('Dar prioridad a formación esencial para cuidadores'),
              value: 'cuidador',
              groupValue: _selectedRole,
              onChanged: (value) => setState(() => _selectedRole = value),
            ),
            RadioListTile<String>(
              title: const Text('🤝 Le acompaño de forma puntual o compartida'),
              //('Dar prioridad a tags de actividades'),
              value: 'acompañante',
              groupValue: _selectedRole,
              onChanged: (value) => setState(() => _selectedRole = value),
            ),
            RadioListTile<String>(
              title: const Text('❓ Prefiero no decirlo o no estoy seguro/a'),
              value: 'no_seguro',
              groupValue: _selectedRole,
              onChanged: (value) => setState(() => _selectedRole = value),
            ),

            const Text('¿Qué te preocupa? (respuestas placeholder)'),
            Wrap(
              spacing: 8.0,
              children: [
                'Que se desoriente',
                'Que se sienta solo/a',
                'Que olvide medicación',
                'Comunicación difícil',
              ].map((tag) {
                return ChoiceChip(
                  label: Text(tag),
                  selected: _selectedConcerns.contains(tag),
                  onSelected: (selected) {
                    setState(() {
                      selected ? _selectedConcerns.add(tag) : _selectedConcerns.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),

            const Text('¿Tienes experiencia previa cuidando?'),
            Slider(
              value: _careExperience,
              min: 0,
              max: 1,
              divisions: 1,
              label: _careExperience == 0 ? 'No, es la primera vez' : 'Sí, algo',
              onChanged: (value) => setState(() => _careExperience = value),
            ),

            const Text('¿Cuánto apoyo necesita la persona que cuidas?'),
            RadioListTile<String>(
              title: const Text('🟢 Bastante autónomo/a'),
              subtitle: const Text('Hace muchas cosas solo/a, aunque olvida detalles.'),
              value: 'autonomo',
              groupValue: _supportLevel,
              onChanged: (value) => setState(() => _supportLevel = value),
            ),
            RadioListTile<String>(
              title: const Text('🟡 Ayuda en algunas tareas'),
              subtitle: const Text('A veces se desorienta o necesita guía.'),
              value: 'parcial',
              groupValue: _supportLevel,
              onChanged: (value) => setState(() => _supportLevel = value),
            ),
            RadioListTile<String>(
              title: const Text('🔴 Depende mucho de mí'),
              subtitle: const Text('Olvida rutinas básicas y se frustra si está solo/a.'),
              value: 'dependiente',
              groupValue: _supportLevel,
              onChanged: (value) => setState(() => _supportLevel = value),
            ),

            const Text('¿Cuánto tiempo dedicas a cuidar? (h/día)'),
            Slider(
              value: _careHours,
              min: 0,
              max: 24,
              divisions: 24,
              label: '${_careHours.round()}h',
              onChanged: (value) => setState(() => _careHours = value),
            ),

            const Text('¿Qué le gusta hacer a tu familiar?'),
            Wrap(
              spacing: 8.0,
              children: [
                'Pasear',
                'Escuchar música',
                'Leer',
                'Juegos de memoria',
                'Cocinar',
              ].map((activity) {
                return FilterChip(
                  label: Text(activity),
                  selected: _likedActivities.contains(activity),
                  onSelected: (selected) {
                    setState(() {
                      selected ? _likedActivities.add(activity) : _likedActivities.remove(activity);
                    });
                  },
                );
              }).toList(),
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
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
