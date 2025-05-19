import 'package:flutter/material.dart';
import 'package:lopako_app_lis/features/routines/models/routine_category_model.dart';
import 'package:lopako_app_lis/features/routines/widgets/routine_category_chip_widget.dart';

class RoutineCategoryScore extends StatelessWidget {
  final RoutineCategory category;
  final bool selected;
  final int bars = 5;

  const RoutineCategoryScore({
    super.key,
    required this.category,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoutineCategoryChip(
          label: category.label,
          color: category.color,
          type: RoutineCategoryChipType.clean,
          selected: selected,
          shadow: selected,
          width: 120,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (int i = 0; i < bars; i++)
                ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 11,
                      decoration: BoxDecoration(
                        color: category.score is int && (category.score as int) / (100 / bars) > i
                          ? category.color
                          : Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }
}
