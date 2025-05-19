import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/core/widgets/icon_3d.dart';
import 'package:lopako_app_lis/features/routines/models/routine_model.dart';
import 'package:lopako_app_lis/features/routines/widgets/routine_category_chip_widget.dart';

class RoutineCard extends StatelessWidget {
  final Routine routine;
  final ValueChanged<Routine>? onSelected;
  final maxSubcategories = 2;

  const RoutineCard({
    Key? key,
    required this.routine,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hiddenSubcategories = max(routine.subcategories.length - maxSubcategories, 0);
    final shownCategories = routine.subcategories.take(maxSubcategories).toList();
    return Card(
      color: routine.category.color[50],
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (onSelected != null) {
            onSelected!(routine);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                Positioned(
                  left: 72,
                  bottom: 4,
                  child: IgnorePointer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        RoutineCategoryChip(
                          label: routine.category.label,
                          color: routine.category.color,
                          selected: true,
                          shadow: true,
                        ),
                        ...shownCategories.map((subcategory) {
                          return Row(
                              children: [
                                const SizedBox(width: 4),
                                RoutineCategoryChip(
                                  label: subcategory.label,
                                  color: subcategory.color,
                                  type: RoutineCategoryChipType.clean,
                                ),
                              ]
                          );
                        }).toList(),
                        if (hiddenSubcategories > 0)
                          Row(
                            children: [
                              const SizedBox(width: 4),
                              RoutineCategoryChip(
                                label: '+$hiddenSubcategories',
                                color: AppColors.neutral,
                                type: RoutineCategoryChipType.clean,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Icon3d(routine.icon, size: 64),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(routine.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: routine.category.color[900],
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (onSelected != null)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, right: 8),
                            child: FaIcon(
                              FontAwesomeIcons.chevronRight,
                              size: 18,
                              color: AppColors.neutral[300],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
