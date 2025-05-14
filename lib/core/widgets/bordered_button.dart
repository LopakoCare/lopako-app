import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';

class OutlinedButton extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback? onPressed;

  const OutlinedButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          side: BorderSide(color: AppColors.neutral[300]!, width: 2.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
