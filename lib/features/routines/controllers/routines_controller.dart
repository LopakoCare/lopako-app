// 🔄 MODIFICADO: Cambiado a inyección por constructor
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/routines_service.dart';
import '../../../core/services/family_circles_service.dart';

class RoutinesController extends ChangeNotifier {
  final RoutinesService _routinesService;
  final FamilyCirclesService _familyService;

  // 🔄 Cambiado: ahora recibe los servicios por constructor (inyección limpia)
  RoutinesController(this._routinesService, this._familyService);

  Future<List<Map<String, dynamic>>> obtenerTodasLasRutinas() => _routinesService.obtenerTodasLasRutinas();

  Future<List<Map<String, dynamic>>> cargarActividadesDesdeReferencias(List<dynamic> referencias) =>
      _routinesService.cargarActividadesDesdeReferencias(referencias);

  Future<String> anadirRutinaAFamilia(DocumentReference rutinaRef) =>
      _familyService.anadirRutinaAFamilia(rutinaRef);

  Future<String> completarRutinaYEliminar(DocumentReference rutinaRef) =>
      _familyService.completarRutinaYEliminar(rutinaRef);
}
