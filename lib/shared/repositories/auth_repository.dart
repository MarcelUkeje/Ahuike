import '../models/patient.dart';
import '../../core/network/api_client.dart';

class AuthResult {
  final String token;
  final Patient patient;

  AuthResult({required this.token, required this.patient});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      patient: Patient.fromJson(json['patient'] as Map<String, dynamic>),
    );
  }
}

abstract class AuthRepository {
  Future<String> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthResult> verifyOtp({
    required String userId,
    required String code,
    required String name,
  });

  Future<AuthResult> login({
    required String email,
    required String password,
  });

  Future<Patient> getProfile();
}

class RemoteAuthRepository implements AuthRepository {
  final ApiClient apiClient;

  RemoteAuthRepository({required this.apiClient});

  @override
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    return data['userId'] as String;
  }

  @override
  Future<AuthResult> verifyOtp({
    required String userId,
    required String code,
    required String name,
  }) async {
    final response = await apiClient.post(
      '/auth/verify-otp',
      body: {
        'userId': userId,
        'code': code,
        'name': name,
      },
    );
    return AuthResult.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return AuthResult.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Patient> getProfile() async {
    final response = await apiClient.get('/patients/me');
    return Patient.fromJson(response.data as Map<String, dynamic>);
  }
}
