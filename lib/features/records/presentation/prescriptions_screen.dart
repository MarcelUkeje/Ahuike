import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/prescription_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/models/prescription.dart';
import '../../../shared/widgets/app_animation.dart';
import '../../../shared/widgets/app_progress_animation.dart';
import '../../../shared/widgets/basil_icon.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPrescriptions();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    _fetchPrescriptions();
  }

  void _fetchPrescriptions() {
    final active = _tabController.index == 1 ? true : null;
    context.read<PrescriptionProvider>().loadPrescriptions(active: active);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PrescriptionProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prescriptions'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active Only'),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
      body: Consumer<PrescriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.prescriptions.isEmpty) {
            return const Center(child: AppProgressAnimation());
          }

          if (provider.errorMessage != null && provider.prescriptions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppAnimation(AppAnimationType.failure, size: 128),
                  const SizedBox(height: 12),
                  Text('Failed to load prescriptions', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _fetchPrescriptions,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          if (provider.prescriptions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppAnimation(AppAnimationType.welcome, size: 160),
                  const SizedBox(height: 16),
                  Text(
                    'No prescriptions found.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          final itemCount = provider.prescriptions.length + (provider.hasMore ? 1 : 0);

          return RefreshIndicator(
            onRefresh: () async => _fetchPrescriptions(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index == provider.prescriptions.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _PrescriptionCard(prescription: provider.prescriptions[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _PrescriptionCard extends StatefulWidget {
  final Prescription prescription;

  const _PrescriptionCard({required this.prescription});

  @override
  State<_PrescriptionCard> createState() => _PrescriptionCardState();
}

class _PrescriptionCardState extends State<_PrescriptionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final issuedDate = DateTime.tryParse(widget.prescription.issuedAt)?.toLocal() ?? DateTime.now();
    final formattedIssued = DateFormat('MMM dd, yyyy').format(issuedDate);

    final expiresDateStr = widget.prescription.expiresAt;
    final formattedExpires = expiresDateStr != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.tryParse(expiresDateStr)?.toLocal() ?? DateTime.now())
        : null;

    final isActive = widget.prescription.isActive;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.prescription.medicationName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFDCFCE7) : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Expired',
                    style: TextStyle(
                      color: isActive ? const Color(0xFF16A34A) : AppColors.textSecondary,
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
                  Row(
                    children: [
                      const BasilIcon('cross-solid', size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.prescription.dosage} · ${widget.prescription.frequency}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Issued: $formattedIssued${formattedExpires != null ? ' · Expires: $formattedExpires' : ''}',
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
                      'Duration',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.prescription.duration,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Instructions',
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
                        widget.prescription.instructions,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          height: 1.4,
                        ),
                      ),
                    ),
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
