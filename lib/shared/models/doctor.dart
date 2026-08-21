import 'package:flutter/widgets.dart';

class Doctor {
  final String id;
  final String name;
  final String slug;
  final String specialty;
  final String departmentId;
  final String? imageUrl;
  final double rating;
  final int ratingCount;
  final int consultationFee;
  final bool isAvailable;
  
  // Detail fields
  final String? bio;
  final List<String>? qualifications;
  final List<AppointmentSlot>? availableSlots;

  Doctor({
    required this.id,
    required this.name,
    required this.slug,
    required this.specialty,
    required this.departmentId,
    this.imageUrl,
    required this.rating,
    required this.ratingCount,
    required this.consultationFee,
    required this.isAvailable,
    this.bio,
    this.qualifications,
    this.availableSlots,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      specialty: json['specialty'] as String,
      departmentId: json['departmentId'] as String,
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num).toDouble(),
      ratingCount: (json['ratingCount'] as num).toInt(),
      consultationFee: (json['consultationFee'] as num).toInt(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      bio: json['bio'] as String?,
      qualifications: json['qualifications'] != null
          ? List<String>.from(json['qualifications'] as List)
          : null,
      availableSlots: json['availableSlots'] != null
          ? (json['availableSlots'] as List)
              .map((s) => AppointmentSlot.fromJson(s))
              .toList()
          : null,
    );
  }
}

class AppointmentSlot {
  final String id;
  final String doctorId;
  final String slotDate; // YYYY-MM-DD
  final String startTime; // HH:MM
  final String endTime; // HH:MM
  final bool isBooked;

  AppointmentSlot({
    required this.id,
    required this.doctorId,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
  });

  factory AppointmentSlot.fromJson(Map<String, dynamic> json) {
    return AppointmentSlot(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      slotDate: json['slotDate'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isBooked: json['isBooked'] as bool? ?? false,
    );
  }
}

extension DoctorImageProvider on Doctor {
  ImageProvider? get imageProvider {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (imageUrl!.startsWith('http')) {
      return NetworkImage(imageUrl!);
    }
    return AssetImage(imageUrl!);
  }
}

