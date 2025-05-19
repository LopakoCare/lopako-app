import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/services/routines_service.dart';
import 'package:lopako_app_lis/core/services/service_manager.dart';
import 'package:lopako_app_lis/features/routines/models/routine_category_model.dart';
import 'package:lopako_app_lis/features/routines/models/routine_model.dart';

class RoutinesController extends ChangeNotifier {
  final RoutinesService _routinesService;

  RoutinesController()
      : _routinesService = ServiceManager.instance.getService('routines') as RoutinesService;

  /// Get a routine by its [id].
  Future<Routine?> getRoutine(String id) async {
    try {
      return await _routinesService.getRoutine(id);
    } catch (e) {
      throw Exception('No se ha podido obtener la información de la rutina.');
    }
  }

  /// Get a list of routine categories.
  Future<List<RoutineCategory>> getCategories({bool forceRefresh = false}) async {
    try {
      final categories = await _routinesService.getCategories(forceRefresh: false);
      categories.sort((a, b) => a.label.compareTo(b.label));
      return categories;
    } catch (e) {
      print(e);
      throw Exception('Ha ocurrido un error al cargar.');
    }
  }

  /// Get recommended routines for a user. Specify a [limit] to limit the number of routines returned.
  Future<List<Routine>> getRecommendedRoutines({int? limit, bool forceRefresh = false}) async {
    try {
      final routines = await _routinesService.getRecommendedRoutines(limit: limit, forceRefresh: forceRefresh);
      return routines;
    } catch (e) {
      print(e);
      throw Exception('Ha ocurrido un error al obtener las rutinas recomendadas.');
    }
  }

  /// Get filtered routines by a [search] query and a list of [categories].
  Future<List<Routine>> getFilteredRoutines({String? search, List<RoutineCategory>? categories, int? limit, bool forceRefresh = false}) async {
    try {
      final routines = await _routinesService.getFilteredRoutines(search: search, categories: categories, limit: limit, forceRefresh: forceRefresh);
      return routines;
    } catch (e) {
      print(e);
      throw Exception('Ha ocurrido un error al obtener las rutinas favoritas.');
    }
  }
}
