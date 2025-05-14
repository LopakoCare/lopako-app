import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/services/family_circles_service.dart';
import 'package:lopako_app_lis/core/services/service_manager.dart';
import 'package:lopako_app_lis/features/family_circles/widgets/question_card_widget.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class CreateFamilyCircleScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const CreateFamilyCircleScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  _CreateFamilyCircleScreenState createState() => _CreateFamilyCircleScreenState();
}

class _CreateFamilyCircleScreenState extends State<CreateFamilyCircleScreen> {
  // Aquí guardamos la opción seleccionada para cada pregunta
  final Map<String, String> _answers = {};

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    final familyCirclesService = ServiceManager.instance.getService<FamilyCirclesService>('familyCircles');
    final questions = familyCirclesService.initialQuestionnaire;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.createFamilyCircle),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.familyOf,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 4),
              TextField(
                decoration: InputDecoration(
                  labelText: localizations.patientName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Generamos una QuestionCard por cada pregunta
              ...questions.map((question) {
                final qId = question['id'] as String;
                return QuestionCard(
                  question: question,
                  selectedOptionId: _answers[qId],
                  onSelected: (optionId) {
                    setState(() {
                      _answers[qId] = optionId;
                    });
                  },
                );
              }).toList(),

              const SizedBox(height: 16),
              // (Opcional) Mostrar debug de respuestas
              Text('Respuestas: $_answers'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              // Aquí _answers contiene el mapa completo de idPregunta → idOpción
              print('Final answers: $_answers');
              widget.onComplete();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: Text(localizations.createCircle),
          ),
        ),
      ),
    );
  }
}
