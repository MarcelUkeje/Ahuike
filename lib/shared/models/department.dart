class Department {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? imageUrl;
  final bool isActive;
  final List<DoctorInDepartment>? doctors; // Only present in detail view

  Department({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.imageUrl,
    required this.isActive,
    this.doctors,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      doctors: json['doctors'] != null
          ? (json['doctors'] as List).map((d) => DoctorInDepartment.fromJson(d)).toList()
          : null,
    );
  }
}

class DoctorInDepartment {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int consultationFee;
  final bool isAvailable;

  DoctorInDepartment({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.consultationFee,
    required this.isAvailable,
  });

  factory DoctorInDepartment.fromJson(Map<String, dynamic> json) {
    return DoctorInDepartment(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      rating: (json['rating'] as num).toDouble(),
      consultationFee: (json['consultationFee'] as num).toInt(),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}
