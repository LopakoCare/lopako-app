import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/family_circles/controllers/family_circles_controller.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'package:lopako_app_lis/features/routines/models/routine_activity_model.dart';
import 'package:lopako_app_lis/features/routines/widgets/routine_activity_card_widget.dart';
import 'package:lopako_app_lis/features/routines/widgets/routine_category_score_widget.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class RoutineActiveSheet extends StatefulWidget {
  final FamilyCircle familyCircle;
  final void Function(FamilyCircle familyCircle)? onComplete;
  const RoutineActiveSheet({super.key, required this.familyCircle, this.onComplete});

  @override
  _RoutineActiveSheetState createState() => _RoutineActiveSheetState();
}

class _RoutineActiveSheetState extends State<RoutineActiveSheet> {

  final FamilyCirclesController _familyCirclesController = FamilyCirclesController();

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    final routine = widget.familyCircle.currentRoutine!;
    final microlearningActivities =
    routine.activities
      .where((activity) => activity.type == RoutineActivityType.microlearning).toList();
    final practiceActivities =
    routine.activities
      .where((activity) => activity.type == RoutineActivityType.practice).toList();

    return SizedBox.expand(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      routine.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.solidClock,
                          size: 12,
                          color: AppColors.neutral,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          routine.duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral,
                          ),
                        ),
                        const SizedBox(width: 24),
                        FaIcon(
                          FontAwesomeIcons.solidCalendarDays,
                          size: 12,
                          color: AppColors.neutral,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          routine.schedule,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    routine.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (microlearningActivities.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      localizations.beforeStart,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    ...microlearningActivities.map(
                          (activity) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: RoutineActivityCard(activity: activity),
                      ),
                    ),
                  ],
                  if (practiceActivities.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      localizations.activities,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    ...practiceActivities.map(
                          (activity) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: RoutineActivityCard(activity: activity),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Card(
                    color: routine.category.color[50],
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          RoutineCategoryScore(
                            category: routine.category,
                            selected: true,
                          ),
                          ...routine.subcategories.map(
                                (subcategory) => Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: RoutineCategoryScore(
                                category: subcategory,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Center(
                    child: Text(
                      localizations.routineCategoriesScoresHelpText,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.neutral[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                await _familyCirclesController.finishFamilyCircleRoutine(widget.familyCircle);
                if (widget.onComplete != null) {
                  widget.onComplete!(widget.familyCircle);
                }
              },
              child: Text(localizations.finish),
            ),
          )
        ],
      )
    );
  }
}
