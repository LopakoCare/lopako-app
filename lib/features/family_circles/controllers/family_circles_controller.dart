import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/services/auth_service.dart';
import 'package:lopako_app_lis/core/services/family_circles_service.dart';
import 'package:lopako_app_lis/core/services/service_manager.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'package:lopako_app_lis/features/routines/models/routine_model.dart';

class FamilyCirclesController extends ChangeNotifier {
  final FamilyCirclesService _familyCirclesService;

  FamilyCirclesController()
      : _familyCirclesService = ServiceManager.instance.getService('familyCircles') as FamilyCirclesService;

  /// Get the JSON questionnaire for creating a family circle
  List<Map<String, Object>> get fullQuestionnaire {
    return _familyCirclesService.questionnaire;
  }

  /// Get the JSON questionnaire for joining a family circle
  List<Map<String, Object>> get userQuestionnaire {
    return _familyCirclesService.questionnaire
        .where((item) => item['type'] == 'user').toList();
  }

  /// Get the JSON questionnaire for editing a family circle
  List<Map<String, Object>> get patientQuestionnaire {
    return _familyCirclesService.questionnaire
        .where((item) => item['type'] == 'patient').toList();
  }

  /// Create a new family circle from a [patientName] and the [questionary] to be used and return the [pin] code.
  Future<FamilyCircle> create(String patientName, Map<String, dynamic> questionary) async {
    AuthService authService = ServiceManager.instance.getService('auth') as AuthService;
    assert(authService.isLogged(), 'User must be logged in to create a family circle');
    if (patientName.isEmpty) {
      throw Exception('El nombre del paciente no puede estar vacío');
    }
    FamilyCircle? circle;
    try {
      circle = await _familyCirclesService.create(patientName, questionary);
    } catch (e) {
      throw Exception('Ha ocurrido un error al crear el círculo familiar. Por favor, inténtelo de nuevo.');
    }
    return circle;
  }

  /// Edit the family circle with the given [familyCircle].
  Future<FamilyCircle> edit(FamilyCircle familyCircle) async {
    AuthService authService = ServiceManager.instance.getService('auth') as AuthService;
    assert(authService.isLogged(), 'User must be logged in to create a family circle');
    FamilyCircle? circle;
    try {
      circle = await _familyCirclesService.edit(familyCircle);
    } catch (e) {
      throw Exception('No se ha podido editar el círculo familiar. Por favor, inténtelo de nuevo.');
    }
    return circle;
  }

  /// Add a routine to the list of scheduled routines for the family circle.
  Future<void> addRoutine(Routine routine, { String? day, String? period }) async {
    AuthService authService = ServiceManager.instance.getService('auth') as AuthService;
    assert(authService.isLogged(), 'User must be logged in to create a family circle');
    DateTime date = DateTime.now();
    date = DateTime(date.year, date.month, date.day, 0, 0, 0);
    day ??= 'today';
    if (day == 'tomorrow') {
      date = date.add(const Duration(days: 1));
    }
    period ??= 'morning';
    if (period == 'night') {
      date = date.add(const Duration(hours: 18));
    } else if (period == 'afternoon') {
      date = date.add(const Duration(hours: 12));
    }
    await _familyCirclesService.addRoutine(routine, startsAt: date);
  }

  /// Start a routine for the family circle.
  Future<void> startRoutine(Routine routine) async {
    AuthService authService = ServiceManager.instance.getService('auth') as AuthService;
    assert(authService.isLogged(), 'User must be logged in to create a family circle');
    await _familyCirclesService.startRoutine(routine);
  }

  /// Finish a routine for the family circle.
  Future<FamilyCircle> finishFamilyCircleRoutine(FamilyCircle familyCircle) async {
    return await _familyCirclesService.finishRoutine(familyCircle);
  }

  /// Get the current family circle.
  Future<FamilyCircle?> getCurrentFamilyCircle({bool forceRefresh = false}) async {
    AuthService authService = ServiceManager.instance.getService('auth') as AuthService;
    assert(authService.isLogged(), 'User must be logged in to create a family circle');
    FamilyCircle? circle;
    try {
      circle = await _familyCirclesService.getCurrentFamilyCircle(forceRefresh: forceRefresh);
    } catch (e) {
      throw Exception('No se ha podido obtener el círculo familiar. Por favor, inténtelo de nuevo.');
    }
    return circle;
  }

  /// Get the list of family circles for the user.
  Future<List<FamilyCircle>> getFamilyCircles() async {
    AuthService authService = ServiceManager.instance.getService('auth') as AuthService;
    assert(authService.isLogged(), 'User must be logged in to create a family circle');
    List<FamilyCircle> circles;
    final userId = authService.currentUser?.uid;
    try {
      circles = await _familyCirclesService.getUserFamilyCircles(userId!);
    } catch (e) {
      throw Exception('No se ha podido obtener la lista de círculos familiares. Por favor, inténtelo de nuevo.');
    }
    return circles;
  }

  /// Switch the current family circle to the one with the given [id].
  Future<FamilyCircle> switchFamilyCircle(FamilyCircle familyCircle) async {
    AuthService authService = ServiceManager.instance.getService('auth') as AuthService;
    assert(authService.isLogged(), 'User must be logged in to create a family circle');
    try {
      return await _familyCirclesService.switchFamilyCircle(familyCircle);
    } catch (e) {
      throw Exception('No se ha podido cambiar el círculo familiar. Por favor, inténtelo de nuevo.');
    }
  }
}
