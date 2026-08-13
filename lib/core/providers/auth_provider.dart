import 'package:flutter/foundation.dart';
import '../../shared/models/patient.dart';
import '../../shared/repositories/auth_repository.dart';
import '../network/api_client.dart';

enum AuthStatus { uninitialized, authenticating, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ApiClient _apiClient;

  AuthStatus _status = AuthStatus.uninitialized;
  Patient? _patient;
  String? _errorMessage;

  AuthProvider({
    required AuthRepository authRepository,
    required ApiClient apiClient,
  })  : _authRepository = authRepository,
        _apiClient = apiClient;

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  Patient? get patient => _patient;
  String? get errorMessage => _errorMessage;

  /// Check saved token on app launch
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final savedToken = await _apiClient.loadSavedToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        final profile = await _authRepository.getProfile();
        _patient = profile;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
      await _apiClient.setAuthToken(null);
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Register new patient
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );

      await _apiClient.setAuthToken(result.token);
      _patient = result.patient;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Login existing patient
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      await _apiClient.setAuthToken(result.token);
      _patient = result.patient;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Logout patient
  Future<void> logout() async {
    await _apiClient.setAuthToken(null);
    _patient = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
