import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/services/auth_service.dart';
import 'package:lopako_app_lis/core/services/family_circles_service.dart';
import 'package:lopako_app_lis/core/services/service_manager.dart';

class FamilyCirclesController extends ChangeNotifier {
  final FamilyCirclesService _familyCirclesService;

  FamilyCirclesController()
      : _familyCirclesService = ServiceManager.instance.getService('familyCircles') as FamilyCirclesService;

  /// Get the JSON questionnaire for creating a family circle
  List<Map<String, Object>> get initialQuestionnaire {
    return _familyCirclesService.initialQuestionnaire;
  }

  /// Get the JSON questionnaire for joining a family circle
  List<Map<String, Object>> get joinQuestionnaire {
    return _familyCirclesService.initialQuestionnaire
        .where((item) => item['type'] == 'join').toList();
  }

  /// Create a new family circle from a [patientName] and the [questionary] to be used and return the [pin] code.
  Future<String> create(String patientName, Map<String, dynamic> questionary) async {
    AuthService authService = ServiceManager.instance.getService('auth') as AuthService;
    assert(authService.isLogged(), 'User must be logged in to create a family circle');
    if (patientName.isEmpty) {
      throw Exception('El nombre del paciente no puede estar vacío');
    }
    String id;
    try {
      id = await _familyCirclesService.create(patientName, questionary);
    } catch (e) {
      throw Exception('Ha ocurrido un error al crear el círculo familiar. Por favor, inténtelo de nuevo.');
    }
    Map<String, dynamic>? data;
    try {
      data = await _familyCirclesService.getFamilyCircle(id);
    } catch (e) {
      throw Exception('Ha ocurrido un error al obtener la información del círculo familiar. Por favor, inténtelo de nuevo.');
    }
    if (data == null) {
      throw Exception('No se pudo obtener el círculo familiar creado.');
    }
    String pin = data['pin'] as String;
    if (pin.isEmpty) {
      throw Exception('El código PIN no se generó correctamente.');
    }
    return pin;
  }
}
