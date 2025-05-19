class User {
  final String id;
  final String name;
  final String email;
  final int? age;

  User(this.id, {
    required this.name,
    required this.email,
    this.age,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
  }) {
    return User(
      id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
