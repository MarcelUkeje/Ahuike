import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../models/appointment.dart';
import 'basil_icon.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../core/network/paystack_service.dart';
import 'dart:async';
import '../../core/network/notification_helper.dart';
import '../../core/providers/appointment_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/doctor_provider.dart';

class AppointmentCard extends StatefulWidget {
  const AppointmentCard({super.key, required this.appointment});

  final Appointment appointment;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final bool isPending = appointment.status.toLowerCase() == 'pending';
    final bool isConfirmed = appointment.status.toLowerCase() == 'confirmed';
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
          onTap: () => _showDetailsDialog(context),
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
                            : isConfirmed ? Colors.green.withValues(alpha: 0.1) 
                            : isCompleted ? AppColors.secondary.withValues(alpha: 0.1) : AppColors.outline,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appointment.status.toUpperCase(),
                        style: TextStyle(
                          color: isPending ? AppColors.warning : isConfirmed ? Colors.green : isCompleted ? AppColors.secondary : AppColors.textSecondary,
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
                    Expanded(
                      child: Text(
                        _formatDate(appointment.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  String _formatDate(String isoString) {
    final date = DateTime.tryParse(isoString)?.toLocal();
    if (date == null) {
      // If the backend hasn't updated yet and still returns the raw GMT string, just strip GMT
      return isoString.replaceAll(RegExp(r'\s*GMT.*$'), ''); 
    }
    return DateFormat('E MMM d y h:mm:ss a').format(date);
  }

  void _showDetailsDialog(BuildContext context) {
    final appointment = widget.appointment;
    final isPending = appointment.status.toLowerCase() == 'pending';
    
    // Look up the doctor to show their details
    final doctors = context.read<DoctorProvider>().doctors;
    final doctorInfo = doctors.where((d) => d.id == appointment.doctorId).firstOrNull;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Appointment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking ID:', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            Text(appointment.id),
            const SizedBox(height: 12),
            if (doctorInfo != null) ...[
              Text('Doctor:', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              Text('Dr. ${doctorInfo.name}'),
              Text(doctorInfo.specialty, style: const TextStyle(fontSize: 12, color: AppColors.primary)),
              const SizedBox(height: 12),
            ],
            Text('Reason for Visit:', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            Text(appointment.reasonForVisit),
            const SizedBox(height: 12),
            Text('Status:', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            Text(appointment.status.toUpperCase()),
            const SizedBox(height: 12),
            Text('Created At:', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            Text(_formatDate(appointment.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _confirmCompleteAppointment(context, appointment.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Complete Appointment'),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          if (isPending)
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _initiatePayment(context);
              },
              child: const Text('Pay Now'),
            ),
        ],
      ),
    );
  }

  void _confirmCompleteAppointment(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Appointment'),
        content: const Text('Are you sure you have honoured this appointment?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AppointmentProvider>().deleteAppointment(id).then((_) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment completed and removed.')));
              }).catchError((e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to complete appointment.')));
              });
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _initiatePayment(BuildContext context) async {
    final appointment = widget.appointment;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text("Initializing Secure Payment..."),
          ),
        ),
      ),
    );

    try {
      final authProvider = context.read<AuthProvider>();
      final email = authProvider.patient?.email ?? 'patient@ahuike.org';
      final uniqueRef = '${appointment.id}_${DateTime.now().millisecondsSinceEpoch}';
      final paystackService = context.read<PaystackService>();
      
      final paystackData = await paystackService.initializePayment(
        email: email,
        amountInKobo: appointment.consultationFee * 100,
        reference: uniqueRef, // Use unique reference to avoid duplicate error
      );

      final url = Uri.parse(paystackData['authorization_url']);
      
      await NotificationHelper.init();
      final timer = Timer(const Duration(minutes: 9), () {
        NotificationHelper.showPaymentWarning();
      });

      await launchUrl(url, mode: LaunchMode.externalApplication);
      timer.cancel();

      if (!mounted) return;
      Navigator.of(context).pop(); // Close initializing dialog

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Awaiting Payment'),
          content: const Text('Please complete the payment in your browser. This will automatically confirm once paid.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel / Close'),
            ),
          ],
        ),
      );

      bool isSuccess = false;
      for (int i = 0; i < 60; i++) {
        await Future.delayed(const Duration(seconds: 5));
        if (!mounted) break;
        isSuccess = await paystackService.verifyPayment(uniqueRef);
        if (isSuccess) break;
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // Close waiting dialog

      if (isSuccess) {
        await context.read<AppointmentProvider>().confirmAppointment(appointment.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful! Appointment Confirmed.'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment not completed or timed out.'), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close initializing dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment initialization failed: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}
