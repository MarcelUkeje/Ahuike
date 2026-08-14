import '../../core/network/api_client.dart';
import '../models/doctor.dart';
import '../models/page_meta.dart';

class DoctorRepository {
  final ApiClient _apiClient;

  DoctorRepository(this._apiClient);

  Future<PagedResponse<Doctor>> getDoctors({
    String? departmentId,
    int limit = 20,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
    };
    if (departmentId != null && departmentId.isNotEmpty) {
      params['departmentId'] = departmentId;
    }

    final response = await _apiClient.get('/doctors', queryParameters: params);
    final list = (response.data as List<dynamic>)
        .map((json) => Doctor.fromJson(json as Map<String, dynamic>))
        .toList();
    final meta = response.meta != null
        ? PageMeta.fromJson(response.meta!)
        : PageMeta.empty;
    return PagedResponse(items: list, meta: meta);
  }

  Future<Doctor> getDoctorById(String id) async {
    final response = await _apiClient.get('/doctors/$id');
    return Doctor.fromJson(response.data as Map<String, dynamic>);
  }
}
