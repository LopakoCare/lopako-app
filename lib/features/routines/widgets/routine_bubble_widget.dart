import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/core/widgets/icon_3d.dart';
import 'package:lopako_app_lis/features/routines/models/routine_model.dart';

class RoutineBubble extends StatelessWidget {
  final Routine routine;
  final double size;
  final bool shadow;
  final void Function(Routine)? onTap;
  final bool hideTitle;

  const RoutineBubble({
    super.key,
    required this.routine,
    this.size = 100,
    this.shadow = false,
    this.onTap,
    this.hideTitle = false,
  });

  @override
  Widget build(BuildContext context) {

    String bubbleAsset() {
      switch (routine.category.color) {
        case AppColors.yellow: return 'assets/bubbles/yellow.png';
        case AppColors.red: return 'assets/bubbles/red.png';
        case AppColors.pink: return 'assets/bubbles/pink.png';
        case AppColors.green: return 'assets/bubbles/green.png';
        case AppColors.blue: return 'assets/bubbles/blue.png';
        case AppColors.teal: return 'assets/bubbles/teal.png';
      }
      return 'assets/bubbles/yellow.png';
    }

    return GestureDetector(
      onTap: onTap != null ? () => onTap!(routine) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: shadow
            ? [
                BoxShadow(
                  color: routine.category.color,
                  blurRadius: 128,
                  spreadRadius: 10,
                ),
              ]
            : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -size * 0.05,
              left: -size * 0.05,
              right: -size * 0.05,
              bottom: -size * 0.05,
              child: Image.asset(
                bubbleAsset(),
                fit: BoxFit.contain,
              ),
            ),
            Center(
              child: Icon3d(routine.icon, size: size * 0.75),
            ),
            if (!hideTitle)
              Positioned(
                top: size + 8,
                left: -8,
                right: -8,
                child: Text(
                  routine.title,
                  style: TextStyle(
                    color: routine.category.color[700],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
