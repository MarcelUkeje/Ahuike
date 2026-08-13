import '../../core/network/api_client.dart';
import '../models/appointment.dart';

class AppointmentRepository {
  final ApiClient _apiClient;

  AppointmentRepository(this._apiClient);

  Future<List<Appointment>> getAppointments() async {
    // The patient ID is automatically injected by the ApiClient headers
    final response = await _apiClient.get('/appointments');
    
    final List<dynamic> list = response as List<dynamic>;
    return list.map((json) => Appointment.fromJson(json)).toList();
  }

  Future<Appointment> getAppointmentById(String id) async {
    final response = await _apiClient.get('/appointments/$id');
    return Appointment.fromJson(response as Map<String, dynamic>);
  }

  Future<Appointment> createAppointment({
    required String doctorId,
    required String departmentId,
    required String slotId,
    required String reasonForVisit,
  }) async {
    final response = await _apiClient.post('/appointments', body: {
      'doctorId': doctorId,
      'departmentId': departmentId,
      'slotId': slotId,
      'reasonForVisit': reasonForVisit,
    });
    
    return Appointment.fromJson(response as Map<String, dynamic>);
  }
}
