import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'package:lopako_app_lis/features/family_circles/screens/share_family_circle_pin_screen.dart';
import 'package:lopako_app_lis/features/family_circles/widgets/new_family_circle_widget.dart';
import 'package:lopako_app_lis/features/navigation/screens/main_tab_screen.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

import '../../family_circles/screens/create_family_circle_screen.dart';

class NewFamilyCircleScreen extends StatelessWidget {
  final VoidCallback onSkip;
  final void Function(FamilyCircle familyCircle) onComplete;

  const NewFamilyCircleScreen({super.key, required this.onSkip, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 120,
            ),
            const SizedBox(height: 48),
            Text(localizations.firstFamilyCircleTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(localizations.firstFamilyCircleSubtitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.neutral,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            NewFamilyCircleWidget(
              onCreatePressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateFamilyCircleScreen(
                      onComplete: (familyCircle) async {
                        await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ShareFamilyCirclePinScreen(
                              familyCircle: familyCircle,
                              onComplete: () {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                            ),
                          ),
                        );
                        onComplete(familyCircle);
                      },
                    )
                  )
                );
              },
              onJoinPressed: () {
                // TODO: Implementa unirse a círculo
              },
            ),
            const SizedBox(height: 16),
            // Skip link button redirect to main screen
            TextButton(
              onPressed: onSkip,
              child: Text(localizations.skip),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              )
            ),
            const SizedBox(height: 64),
          ]
        )
      )
    );
  }
}

