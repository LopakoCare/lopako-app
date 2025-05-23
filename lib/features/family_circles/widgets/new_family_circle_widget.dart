import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/core/widgets/icon_3d.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class NewFamilyCircleWidget extends StatelessWidget {
  final VoidCallback onCreatePressed;
  final VoidCallback onJoinPressed;

  const NewFamilyCircleWidget({
    Key? key,
    required this.onCreatePressed,
    required this.onJoinPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: onCreatePressed,
          child: Row(
            children: [
              Icon3d('rocket', size: 64),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(localizations.createCircle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        )),
                    Text(
                      localizations.createCircleDescription,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.neutral,
                      ),
                      softWrap: true,
                      maxLines: 2,
                    ),
                  ],
                ),
              )
            ]
          )
        ),
        SizedBox(height: 12),
        OutlinedButton(
          onPressed: onJoinPressed,
          child: Row(
            children: [
              Icon3d('target', size: 64),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(localizations.joinCircle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        )),
                    Text(
                      localizations.joinCircleDescription,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.neutral,
                      ),
                      softWrap: true,
                      maxLines: 2,
                    ),
                  ],
                ),
              )
            ]
          )
        ),
      ],
    );
  }
}
