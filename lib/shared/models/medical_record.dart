class MedicalRecord {
  final String id;
  final String patientId;
  final String? doctorId;
  final String? appointmentId;
  final String recordType;
  final String title;
  final String description;
  final String? diagnosis;
  final String? treatmentPlan;
  final String createdAt;

  const MedicalRecord({
    required this.id,
    required this.patientId,
    this.doctorId,
    this.appointmentId,
    required this.recordType,
    required this.title,
    required this.description,
    this.diagnosis,
    this.treatmentPlan,
    required this.createdAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      patientId: json['patientId'] ?? json['patient_id'] as String,
      doctorId: json['doctorId'] ?? json['doctor_id'] as String?,
      appointmentId: json['appointmentId'] ?? json['appointment_id'] as String?,
      recordType: json['recordType'] ?? json['record_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      diagnosis: json['diagnosis'] as String?,
      treatmentPlan: json['treatmentPlan'] ?? json['treatment_plan'] as String?,
      createdAt: json['createdAt'] ?? json['created_at'] as String,
    );
  }
}
