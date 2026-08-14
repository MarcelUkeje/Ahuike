import '../../core/network/api_client.dart';
import '../models/medical_record.dart';
import '../models/page_meta.dart';

class MedicalRecordRepository {
  final ApiClient _apiClient;

  MedicalRecordRepository(this._apiClient);

  Future<PagedResponse<MedicalRecord>> getMedicalRecords({
    int limit = 20,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
    };

    final response = await _apiClient.get('/medical-records', queryParameters: params);
    final list = (response.data as List<dynamic>)
        .map((json) => MedicalRecord.fromJson(json as Map<String, dynamic>))
        .toList();
    final meta = response.meta != null
        ? PageMeta.fromJson(response.meta!)
        : PageMeta.empty;
    return PagedResponse(items: list, meta: meta);
  }

  Future<MedicalRecord> getMedicalRecordById(String id) async {
    final response = await _apiClient.get('/medical-records/$id');
    return MedicalRecord.fromJson(response.data as Map<String, dynamic>);
  }
}
