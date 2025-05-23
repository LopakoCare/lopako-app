import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/family_circles/controllers/family_circles_controller.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'package:lopako_app_lis/features/routines/models/routine_model.dart';
import 'package:lopako_app_lis/features/routines/widgets/iddle_bubbles_widget.dart';
import 'package:lopako_app_lis/features/routines/widgets/routine_bubble_widget.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class HomeRoutinesBubbles extends StatelessWidget {
  final FamilyCircle? familyCircle;
  final void Function(FamilyCircle onStartRoutine)? onStartRoutine;

  const HomeRoutinesBubbles({
    super.key,
    required this.familyCircle,
    this.onStartRoutine,
  });


  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    final FamilyCirclesController familyCirclesController = FamilyCirclesController();

    void startRoutine(Routine routine) async {
      await familyCirclesController.startRoutine(routine);
      if (onStartRoutine != null) {
        onStartRoutine!(familyCircle!);
      }
    }

    if (familyCircle == null) {
      return Text(
        localizations.noFamilyCirclesYet,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.neutral,
        ),
        textAlign: TextAlign.center,
      );
    }

    if (familyCircle!.currentRoutine != null) {
      final routine = familyCircle!.currentRoutine!;
      return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoutineBubble(
              routine: routine,
              shadow: true,
              size: 140,
              hideTitle: true,
            ),
          ]
      );
    }

    if (familyCircle!.routines.isEmpty) {
      return Text(
        localizations.noRoutinesYet,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.neutral,
        ),
        textAlign: TextAlign.center,
      );
    }

    return SizedBox.expand(
      child: IdleRoutineBubbles(
        routines: familyCircle!.routines,
        onTap: startRoutine,
      ),
    );

  }
}
