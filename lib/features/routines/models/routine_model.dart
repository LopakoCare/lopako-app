import 'package:lopako_app_lis/features/routines/models/routine_activity_model.dart';
import 'package:lopako_app_lis/features/routines/models/routine_category_model.dart';

class Routine {
  final String id;
  final List<RoutineActivity> activities;
  final RoutineCategory category;
  final String duration;
  final String icon;
  final String description;
  final String schedule;
  final List<RoutineCategory> subcategories;
  final String title;

  Routine(this.id, {
    required this.activities,
    required this.category,
    required this.duration,
    required this.icon,
    required this.description,
    required this.schedule,
    required this.subcategories,
    required this.title,
  });

  Routine copyWith({
    String? id,
    List<RoutineActivity>? activities,
    RoutineCategory? category,
    String? duration,
    String? icon,
    String? description,
    String? schedule,
    List<RoutineCategory>? subcategories,
    String? title,
  }) {
    return Routine(
      id ?? this.id,
      activities: activities ?? this.activities,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      schedule: schedule ?? this.schedule,
      subcategories: subcategories ?? this.subcategories,
      title: title ?? this.title,
    );
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      json['id'] as String,
      activities: (json['activities'] as List)
          .map((e) => RoutineActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
      category: RoutineCategory.fromJson(json['category'] as Map<String, dynamic>),
      duration: json['duration'] as String,
      icon: json['icon'] as String,
      description: json['information'] as String,
      schedule: json['schedule'] as String,
      subcategories: (json['subcategories'] as Map<String, dynamic>)
          .entries
          .map((e) => RoutineCategory(e.key, score: (e.value as num).toInt()))
          .toList(),
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'activities': activities.map((a) => a.toJson()).toList(),
    'category': category.toJson(),
    'duration': duration,
    'icon': icon,
    'information': description,
    'schedule': schedule,
    'subcategories': {
      for (var sub in subcategories) sub.id: sub.score,
    },
    'title': title,
  };
}
