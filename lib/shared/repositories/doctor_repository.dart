import '../../core/network/api_client.dart';
import '../models/doctor.dart';

class DoctorRepository {
  final ApiClient _apiClient;

  DoctorRepository(this._apiClient);

  Future<List<Doctor>> getDoctors({String? departmentId}) async {
    final Map<String, String> queryParams = {};
    if (departmentId != null && departmentId.isNotEmpty) {
      queryParams['departmentId'] = departmentId;
    }

    final response = await _apiClient.get('/doctors', queryParameters: queryParams.isEmpty ? null : queryParams);
    
    final List<dynamic> list = response as List<dynamic>;
    return list.map((json) => Doctor.fromJson(json)).toList();
  }

  Future<Doctor> getDoctorById(String id) async {
    final response = await _apiClient.get('/doctors/$id');
    return Doctor.fromJson(response as Map<String, dynamic>);
  }
}
