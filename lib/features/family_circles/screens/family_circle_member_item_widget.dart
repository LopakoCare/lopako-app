import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/auth/models/user_model.dart';

class FamilyCircleMemberItem extends StatelessWidget {
  final AppUser member;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool isAdmin;

  const FamilyCircleMemberItem({
    super.key,
    required this.member,
    this.onTap,
    this.onRemove,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final firstInitial = member.name.trim().split(' ').first[0].toUpperCase();
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary[800],
        radius: 18,
        child: Text(
          firstInitial,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRemove != null)
            IconButton(
              icon: FaIcon(FontAwesomeIcons.trash, size: 16, color: AppColors.red),
              onPressed: onRemove,
            ),
          if (isAdmin)
            IgnorePointer(
              child: IconButton(
                icon: FaIcon(FontAwesomeIcons.crown, size: 16, color: AppColors.yellow),
                onPressed: () {},
              ),
            ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(member.name),
      subtitle: Text(member.email),
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 12,
        color: AppColors.neutral,
        height: 1.2,
      ),
      visualDensity: const VisualDensity(vertical: -4),
    );
  }
}
