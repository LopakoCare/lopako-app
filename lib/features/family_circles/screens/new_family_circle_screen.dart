import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'package:lopako_app_lis/features/family_circles/screens/create_family_circle_screen.dart';
import 'package:lopako_app_lis/features/family_circles/screens/edit_family_circle_screen.dart';
import 'package:lopako_app_lis/features/family_circles/widgets/new_family_circle_widget.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class NewFamilyCircleScreen extends StatefulWidget {
  final void Function(FamilyCircle familyCircle)? onComplete;
  const NewFamilyCircleScreen({super.key, this.onComplete});

  @override
  _NewFamilyCircleScreenState createState() => _NewFamilyCircleScreenState();
}

class _NewFamilyCircleScreenState extends State<NewFamilyCircleScreen> {

  @override
  void initState() {
    super.initState();
  }

  void onComplete(familyCircle) async {
    Navigator.pop(context);
    await Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) =>
        EditFamilyCircleScreen(
          currentUser: familyCircle.members.last,
          familyCircle: familyCircle,
          onSave: (newCircle) {
            familyCircle = newCircle;
            Navigator.pop(context);
          },
        ),
      ),
    );
    if (widget.onComplete != null) {
      widget.onComplete!(familyCircle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.addFamilyCircle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(localizations.addOtherFamilyCircle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(localizations.addFamilyCircleDecision,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.neutral,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            NewFamilyCircleWidget(
              onCreatePressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateFamilyCircleScreen(
                    onComplete: onComplete,
                  )),
                );
              },
              onJoinPressed: () {
                // TODO: Implementa unirse a círculo
              },
            ),
            const SizedBox(height: 64),
          ]
        )
      )
    );
  }
}

