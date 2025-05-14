class Actividad {
  final String title;
  final String information;
  final String duration;
  final String schedule;
  final Map<String, String> category;
  final List<Map<String, String>> secondaryCategories;
  final String? icon;
  final int caregivers;

  Actividad({
    required this.title,
    required this.information,
    required this.duration,
    required this.schedule,
    required this.category,
    required this.secondaryCategories,
    this.icon,
    required this.caregivers,
  });

  factory Actividad.fromMap(Map<String, dynamic> map) {
    return Actividad(
      title: map['title'] ?? '',
      information: map['information'] ?? '',
      duration: map['duration'] ?? '',
      schedule: map['schedule'] ?? '',
      category: Map<String, String>.from(map['category'] ?? {}),
      secondaryCategories: (map['secondary_categories'] as List<dynamic>? ?? [])
          .map((e) => Map<String, String>.from(e))
          .toList(),
      icon: map['icon'],
      caregivers: map['caregivers'] ?? 1,
    );
  }
}