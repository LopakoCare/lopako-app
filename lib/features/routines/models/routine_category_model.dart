import 'package:flutter/material.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';

class RoutineCategory {
  final String id;
  final String label;
  final int? score;
  late final MaterialColor color;
  bool isSelected;

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

  RoutineCategory(this.id, {
    this.label = '',
    this.score,
    String color = '',
    this.isSelected = false,
  }) {
    this.color = _getColor(color);
  }

  RoutineCategory copyWith({
    String? id,
    String? label,
    int? score,
    MaterialColor? color,
    bool? isSelected,
  }) {
    return RoutineCategory(
      id ?? this.id,
      label: label ?? this.label,
      score: score ?? this.score,
      color: color == null ? _getColorString(this.color) : _getColorString(color),
      isSelected: isSelected ?? this.isSelected,
    );
  }

  RoutineCategory.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      label = json['label'] as String,
      score = json['score'] as int?,
      isSelected = json['isSelected'] as bool? ?? false {
    color = _getColor(json['color'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'color': _getColorString(color),
      'score': score,
      'isSelected': isSelected,
    };
  }
}
