import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';

enum RoutineActivityType {
  microlearning,
  practice,
}

class RoutineActivity {
  final String id;
  final String icon;
  final String title;
  final String description;
  final RoutineActivityType type;
  final List<String> resources;
  late final MaterialColor color;

  MaterialColor _getColor(String color) {
    switch (color) {
      case 'yellow': return AppColors.yellow;
      case 'red':    return AppColors.red;
      case 'pink':   return AppColors.pink;
      case 'blue':   return AppColors.blue;
      case 'teal':   return AppColors.teal;
      case 'green':  return AppColors.green;
      default:       return AppColors.neutral;
    }
  }

  String _getColorString(MaterialColor color) {
    if (color == AppColors.yellow) return 'yellow';
    if (color == AppColors.red)    return 'red';
    if (color == AppColors.pink)   return 'pink';
    if (color == AppColors.blue)   return 'blue';
    if (color == AppColors.teal)   return 'teal';
    if (color == AppColors.green)  return 'green';
    return 'neutral';
  }

  RoutineActivity(this.id, {
    required this.icon,
    required this.title,
    required this.description,
    required this.type,
    required this.resources,
    String color = 'neutral',
  }) {
    this.color = _getColor(color);
  }

  RoutineActivity copyWith({
    String? id,
    String? icon,
    String? title,
    String? description,
    RoutineActivityType? type,
    List<String>? resources,
    String? color,
  }) {
    return RoutineActivity(
      id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      resources: resources ?? this.resources,
      color: color == null ? _getColorString(this.color) : _getColorString(_getColor(color)),
    );
  }

  factory RoutineActivity.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    final type = RoutineActivityType.values.firstWhere(
      (e) => e.toString().split('.').last == typeString,
      orElse: () => RoutineActivityType.practice,
    );
    final resources = <String>[];
    if (json['resources'] != null && json['resources'] is List) {
      resources.addAll((json['resources'] as List).map((e) => e as String));
    }
    return RoutineActivity(
      json['id'] as String,
      icon: json['icon'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: type,
      resources: resources,
      color: json['color'] as String? ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'resources': resources,
      'color': _getColorString(color),
    };
  }
}
