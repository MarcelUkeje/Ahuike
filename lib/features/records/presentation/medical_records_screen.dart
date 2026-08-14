import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/medical_record_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/models/medical_record.dart';
import '../../../shared/widgets/app_animation.dart';
import '../../../shared/widgets/app_progress_animation.dart';
import '../../../shared/widgets/basil_icon.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicalRecordProvider>().loadMedicalRecords();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MedicalRecordProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Consumer<MedicalRecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.records.isEmpty) {
            return const Center(child: AppProgressAnimation());
          }

          if (provider.errorMessage != null && provider.records.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppAnimation(AppAnimationType.failure, size: 128),
                  const SizedBox(height: 12),
                  Text('Failed to load medical records', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => provider.loadMedicalRecords(),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          if (provider.records.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppAnimation(AppAnimationType.welcome, size: 160),
                  const SizedBox(height: 16),
                  Text(
                    'No medical records found.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          final itemCount = provider.records.length + (provider.hasMore ? 1 : 0);

          return RefreshIndicator(
            onRefresh: () => provider.loadMedicalRecords(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index == provider.records.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _MedicalRecordCard(record: provider.records[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MedicalRecordCard extends StatefulWidget {
  final MedicalRecord record;

  const _MedicalRecordCard({required this.record});

  @override
  State<_MedicalRecordCard> createState() => _MedicalRecordCardState();
}

class _MedicalRecordCardState extends State<_MedicalRecordCard> {
  bool _isExpanded = false;

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'diagnosis':
        return Colors.teal;
      case 'lab_result':
        return Colors.purple;
      case 'imaging':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'diagnosis':
        return 'Diagnosis';
      case 'lab_result':
        return 'Lab Result';
      case 'imaging':
        return 'Imaging';
      default:
        return type.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(widget.record.recordType);
    final date = DateTime.tryParse(widget.record.createdAt)?.toLocal() ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd, yyyy · hh:mm a').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getTypeLabel(widget.record.recordType),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.record.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isExpanded ? AppColors.primaryContainer : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: BasilIcon(
                _isExpanded ? 'cross-solid' : 'plus-solid',
                size: 16,
                color: _isExpanded ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: AppColors.outline, height: 24),
                    const Text(
                      'Clinical Notes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.record.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    if (widget.record.diagnosis != null && widget.record.diagnosis!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Diagnosis Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.record.diagnosis!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (widget.record.treatmentPlan != null && widget.record.treatmentPlan!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Treatment Plan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: AppColors.primaryContainer),
                        ),
                        child: Text(
                          widget.record.treatmentPlan!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
