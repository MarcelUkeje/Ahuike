import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/doctor_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/department.dart';
import '../../../shared/widgets/app_progress_animation.dart';
import '../../../shared/widgets/app_animation.dart';
import '../../../shared/widgets/doctor_card.dart';
import 'doctor_profile_screen.dart';

class DoctorListScreen extends StatefulWidget {
  final Department department;

  const DoctorListScreen({super.key, required this.department});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().loadDoctors(departmentId: widget.department.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.department.name),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Consumer<DoctorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.doctors.isEmpty) {
            return const Center(child: AppProgressAnimation());
          }
          if (provider.errorMessage != null && provider.doctors.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppAnimation(AppAnimationType.failure, size: 128),
                  const SizedBox(height: 12),
                  Text('Failed to load doctors', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => provider.loadDoctors(departmentId: widget.department.id),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }
          if (provider.doctors.isEmpty) {
            return Center(
              child: Text(
                'No doctors found for this department.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.doctors.length,
            itemBuilder: (context, index) {
              final doctor = provider.doctors[index];
              return DoctorCard(
                doctor: doctor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DoctorProfileScreen(doctorId: doctor.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
