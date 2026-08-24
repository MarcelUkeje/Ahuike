import 'dart:math';
import '../../core/network/api_client.dart';
import '../models/appointment.dart';
import '../models/page_meta.dart';

class AppointmentRepository {
  final ApiClient _apiClient;

  AppointmentRepository(this._apiClient);

  Future<PagedResponse<Appointment>> getAppointments({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
    };
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await _apiClient.get('/appointments', queryParameters: params);
    final list = (response.data as List<dynamic>)
        .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
        .toList();
    final meta = response.meta != null
        ? PageMeta.fromJson(response.meta!)
        : PageMeta.empty;
    return PagedResponse(items: list, meta: meta);
  }

  Future<Appointment> getAppointmentById(String id) async {
    final response = await _apiClient.get('/appointments/$id');
    return Appointment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Appointment> createAppointment({
    required String doctorId,
    required String departmentId,
    required String slotId,
    required String reasonForVisit,
  }) async {
    final idempotencyKey = '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000000)}';
    
    final response = await _apiClient.post(
      '/appointments', 
      body: {
        'doctorId': doctorId,
        'departmentId': departmentId,
        'slotId': slotId,
        'reasonForVisit': reasonForVisit,
      },
      headers: {
        'Idempotency-Key': idempotencyKey,
      },
    );
    return Appointment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> confirmAppointment(String id) async {
    await _apiClient.post('/appointments/$id/confirm', body: {});
  }

  Future<void> completeAppointment(String id) async {
    await _apiClient.post('/appointments/$id/complete', body: {});
  }

  Future<void> deleteAppointment(String id) async {
    await _apiClient.delete('/appointments/$id');
  }
}
