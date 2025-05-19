import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/core/services/family_circles_service.dart';
import 'package:lopako_app_lis/core/services/service_manager.dart';
import 'package:lopako_app_lis/features/family_circles/controllers/family_circles_controller.dart';
import 'package:lopako_app_lis/features/family_circles/screens/share_family_circle_pin_screen.dart';
import 'package:lopako_app_lis/features/family_circles/widgets/question_card_widget.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class CreateFamilyCircleScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const CreateFamilyCircleScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  _CreateFamilyCircleScreenState createState() => _CreateFamilyCircleScreenState();
}

class _CreateFamilyCircleScreenState extends State<CreateFamilyCircleScreen> {
  final Map<String, dynamic> _answers = {};
  bool _showValidationError = false;
  bool _isCreating = false;

  final _patientNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final FamilyCirclesController _familyCirclesController = FamilyCirclesController();

  @override
  void dispose() {
    _patientNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    final familyCirclesService = ServiceManager.instance.getService<FamilyCirclesService>('familyCircles');
    final questions = familyCirclesService.initialQuestionnaire;

    bool allRequiredAnswered = questions.every((q) {
      final id = q['id'] as String;
      final required = q['required'] as bool? ?? false;
      if (!required) return true;
      final multiple = q['multiple'] as bool? ?? false;
      final ans = _answers[id];
      if (multiple) return (ans as List<String>?)?.isNotEmpty ?? false;
      return ans != null;
    });

    return Scaffold(
      appBar: AppBar(title: Text(localizations.createFamilyCircle)),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 24, right: 16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localizations.familyOf, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _patientNameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.nameRequired;
                    }
                    return null;
                  },
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: localizations.patientName,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  textCapitalization: TextCapitalization.words,
                  onTapOutside: (event) {
                    if (_patientNameController.text.isNotEmpty) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                ),
                const SizedBox(height: 24),

                ...questions.map((q) {
                  final id = q['id'] as String;
                  return QuestionCard(
                    question: q,
                    selectedValue: _answers[id],
                    showError: _showValidationError,
                    onChange: (val) {
                      setState(() {
                        if (val == null || (val is List && val.isEmpty)) {
                          _answers.remove(id);
                        } else {
                          _answers[id] = val;
                        }
                        _showValidationError = true;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: allRequiredAnswered && _formKey.currentState?.validate() == true && !_isCreating
                ? () async {
              String pin;
              setState(() {
                _isCreating = true;
              });
              try {
                pin = await _familyCirclesController.create(
                  _patientNameController.text,
                  _answers,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    margin: EdgeInsets.all(8),
                  ),
                );
                setState(() {
                  _isCreating = false;
                });
                return;
              }
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ShareFamilyCirclePinScreen(
                    pin: pin,
                    onComplete: () {
                      widget.onComplete();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              );
              setState(() {
                _isCreating = false;
              });
            } : null,
            child: (allRequiredAnswered && _formKey.currentState?.validate() == true
              ? Text(localizations.createCircle)
              : Text(localizations.missingRequiredAnswers)),
          ),
        ),
      ),
    );
  }
}
