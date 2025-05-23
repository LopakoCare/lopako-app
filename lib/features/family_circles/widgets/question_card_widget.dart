import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/core/widgets/icon_3d.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class QuestionCard extends StatelessWidget {
  final Map<String, dynamic> question;
  final dynamic selectedValue;
  final bool showError;
  final void Function(dynamic) onChange;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.selectedValue,
    required this.showError,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    final options = question['options'] as List<dynamic>;
    final multiple = question['multiple'] as bool? ?? false;
    final required = question['required'] as bool? ?? false;
    final description = question['description'] as String;

    bool hasAnswer() {
      if (multiple) return (selectedValue as List<String>?)?.isNotEmpty ?? false;
      return selectedValue != null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
            ),
            children: [
              if (required)
                TextSpan(text: ' '),
              TextSpan(text: description),
              if (required)
                TextSpan(
                  text: ' *',
                  style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),
        ...options.map((opt) {
          final value = opt['value'] as String;
          final iconId = opt['icon'] as String?;
          final desc = opt['description'] as String?;
          final label = opt['label'] as String;

          bool selected;
          if (multiple) selected = (selectedValue as List<String>?)?.contains(value) ?? false;
          else selected = selectedValue == value;

          final hasExtra = (iconId?.isNotEmpty == true) || (desc?.isNotEmpty == true);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: selected ? Theme.of(context).primaryColor : Colors.grey, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                alignment: hasExtra
                    ? Alignment.centerLeft
                    : Alignment.center,
                backgroundColor: selected ? Theme.of(context).primaryColorLight : Colors.white,
              ),
              onPressed: () {
                if (multiple) {
                  final list = List<String>.from(selectedValue as List<String>? ?? []);
                  if (list.contains(value)) list.remove(value);
                  else list.add(value);
                  onChange(list);
                } else {
                  if (selected && !required) onChange(null);
                  else onChange(value);
                }
              },
              child: hasExtra
                ? Row(children: [
                  if (iconId?.isNotEmpty == true) ...[Icon3d(iconId!, size: 64), const SizedBox(width: 12)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 18,
                            color: selected
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                          )
                        ),
                        if (desc?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(desc!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400,
                              color: selected ? Colors.black54 : Colors.grey[700])),
                        ],
                      ],
                    ),
                  ),
                ])
                : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: selected
                      ? Theme.of(context).primaryColor
                      : Colors.black,
                  ),
                ),
            ),
          );
        }).toList(),
        if (showError && multiple && required && !hasAnswer()) ...[
          Text(
            localizations.selectAtLeastOneOption,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
          const SizedBox(height: 24),
        ] else const SizedBox(height: 24),
      ],
    );
  }
}
