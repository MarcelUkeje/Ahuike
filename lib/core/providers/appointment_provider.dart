import 'package:flutter/foundation.dart';
import '../../shared/models/appointment.dart';
import '../../shared/repositories/appointment_repository.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentRepository _repository;

  AppointmentProvider(this._repository);

  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isBooking = false;
  bool get isBooking => _isBooking;

  String? _bookingError;
  String? get bookingError => _bookingError;

  Future<void> loadAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await _repository.getAppointments();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
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
      
      // Add the new appointment to the top of our local history list
      _appointments.insert(0, newAppointment);
      return newAppointment;
    } catch (e) {
      _bookingError = e.toString();
      return null;
    } finally {
      _isBooking = false;
      notifyListeners();
    }
  }
}
