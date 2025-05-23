import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';

class SettingsItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool hideArrow;

  const SettingsItem({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.hideArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: icon == null
        ? null
        : FaIcon(icon, size: 20, color: AppColors.neutral),
      trailing: hideArrow
        ? null
        : FaIcon(FontAwesomeIcons.angleRight, size: 16, color: AppColors.neutral),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      visualDensity: const VisualDensity(vertical: -3),
    );
  }
}
