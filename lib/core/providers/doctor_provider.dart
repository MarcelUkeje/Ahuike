import 'package:flutter/foundation.dart';
import '../../shared/models/doctor.dart';
import '../../shared/repositories/doctor_repository.dart';

class DoctorProvider extends ChangeNotifier {
  final DoctorRepository _repository;

  DoctorProvider(this._repository);

  List<Doctor> _doctors = [];
  List<Doctor> get doctors => _doctors;

  Doctor? _selectedDoctor;
  Doctor? get selectedDoctor => _selectedDoctor;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadDoctors({String? departmentId}) async {
    // Clear previous results immediately so stale data from another department
    // does not show while the new request is in flight (#13 state bleed fix)
    _doctors = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _doctors = await _repository.getDoctors(departmentId: departmentId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
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
