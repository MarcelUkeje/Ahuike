import 'package:flutter/foundation.dart';
import '../../shared/models/department.dart';
import '../../shared/repositories/department_repository.dart';

class DepartmentProvider extends ChangeNotifier {
  final DepartmentRepository _repository;

  DepartmentProvider(this._repository);

  List<Department> _departments = [];
  List<Department> get departments => _departments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadDepartments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _departments = await _repository.getDepartments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Option to search departments
  Future<void> searchDepartments(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _departments = await _repository.getDepartments(query: query);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
