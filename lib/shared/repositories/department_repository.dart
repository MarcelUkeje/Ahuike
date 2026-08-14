import '../../core/network/api_client.dart';
import '../models/department.dart';
import '../models/page_meta.dart';

class DepartmentRepository {
  final ApiClient _apiClient;

  DepartmentRepository(this._apiClient);

  Future<PagedResponse<Department>> getDepartments({
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
    };
    if (query != null && query.isNotEmpty) params['q'] = query;

    final response = await _apiClient.get('/departments', queryParameters: params);
    final list = (response.data as List<dynamic>)
        .map((json) => Department.fromJson(json as Map<String, dynamic>))
        .toList();
    final meta = response.meta != null
        ? PageMeta.fromJson(response.meta!)
        : PageMeta.empty;
    return PagedResponse(items: list, meta: meta);
  }

  Future<Department> getDepartmentById(String id) async {
    final response = await _apiClient.get('/departments/$id');
    return Department.fromJson(response.data as Map<String, dynamic>);
  }
}
