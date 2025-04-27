import 'package:flutter/material.dart';
import 'package:lopako_app_lis/generated/l10n.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import 'edit_profile_screen.dart';
import 'edit_routines_screen.dart';

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
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(localizations.editProfile),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.family_restroom),
              title: Text(localizations.editRoutines),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditRoutinesScreen(context: context)),
                );
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: authController.signOut,
              child: Text(localizations.logout),
            ),
          ],
        ),
      ),
    );
  }
}
