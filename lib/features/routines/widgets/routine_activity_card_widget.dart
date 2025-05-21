import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/core/widgets/icon_3d.dart';
import 'package:lopako_app_lis/features/routines/models/routine_activity_model.dart';

class RoutineActivityCard extends StatelessWidget {
  final RoutineActivity activity;
  final ValueChanged<RoutineActivity>? onTap;
  final maxSubcategories = 2;

  const RoutineActivityCard({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final bool rippleEnabled = onTap != null;

    final card = Card(
      color: activity.color[50],
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!(activity);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon3d(activity.icon, size: 40),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(activity.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: activity.color[900],
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              if (onTap != null)
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
        ),
      ),
    );

    if (!rippleEnabled) {
      return Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: card,
      );
    }

    return card;
  }
}
