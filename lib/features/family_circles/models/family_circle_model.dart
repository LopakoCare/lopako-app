import 'package:lopako_app_lis/features/auth/models/user_model.dart';
import 'package:lopako_app_lis/features/routines/models/routine_model.dart';

class FamilyCircle {
  final String id;
  final AppUser createdBy;
  final List<AppUser> members;
  final String patientName;
  final DateTime createdAt;
  final String pin;
  List<Routine> routines;
  Routine? currentRoutine;

  FamilyCircle(this.id, {
    required this.createdBy,
    required this.members,
    required this.patientName,
    required this.createdAt,
    required this.pin,
    required this.routines,
    required this.currentRoutine,
  });

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is FamilyCircle && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  FamilyCircle copyWith({
    String? id,
    AppUser? createdBy,
    List<AppUser>? members,
    String? patientName,
    DateTime? createdAt,
    String? pin,
    List<Routine>? routines,
    Routine? currentRoutine,
  }) {
    return FamilyCircle(
      id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      members: members != null ? List.from(members) : List.from(this.members),
      patientName: patientName ?? this.patientName,
      createdAt: createdAt ?? this.createdAt,
      pin: pin ?? this.pin,
      routines: routines != null ? List.from(routines) : List.from(this.routines),
      currentRoutine: currentRoutine ?? this.currentRoutine,
    );
  }

  factory FamilyCircle.fromJson(Map<String, dynamic> json) {
    return FamilyCircle(
      json['id'] as String,
      createdBy: AppUser.fromJson(json['createdBy'] as Map<String, dynamic>),
      members: (json['members'] as List<dynamic>)
        .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
        .toList(),
      patientName: json['patientName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      pin: json['pin'] as String,
      routines: json['routines'] == null
        ? []
        : (json['routines'] as List<dynamic>)
          .map((e) => Routine.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentRoutine: json['currentRoutine'] == null
        ? null
        : Routine.fromJson(json['currentRoutine'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdBy': createdBy.toJson(),
      'members': members.map((e) => e.toJson()).toList(),
      'patientName': patientName,
      'createdAt': createdAt.toIso8601String(),
      'pin': pin,
      'routines': routines.map((e) => e.toJson()).toList(),
      'currentRoutine': currentRoutine?.toJson(),
    };
  }
}
