import 'package:flutter/foundation.dart';
import '../../shared/models/appointment.dart';
import '../../shared/models/page_meta.dart';
import '../../shared/repositories/appointment_repository.dart';
import '../network/api_client.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentRepository _repository;

  AppointmentProvider(this._repository);

  static const int _pageSize = 20;

  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  PageMeta _meta = PageMeta.empty;
  PageMeta get meta => _meta;
  bool get hasMore => _meta.hasMore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isBooking = false;
  bool get isBooking => _isBooking;

  String? _bookingError;
  String? get bookingError => _bookingError;

  /// Initial load / refresh — resets to page 0.
  Future<void> loadAppointments({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    _appointments = [];
    notifyListeners();

    try {
      final result = await _repository.getAppointments(
        status: status,
        limit: _pageSize,
        offset: 0,
      );
      _appointments = result.items;
      _meta = result.meta;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Appends the next page of results.
  Future<void> loadMore({String? status}) async {
    if (_isLoadingMore || !_meta.hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getAppointments(
        status: status,
        limit: _pageSize,
        offset: _appointments.length,
      );
      _appointments = [..._appointments, ...result.items];
      _meta = result.meta;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<Appointment?> bookAppointment({
    required String doctorId,
    required String departmentId,
    required String slotId,
    required String reasonForVisit,
  }) async {
    _isBooking = true;
    _bookingError = null;
    notifyListeners();

    try {
      final newAppointment = await _repository.createAppointment(
        doctorId: doctorId,
        departmentId: departmentId,
        slotId: slotId,
        reasonForVisit: reasonForVisit,
      );
      // Prepend to local list and update total count
      _appointments = [newAppointment, ..._appointments];
      _meta = PageMeta(
        total: _meta.total + 1,
        limit: _meta.limit,
        offset: _meta.offset,
        hasMore: _meta.hasMore,
      );
      return newAppointment;
    } catch (e) {
      _bookingError = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isBooking = false;
      notifyListeners();
    }
  }

  Future<void> confirmAppointment(String appointmentId) async {
    try {
      await _repository.confirmAppointment(appointmentId);
      
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        final current = _appointments[index];
        _appointments[index] = Appointment(
          id: current.id,
          patientId: current.patientId,
          doctorId: current.doctorId,
          departmentId: current.departmentId,
          slotId: current.slotId,
          reasonForVisit: current.reasonForVisit,
          consultationFee: current.consultationFee,
          status: 'confirmed',
          notes: current.notes,
          createdAt: current.createdAt,
          updatedAt: DateTime.now().toUtc().toIso8601String(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to confirm appointment locally: $e");
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _repository.deleteAppointment(appointmentId);
      
      _appointments.removeWhere((a) => a.id == appointmentId);
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to delete appointment: $e");
      rethrow;
    }
  }
}
