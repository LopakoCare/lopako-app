import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class EditProfileController extends ChangeNotifier {
  String? name;
  int? age;
  String? password;
  bool loading = false;
  final BuildContext context;

  EditProfileController(this.context);

  Future<void> loadUserData() async {
    loading = true;
    notifyListeners();
    final user = await SettingsService(context).getUserProfile();
    name = user['name'] as String?;
    age = user['age'] as int?;
    loading = false;
    notifyListeners();
  }

  Future<String?> saveChanges() async {
    loading = true;
    notifyListeners();
    final result = await SettingsService(context).updateUserProfile(
      name: name,
      age: age,
      password: password,
    );
    loading = false;
    notifyListeners();
    return result;
  }
}
