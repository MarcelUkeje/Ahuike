class Prescription {
  final String id;
  final String patientId;
  final String? doctorId;
  final String? appointmentId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;
  final bool isActive;
  final String issuedAt;
  final String? expiresAt;

  const Prescription({
    required this.id,
    required this.patientId,
    this.doctorId,
    this.appointmentId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
    required this.isActive,
    required this.issuedAt,
    this.expiresAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String,
      patientId: json['patientId'] ?? json['patient_id'] as String,
      doctorId: json['doctorId'] ?? json['doctor_id'] as String?,
      appointmentId: json['appointmentId'] ?? json['appointment_id'] as String?,
      medicationName: json['medicationName'] ?? json['medication_name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      instructions: json['instructions'] as String,
      isActive: json['isActive'] ?? json['is_active'] as bool,
      issuedAt: json['issuedAt'] ?? json['issued_at'] as String,
      expiresAt: json['expiresAt'] ?? json['expires_at'] as String?,
    );
  }
}
