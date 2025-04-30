import 'package:flutter/material.dart';
import 'package:lopako_app_lis/generated/l10n.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(localizations.editProfile),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                },
              ),
            ),
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
