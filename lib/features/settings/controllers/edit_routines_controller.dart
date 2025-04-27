import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class EditRoutinesController extends ChangeNotifier {
  List<String> routines = [];
  bool loading = false;
  final BuildContext context;

  EditRoutinesController(this.context);

  Future<void> loadRoutines() async {
    loading = true;
    notifyListeners();
    routines = await SettingsService(context).getUserRoutines();
    loading = false;
    notifyListeners();
  }

  void updateRoutine(int index, String value) {
    routines[index] = value;
    notifyListeners();
  }

  void addRoutine() {
    routines.add('');
    notifyListeners();
  }

  void removeRoutine(int index) {
    routines.removeAt(index);
    notifyListeners();
  }

  Future<String?> saveRoutines() async {
    loading = true;
    notifyListeners();
    final result = await SettingsService(context).updateUserRoutines(routines);
    loading = false;
    notifyListeners();
    return result;
  }
}
