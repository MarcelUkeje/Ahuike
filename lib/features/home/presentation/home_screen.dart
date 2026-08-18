import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/department_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_animation.dart';
import '../../../shared/widgets/app_progress_animation.dart';
import '../../../shared/widgets/basil_icon.dart';
import '../../../shared/widgets/department_card.dart';
import '../../doctors/presentation/doctor_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  void initState() {
    super.initState();
    // Load departments when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentProvider>().loadDepartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final patient = context.watch<AuthProvider>().patient;
    final patientName = patient?.name ?? 'Guest';
    final firstName = patientName.split(' ').first;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await context.read<DepartmentProvider>().loadDepartments();
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primaryContainer,
                        child: BasilIcon(
                          'user-solid',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getGreeting(), style: Theme.of(context).textTheme.bodySmall),
                            Text(firstName, style: const TextStyle(fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Notifications',
                        onPressed: () {},
                        icon: const BasilIcon('notification-outline'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Find your doctor\nand book an appointment', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Health Checkup', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text('Book a comprehensive checkup with our experts.', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const Text('🩺', style: TextStyle(fontSize: 54)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text('Specialties', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Consumer<DepartmentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.departments.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: AppProgressAnimation()),
                  );
                }
                if (provider.errorMessage != null && provider.departments.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppAnimation(
                            AppAnimationType.failure,
                            size: 128,
                          ),
                          const SizedBox(height: 12),
                          Text('Failed to load departments', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => provider.loadDepartments(),
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList.builder(
                    itemCount: provider.departments.length,
                    itemBuilder: (_, index) {
                      final dept = provider.departments[index];
                      return DepartmentCard(
                        department: dept,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DoctorListScreen(department: dept),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
