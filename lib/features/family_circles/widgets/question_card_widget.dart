import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/core/widgets/icon_3d.dart';

class QuestionCard extends StatelessWidget {
  final Map<String, dynamic> question;
  final String? selectedOptionId;
  final void Function(String optionId) onSelected;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.selectedOptionId,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final options = question['options'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          question['description'] as String,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        // Render each option as an OutlinedButton
        ...options.map((opt) {
          final optionId = opt['id'] as String;
          final iconId = opt['icon'] as String?;
          final desc = opt['description'] as String?;
          final label = opt['label'] as String;
          final hasIcon = iconId != null && iconId.isNotEmpty;
          final hasDesc = desc != null && desc.isNotEmpty;
          final isSelected = optionId == selectedOptionId;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                alignment: hasIcon || hasDesc
                    ? Alignment.centerLeft
                    : Alignment.center,
                backgroundColor: isSelected
                    ? AppColors.primary[50]
                    : Colors.white,
              ),
              onPressed: () => onSelected(optionId),
              child: hasIcon || hasDesc
                  ? Row(
                children: [
                  if (hasIcon) ...[
                    Icon3d(iconId, size: 64),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 18,
                            color: isSelected ? AppColors.primary : Colors.black,
                          ),
                        ),
                        if (hasDesc) ...[
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: isSelected
                                  ? AppColors.neutral[600]
                                  : AppColors.neutral,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              )
                  : Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? AppColors.primary : Colors.black,
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 24),
      ],
    );
  }
}
