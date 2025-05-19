import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/auth/screens/auth_screen.dart';
import 'package:lopako_app_lis/generated/l10n.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import 'edit_profile_screen.dart';
import 'reminder_screen.dart';

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
      appBar: AppBar(title: Text(localizations.settings)),
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
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('Recordatorio diario'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReminderScreen(),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await authController.logout();
                if (!mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(localizations.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
