import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/appointment_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_progress_animation.dart';
import '../../../shared/widgets/app_animation.dart';
import '../../../shared/widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.appointments.isEmpty) {
            return const Center(child: AppProgressAnimation());
          }
          
          if (provider.errorMessage != null && provider.appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppAnimation(AppAnimationType.failure, size: 128),
                  const SizedBox(height: 12),
                  Text('Failed to load appointments', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => provider.loadAppointments(),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }
          
          if (provider.appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppAnimation(AppAnimationType.welcome, size: 160),
                  const SizedBox(height: 16),
                  Text(
                    'No appointments yet.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAppointments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.appointments.length,
              itemBuilder: (context, index) {
                return AppointmentCard(
                  appointment: provider.appointments[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
