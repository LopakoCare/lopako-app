import 'package:flutter/material.dart';

class FamilyCircleChoiceScreen extends StatefulWidget {
  final int userAge;
  const FamilyCircleChoiceScreen({super.key, required this.userAge});

  @override
  State<FamilyCircleChoiceScreen> createState() => _FamilyCircleChoiceScreenState();
}

class _FamilyCircleChoiceScreenState extends State<FamilyCircleChoiceScreen> {
  final Color borderColor = Colors.purple;

  void _goToCreate() {
    Navigator.pushNamed(
      context,
      '/family/details',
      arguments: {
        'isCreating': true,
        'userAge': widget.userAge,
      },
    );
  }


  void _goToJoin() {
    Navigator.pushNamed(
      context,
      '/family/join',
      arguments: {
        'userAge': widget.userAge, //
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Círculo Familiar')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: _goToCreate,
              style: OutlinedButton.styleFrom(
                foregroundColor: borderColor,
                side: BorderSide(color: borderColor),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Crear círculo familiar'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _goToJoin,
              style: OutlinedButton.styleFrom(
                foregroundColor: borderColor,
                side: BorderSide(color: borderColor),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Unirse a un círculo familiar'),
            ),
          ],
        ),
      ),
    );
  }
}
