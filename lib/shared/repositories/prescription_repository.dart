import '../../core/network/api_client.dart';
import '../models/page_meta.dart';
import '../models/prescription.dart';

class PrescriptionRepository {
  final ApiClient _apiClient;

  PrescriptionRepository(this._apiClient);

  Future<PagedResponse<Prescription>> getPrescriptions({
    bool? active,
    int limit = 20,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
    };
    if (active != null) {
      params['active'] = '$active';
    }

    final response = await _apiClient.get('/prescriptions', queryParameters: params);
    final list = (response.data as List<dynamic>)
        .map((json) => Prescription.fromJson(json as Map<String, dynamic>))
        .toList();
    final meta = response.meta != null
        ? PageMeta.fromJson(response.meta!)
        : PageMeta.empty;
    return PagedResponse(items: list, meta: meta);
  }

  Future<Prescription> getPrescriptionById(String id) async {
    final response = await _apiClient.get('/prescriptions/$id');
    return Prescription.fromJson(response.data as Map<String, dynamic>);
  }
}
