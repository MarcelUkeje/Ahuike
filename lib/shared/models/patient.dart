class Patient {
  final String id;
  final String name;
  final String email;
  final String createdAt;

  const Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt,
    };
  }
}
