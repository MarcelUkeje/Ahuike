import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/doctor_provider.dart';
import '../../../core/providers/appointment_provider.dart';
import '../../../shared/models/appointment.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/app_progress_animation.dart';
import '../../../shared/widgets/app_animation.dart';
import '../../../shared/widgets/basil_icon.dart';
import '../../../core/network/paystack_service.dart';
import '../../../core/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorProfileScreen extends StatefulWidget {
  final String doctorId;

  const DoctorProfileScreen({super.key, required this.doctorId});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  String? _selectedSlotId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().loadDoctorDetails(widget.doctorId);
    });
  }

  void _bookAppointment() async {
    if (_selectedSlotId == null) return;
    final doctorProvider = context.read<DoctorProvider>();
    final doctor = doctorProvider.selectedDoctor;
    if (doctor == null) return;

    final reasonController = TextEditingController();
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reason for Visit'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'e.g. Routine checkup, Headaches...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (shouldProceed != true) return;
    if (!mounted) return;

    final appointmentProvider = context.read<AppointmentProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    Appointment? appointment;
    try {
      appointment = await appointmentProvider.bookAppointment(
        doctorId: doctor.id,
        departmentId: doctor.departmentId,
        slotId: _selectedSlotId!,
        reasonForVisit: reasonController.text.trim(),
      );
    } finally {
      // Always close the loading dialog, even if unmounted or an error occurred
      if (mounted) Navigator.of(context).pop();
    }

    if (!mounted) return;

    if (!mounted) return;

    if (appointment != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => const Center(
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
        
        final paystackData = await PaystackService.initializePayment(
          email: email,
          amountInKobo: appointment.consultationFee * 100, // Naira to Kobo
          reference: uniqueRef,
        );

        final url = Uri.parse(paystackData['authorization_url']);
        await launchUrl(url, mode: LaunchMode.externalApplication);

        if (!mounted) return;
        Navigator.of(context).pop(); // Close initializing dialog

        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (_) => AlertDialog(
                title: const Text('Awaiting Payment'),
                content: const Text(
                  'Please complete the payment in your browser. This will automatically confirm once paid.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel / Close'),
                  ),
                ],
              ),
        );

        bool isSuccess = false;
        // Poll every 5 seconds for up to 5 minutes
        for (int i = 0; i < 60; i++) {
          await Future.delayed(const Duration(seconds: 5));
          if (!mounted) break;
          isSuccess = await PaystackService.verifyPayment(uniqueRef);
          if (isSuccess) break;
        }

        if (!mounted) return;
        Navigator.of(context).pop(); // Close waiting dialog

        if (isSuccess) {
          await appointmentProvider.confirmAppointment(appointment.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment Successful! Appointment Confirmed.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Return to previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment not completed or timed out.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop(); // Close initializing dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment initialization failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appointmentProvider.bookingError ?? 'Failed to book'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Consumer<DoctorProvider>(
        builder: (context, provider, child) {
          final doctor = provider.selectedDoctor;

          if (provider.isLoading || doctor == null) {
            return const Center(child: AppProgressAnimation());
          }
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppAnimation(AppAnimationType.failure, size: 128),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed:
                        () => provider.loadDoctorDetails(widget.doctorId),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage:
                            doctor.imageUrl != null
                                ? NetworkImage(doctor.imageUrl!)
                                : null,
                        child:
                            doctor.imageUrl == null
                                ? const BasilIcon(
                                  'user-solid',
                                  color: AppColors.primary,
                                  size: 50,
                                )
                                : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        doctor.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        doctor.specialty,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatBox(
                            label: 'Rating',
                            value: doctor.rating.toStringAsFixed(1),
                            icon: 'star-solid',
                            iconColor: AppColors.warning,
                          ),
                          _StatBox(
                            label: 'Reviews',
                            value: doctor.ratingCount.toString(),
                            icon: 'chat-outline',
                            iconColor: AppColors.secondary,
                          ),
                          _StatBox(
                            label: 'Fee',
                            value: '₦${doctor.consultationFee}',
                            icon: 'wallet-outline',
                            iconColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        doctor.bio ?? 'No biography available.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Available Slots',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (doctor.availableSlots == null ||
                          doctor.availableSlots!.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('No slots available for booking.'),
                        )
                      else
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              doctor.availableSlots!.map((slot) {
                                final isSelected = _selectedSlotId == slot.id;
                                final isBooked = slot.isBooked;
                                return InkWell(
                                  onTap:
                                      isBooked
                                          ? null
                                          : () {
                                            setState(() {
                                              _selectedSlotId = slot.id;
                                            });
                                          },
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMedium,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : (isBooked
                                                  ? AppColors.outline
                                                  : AppColors.surface),
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMedium,
                                      ),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : (isBooked
                                                    ? AppColors.outline
                                                    : AppColors.primary
                                                        .withValues(
                                                          alpha: 0.5,
                                                        )),
                                      ),
                                    ),
                                    child: Text(
                                      '${slot.slotDate} ${slot.startTime}',
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : (isBooked
                                                    ? AppColors.textSecondary
                                                    : AppColors.primary),
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        decoration:
                                            isBooked
                                                ? TextDecoration.lineThrough
                                                : null,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ), // Bottom padding
            ],
          );
        },
      ),
      bottomSheet: Consumer<DoctorProvider>(
        builder: (context, provider, child) {
          final doctor = provider.selectedDoctor;
          if (doctor == null || _selectedSlotId == null)
            return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: FilledButton(
                onPressed:
                    context.watch<AppointmentProvider>().isBooking
                        ? null
                        : _bookAppointment,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                  ),
                ),
                child:
                    context.watch<AppointmentProvider>().isBooking
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color iconColor;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: BasilIcon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
