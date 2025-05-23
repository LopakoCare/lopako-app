import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class ShareFamilyCirclePinScreen extends StatefulWidget {
  final FamilyCircle familyCircle;
  final VoidCallback onComplete;

  const ShareFamilyCirclePinScreen({
    Key? key,
    required this.familyCircle,
    required this.onComplete,
  }) : super(key: key);

  @override
  _ShareFamilyCirclePinScreenState createState() => _ShareFamilyCirclePinScreenState();
}

class _ShareFamilyCirclePinScreenState extends State<ShareFamilyCirclePinScreen> {

  TextTheme get _textTheme => Theme.of(context).textTheme;

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.createFamilyCircle),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            localizations.familyCircleCreated,
            style: _textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.shareFamilyCirclePinDescription,
            style: _textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            widget.familyCircle.pin,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 8,
              fontFamily: 'Courier New',
            )
          ),
          const SizedBox(height: 64),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: widget.onComplete,
          child: Text(localizations.finish),
        ),
      ),
    );
  }
}

