import 'package:flutter/foundation.dart';
import '../../shared/models/doctor.dart';
import '../../shared/models/page_meta.dart';
import '../../shared/repositories/doctor_repository.dart';

class DoctorProvider extends ChangeNotifier {
  final DoctorRepository _repository;

  DoctorProvider(this._repository);

  static const int _pageSize = 20;

  List<Doctor> _doctors = [];
  List<Doctor> get doctors => _doctors;

  Doctor? _selectedDoctor;
  Doctor? get selectedDoctor => _selectedDoctor;

  PageMeta _meta = PageMeta.empty;
  PageMeta get meta => _meta;
  bool get hasMore => _meta.hasMore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentDepartmentId;

  /// Initial load / refresh — clears stale results immediately.
  Future<void> loadDoctors({String? departmentId}) async {
    _currentDepartmentId = departmentId;
    // Clear immediately so stale data from another department is never shown.
    _doctors = [];
    _meta = PageMeta.empty;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getDoctors(
        departmentId: departmentId,
        limit: _pageSize,
        offset: 0,
      );
      _doctors = result.items;
      _meta = result.meta;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Appends the next page of results.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_meta.hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getDoctors(
        departmentId: _currentDepartmentId,
        limit: _pageSize,
        offset: _doctors.length,
      );
      _doctors = [..._doctors, ...result.items];
      _meta = result.meta;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadDoctorDetails(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedDoctor = null;
    notifyListeners();

    try {
      _selectedDoctor = await _repository.getDoctorById(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
