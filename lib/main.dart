import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/navigation/app_shell.dart';
import 'core/network/api_client.dart';
import 'core/network/paystack_service.dart';
import 'core/providers/appointment_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/department_provider.dart';
import 'core/providers/doctor_provider.dart';
import 'core/providers/medical_record_provider.dart';
import 'core/providers/prescription_provider.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'shared/repositories/appointment_repository.dart';
import 'shared/repositories/auth_repository.dart';
import 'shared/repositories/department_repository.dart';
import 'shared/repositories/doctor_repository.dart';
import 'shared/repositories/medical_record_repository.dart';
import 'shared/repositories/prescription_repository.dart';
import 'shared/widgets/basil_icon.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (error) {
    if (kDebugMode) debugPrint('Environment file was not loaded: $error');
  }

  final apiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        // 1. Core Services
        Provider<ApiClient>.value(value: apiClient),

        // 2. Repositories
        ProxyProvider<ApiClient, AuthRepository>(
          update: (_, api, __) => RemoteAuthRepository(apiClient: api),
        ),
        ProxyProvider<ApiClient, DepartmentRepository>(
          update: (_, api, __) => DepartmentRepository(api),
        ),
        ProxyProvider<ApiClient, DoctorRepository>(
          update: (_, api, __) => DoctorRepository(api),
        ),
        ProxyProvider<ApiClient, AppointmentRepository>(
          update: (_, api, __) => AppointmentRepository(api),
        ),
        ProxyProvider<ApiClient, MedicalRecordRepository>(
          update: (_, api, __) => MedicalRecordRepository(api),
        ),
        ProxyProvider<ApiClient, PrescriptionRepository>(
          update: (_, api, __) => PrescriptionRepository(api),
        ),
        ProxyProvider<ApiClient, PaystackService>(
          update: (_, api, __) => PaystackService(api),
        ),

        // 3. Auth State Provider
        ChangeNotifierProxyProvider<AuthRepository, AuthProvider>(
          create:
              (ctx) => AuthProvider(
                authRepository: RemoteAuthRepository(apiClient: apiClient),
                apiClient: apiClient,
              )..checkAuthStatus(),
          update:
              (_, repo, prev) =>
                  prev ??
                  AuthProvider(authRepository: repo, apiClient: apiClient),
        ),

        // 4. Feature Domain Providers
        ChangeNotifierProxyProvider<DepartmentRepository, DepartmentProvider>(
          create: (_) => DepartmentProvider(DepartmentRepository(apiClient)),
          update: (_, repo, prev) => prev ?? DepartmentProvider(repo),
        ),
        ChangeNotifierProxyProvider<DoctorRepository, DoctorProvider>(
          create: (_) => DoctorProvider(DoctorRepository(apiClient)),
          update: (_, repo, prev) => prev ?? DoctorProvider(repo),
        ),
        ChangeNotifierProxyProvider<AppointmentRepository, AppointmentProvider>(
          create: (_) => AppointmentProvider(AppointmentRepository(apiClient)),
          update: (_, repo, prev) => prev ?? AppointmentProvider(repo),
        ),
        ChangeNotifierProxyProvider<
          MedicalRecordRepository,
          MedicalRecordProvider
        >(
          create:
              (_) => MedicalRecordProvider(MedicalRecordRepository(apiClient)),
          update: (_, repo, prev) => prev ?? MedicalRecordProvider(repo),
        ),
        ChangeNotifierProxyProvider<
          PrescriptionRepository,
          PrescriptionProvider
        >(
          create:
              (_) => PrescriptionProvider(PrescriptionRepository(apiClient)),
          update: (_, repo, prev) => prev ?? PrescriptionProvider(repo),
        ),
      ],
      child: const AhuikeApp(),
    ),
  );
}

class AhuikeApp extends StatelessWidget {
  const AhuikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ahuike Hospital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.uninitialized:
          case AuthStatus.authenticating:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BasilIcon(
                      'heartbeat-solid',
                      size: 64,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 24),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
          case AuthStatus.authenticated:
            return const AppShell();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}
