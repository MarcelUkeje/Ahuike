import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahuike/core/network/api_client.dart';
import 'package:ahuike/core/providers/auth_provider.dart';
import 'package:ahuike/shared/models/patient.dart';
import 'package:ahuike/shared/repositories/auth_repository.dart';
import 'package:ahuike/features/auth/presentation/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders Ahuike LoginScreen when unauthenticated', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final apiClient = ApiClient();
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiClient>.value(value: apiClient),
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(
              authRepository: FakeAuthRepository(),
              apiClient: apiClient,
            ),
          ),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Ahuike Hospital'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthResult> login({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<String> register({required String name, required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> verifyOtp({required String userId, required String code, required String name}) async {
    throw UnimplementedError();
  }

  @override
  Future<Patient> getProfile() async {
    throw UnimplementedError();
  }
}
