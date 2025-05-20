import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/auth/models/user_model.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class FamilyCircleItem extends StatelessWidget {
  final FamilyCircle familyCircle;
  final VoidCallback? onTap;

  const FamilyCircleItem({
    super.key,
    required this.familyCircle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FamilyCircleMembers(
            members: familyCircle.members,
          ),
          const SizedBox(width: 16),
          FaIcon(FontAwesomeIcons.angleRight, size: 16, color: AppColors.neutral),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(localizations.familyOfPatientName(familyCircle.patientName)),
      visualDensity: const VisualDensity(vertical: -3),
    );
  }
}

class FamilyCircleMembers extends StatelessWidget {
  final List<AppUser> members;
  final double radius;
  final double overlap;    // cuánto se solapan

  const FamilyCircleMembers({
    super.key,
    required this.members,
    this.radius = 18.0,
    this.overlap = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    // límite de avatares a mostrar antes de "+N"
    const int maxAvatars = 5;
    final displayMembers = members.take(maxAvatars).toList();
    final extraCount = members.length - displayMembers.length;

    // ancho total necesario para el Stack
    final totalWidth = radius * 2 + (displayMembers.length - 1) * (radius * 2 - overlap)
        + (extraCount > 0 ? (radius * 2 - overlap) : 0);

    return SizedBox(
      width: totalWidth,
      height: radius * 2,
      child: Stack(
        children: [
          for (var i = 0; i < displayMembers.length; i++)
            Positioned(
              left: (radius * 2 - overlap) * i,
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: radius - 2,
                  backgroundColor: AppColors.primary[800],
                  child: Text(
                    displayMembers[i].name.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: radius * 0.8),
                  ),
                ),
              ),
            ),
          if (extraCount > 0)
            Positioned(
              left: displayMembers.length * (radius * 2 - overlap),
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: radius - 2,
                  backgroundColor: AppColors.neutral[200],
                  child: Text(
                    '+$extraCount',
                    style: TextStyle(
                      color: AppColors.primary[900],
                      fontWeight: FontWeight.bold,
                      fontSize: radius * 0.8,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
