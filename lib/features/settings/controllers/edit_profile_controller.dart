import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class EditProfileController extends ChangeNotifier {
  String? name;
  String? email;
  int? age;
  String? password;
  String? familyId;  // Añadir campo family_id
  bool loading = false;
  final BuildContext context;

  EditProfileController(this.context);

  Future<void> loadUserData() async {
    loading = true;
    notifyListeners();
    final user = await SettingsService(context).getUserProfile();
    name = user['name'] as String?;
    email = user['email'] as String?;
    age = user['age'] as int?;
    familyId = user['family_id'] as String?;  // Cargar family_id
    loading = false;
    notifyListeners();
  }

  Future<String?> saveChanges() async {
    loading = true;
    notifyListeners();

    // Validar family_id si se ha proporcionado uno
    if (familyId != null && familyId!.isNotEmpty) {
      final exists = await checkFamilyIdExists(familyId!);
      if (!exists) {
        loading = false;
        notifyListeners();
        return 'El ID de familia no existe';
      }
    }

    final result = await SettingsService(context).updateUserProfile(
      name: name,
      age: age,
      password: password,
      familyId: familyId,
    );
    loading = false;
    notifyListeners();
    return result;
  }

  // Método para verificar si existe el family_id
  Future<bool> checkFamilyIdExists(String id) async {
    final service = SettingsService(context);
    return await service.checkFamilyIdExists(id);
  }
}
