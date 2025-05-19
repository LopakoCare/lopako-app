import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';

class ProfileOptionItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const ProfileOptionItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = title.trim().split(' ').map((s) => s[0]).take(2).join();
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Color(0xFF8B5CF6),
        radius: 32,
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      title: Text(title),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary[900],
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      subtitleTextStyle: TextStyle(
        fontSize: 14,
        color: AppColors.neutral,
      ),
      trailing: FaIcon(FontAwesomeIcons.angleRight, size: 16, color: AppColors.neutral),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
