class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final String departmentId;
  final String slotId;
  final String reasonForVisit;
  final int consultationFee;
  final String status;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.departmentId,
    required this.slotId,
    required this.reasonForVisit,
    required this.consultationFee,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      departmentId: json['departmentId'] as String,
      slotId: json['slotId'] as String,
      reasonForVisit: json['reasonForVisit'] as String,
      consultationFee: (json['consultationFee'] as num).toInt(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
