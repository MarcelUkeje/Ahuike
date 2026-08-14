import 'package:flutter/foundation.dart';
import '../../shared/models/department.dart';
import '../../shared/models/page_meta.dart';
import '../../shared/repositories/department_repository.dart';

class DepartmentProvider extends ChangeNotifier {
  final DepartmentRepository _repository;

  DepartmentProvider(this._repository);

  static const int _pageSize = 20;

  List<Department> _departments = [];
  List<Department> get departments => _departments;

  PageMeta _meta = PageMeta.empty;
  PageMeta get meta => _meta;
  bool get hasMore => _meta.hasMore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentQuery;

  /// Initial load / refresh — resets to page 0.
  Future<void> loadDepartments({String? query}) async {
    _currentQuery = query;
    _isLoading = true;
    _errorMessage = null;
    _departments = [];
    notifyListeners();

    try {
      final result = await _repository.getDepartments(
        query: query,
        limit: _pageSize,
        offset: 0,
      );
      _departments = result.items;
      _meta = result.meta;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Appends the next page of results (infinite scroll).
  Future<void> loadMore() async {
    if (_isLoadingMore || !_meta.hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getDepartments(
        query: _currentQuery,
        limit: _pageSize,
        offset: _departments.length,
      );
      _departments = [..._departments, ...result.items];
      _meta = result.meta;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Convenience alias for search use.
  Future<void> searchDepartments(String query) => loadDepartments(query: query);
}
