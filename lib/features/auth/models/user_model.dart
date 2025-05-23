class AppUser {
  final String id;
  final String name;
  final String email;
  final int? age;

  AppUser(this.id, {
    required this.name,
    required this.email,
    this.age,
  });

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is AppUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
  }) {
    return AppUser(
      id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      age: json['age'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
    };
  }
}
