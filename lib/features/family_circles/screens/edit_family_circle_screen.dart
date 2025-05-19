import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/core/services/family_circles_service.dart';
import 'package:lopako_app_lis/core/services/service_manager.dart';
import 'package:lopako_app_lis/features/auth/models/user_model.dart';
import 'package:lopako_app_lis/features/family_circles/controllers/family_circles_controller.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'package:lopako_app_lis/features/family_circles/screens/share_family_circle_pin_screen.dart';
import 'package:lopako_app_lis/features/family_circles/widgets/question_card_widget.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class EditFamilyCircleScreen extends StatefulWidget {
  final FamilyCircle familyCircle;
  final void Function(FamilyCircle familyCircle)? onSave;

  const EditFamilyCircleScreen({super.key, required this.familyCircle, this.onSave});

  @override
  _EditFamilyCircleScreenState createState() => _EditFamilyCircleScreenState();
}

class _EditFamilyCircleScreenState extends State<EditFamilyCircleScreen> {

  final FamilyCirclesController _familyCirclesController = FamilyCirclesController();

  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();

  bool _isSaving = false;

  List<User> members = [];

  bool _hasChanged() {
    return _patientNameController.text != widget.familyCircle.patientName ||
        members != widget.familyCircle.members;
  }

  @override
  void initState() {
    super.initState();
    _patientNameController.text = widget.familyCircle.patientName;
    members = widget.familyCircle.members;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.editFamilyCircle),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.trash),
            onPressed: () {
              // TODO: Implement delete family circle
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 24, right: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _formKey.currentState?.validate() == true && !_isSaving && _hasChanged()
                ? () async {
              setState(() {
                _isSaving = true;
              });
              FamilyCircle circle = widget.familyCircle.copyWith(
                patientName: _patientNameController.text,
                members: members,
              );
              try {
                circle = await _familyCirclesController.edit(circle);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    margin: EdgeInsets.all(8),
                  ),
                );
                setState(() {
                  _isSaving = false;
                });
                return;
              }
              setState(() {
                _isSaving = false;
              });
              if (widget.onSave != null) {
                widget.onSave!(circle);
              }
            } : null,
            child: Text(localizations.save),
          ),
        ),
      ),
    );
  }
}
