import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/intl_localizations.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authController = Provider.of<AuthController>(context);
    final state = authController.state;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Hello world!'),
            const Spacer(),
            ElevatedButton(
              onPressed: authController.signOut,
              child: Text(localizations.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger
              )
            ),
          ],
        ),
      ),
    );
  }
}
