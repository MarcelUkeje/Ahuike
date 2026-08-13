import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../models/appointment.dart';
import 'basil_icon.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.appointment, this.onTap});

  final Appointment appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isPending = appointment.status.toLowerCase() == 'pending';
    final bool isCompleted = appointment.status.toLowerCase() == 'completed';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending 
                            ? AppColors.warning.withValues(alpha: 0.1) 
                            : isCompleted ? AppColors.secondary.withValues(alpha: 0.1) : AppColors.outline,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appointment.status.toUpperCase(),
                        style: TextStyle(
                          color: isPending ? AppColors.warning : isCompleted ? AppColors.secondary : AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Booking ID: ${appointment.id.substring(0, 8)}...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      child: const Center(
                        child: BasilIcon('calendar-solid', color: AppColors.primary, size: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.reasonForVisit,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fee: ₦${appointment.consultationFee}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  children: [
                    const BasilIcon('clock-outline', size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Created: ${DateTime.tryParse(appointment.createdAt)?.toLocal().toString().split('.')[0] ?? appointment.createdAt}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
