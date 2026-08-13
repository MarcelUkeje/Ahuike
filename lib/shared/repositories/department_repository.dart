import '../../core/network/api_client.dart';
import '../models/department.dart';

class DepartmentRepository {
  final ApiClient _apiClient;

  DepartmentRepository(this._apiClient);

  Future<List<Department>> getDepartments({String? query}) async {
    final Map<String, String> queryParams = {};
    if (query != null && query.isNotEmpty) {
      queryParams['q'] = query;
    }

    final response = await _apiClient.get('/departments', queryParameters: queryParams.isEmpty ? null : queryParams);
    
    // response is the unwrapped "data" list
    final List<dynamic> list = response as List<dynamic>;
    return list.map((json) => Department.fromJson(json)).toList();
  }

  Future<Department> getDepartmentById(String id) async {
    final response = await _apiClient.get('/departments/$id');
    return Department.fromJson(response as Map<String, dynamic>);
  }
}
