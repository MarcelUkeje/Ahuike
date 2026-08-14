import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/appointment_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/basil_icon.dart';
import '../../appointments/presentation/appointments_screen.dart';
import '../../records/presentation/medical_records_screen.dart';
import '../../records/presentation/prescriptions_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load appointments so stats are accurate even without visiting the Appointments tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final patient = context.watch<AuthProvider>().patient;
    final patientName = patient?.name ?? 'Patient';
    final patientEmail = patient?.email ?? 'Ahuike Hospital';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        children: [
          Text('My Profile', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // ── Avatar & Name ──────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: BasilIcon('user-solid', size: 48, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  patientName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$patientEmail · Patient',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Stats Row ─────────────────────────────────────────────
          Consumer<AppointmentProvider>(
            builder: (context, provider, _) {
              final total = provider.appointments.length;
              final pending = provider.appointments.where((a) => a.status == 'pending').length;
              final completed = provider.appointments.where((a) => a.status == 'completed').length;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCell(label: 'Total', value: total.toString()),
                    _Divider(),
                    _StatCell(label: 'Pending', value: pending.toString()),
                    _Divider(),
                    _StatCell(label: 'Completed', value: completed.toString()),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // ── My Records section ────────────────────────────────────
          Text('My Records', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          _ProfileTile(
            icon: 'calendar-solid',
            iconColor: AppColors.primary,
            title: 'Appointment History',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
            ),
          ),
          _ProfileTile(
            icon: 'document-outline',
            iconColor: AppColors.secondary,
            title: 'Medical Records',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MedicalRecordsScreen()),
            ),
          ),
          _ProfileTile(
            icon: 'cross-outline',
            iconColor: AppColors.warning,
            title: 'Prescription History',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrescriptionsScreen()),
            ),
          ),
          const SizedBox(height: 20),

          // ── Account section ───────────────────────────────────────
          Text('Account', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const _ProfileTile(icon: 'user-outline', iconColor: AppColors.primary, title: 'Personal Information'),
          const _ProfileTile(icon: 'notification-outline', iconColor: AppColors.primary, title: 'Notifications'),
          const _ProfileTile(icon: 'headset-outline', iconColor: AppColors.primary, title: 'Help & Support'),
          const _ProfileTile(icon: 'settings-outline', iconColor: AppColors.primary, title: 'Settings'),
          _ProfileTile(
            icon: 'cross-solid',
            iconColor: AppColors.error,
            title: 'Log Out',
            onTap: () async {
              final auth = context.read<AuthProvider>();
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out of your account?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Log Out', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                auth.logout();
              }
            },
          ),
          const SizedBox(height: 20),

          // ── Footer ───────────────────────────────────────────────
          Center(
            child: Text(
              'Ahuike v0.1.0 · Basil icons by Craftwork (CC BY 4.0)',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.primary.withValues(alpha: 0.2));
  }
}

class _ProfileTile extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final String title;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: BasilIcon(icon, color: iconColor, size: 22)),
        ),
        title: Text(title, style: TextStyle(color: iconColor == AppColors.error ? AppColors.error : null, fontWeight: iconColor == AppColors.error ? FontWeight.bold : null)),
        trailing: BasilIcon('arrow-right-outline', color: iconColor == AppColors.error ? AppColors.error : AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
