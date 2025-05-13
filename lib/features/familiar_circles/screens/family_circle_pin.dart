import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JoinFamilyCodeScreen extends StatefulWidget {
  final int userAge;
  const JoinFamilyCodeScreen({super.key, required this.userAge});

  @override
  State<JoinFamilyCodeScreen> createState() => _JoinFamilyCodeScreenState();
}

class _JoinFamilyCodeScreenState extends State<JoinFamilyCodeScreen> {
  final _pinController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _onNextPressed() async {
    final pin = _pinController.text.trim();

    if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un código válido de 6 dígitos')),
      );
      return;
    }

    try {
      // Verificar si el círculo familiar con ese family_id existe
      final query = await _firestore
          .collection('familiar_circle_routines')
          .where('family_id', isEqualTo: pin)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('El código ingresado no existe.');
      }

      final doc = query.docs.first;
      final patientName = doc['patientName'] ?? 'Paciente';

      if (!mounted) return;

      // Navegar a la pantalla de detalles
      Navigator.pushNamed(
        context,
        '/family/details',
        arguments: {
          'isCreating': false,
          'patientName': patientName,
          'familyId': pin,
          'userAge': widget.userAge
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unirse a un círculo')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Introduce el código de 6 dígitos:'),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: 123456',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onNextPressed,
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}
