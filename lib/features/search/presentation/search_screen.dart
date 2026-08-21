import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/department_provider.dart';
import '../../../core/providers/doctor_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/models/department.dart';
import '../../../shared/models/doctor.dart';
import '../../../shared/widgets/basil_icon.dart';
import '../../doctors/presentation/doctor_list_screen.dart';
import '../../doctors/presentation/doctor_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    setState(() {
      _query = value.trim();
      _hasSearched = _query.isNotEmpty;
    });
    if (_query.isNotEmpty) {
      _debounce = Timer(const Duration(milliseconds: 500), () {
        context.read<DepartmentProvider>().searchDepartments(_query);
        context.read<DoctorProvider>().loadDoctors();
      });
    }
  }

  List<Doctor> _filteredDoctors(List<Doctor> doctors) {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return doctors.where((d) =>
      d.name.toLowerCase().contains(q) ||
      d.specialty.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Search', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  autofocus: false,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Doctors, specialties, departments…',
                    prefixIcon: const BasilIcon('search-outline'),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const BasilIcon('close-outline'),
                            onPressed: () {
                              _controller.clear();
                              setState(() { _query = ''; _hasSearched = false; });
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Results ──
          Expanded(
            child: _hasSearched ? _buildResults() : _buildSuggestions(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    const popularSpecialties = [
      ('🫀', 'Cardiology'),
      ('🦷', 'Dentistry'),
      ('🧠', 'Neurology'),
      ('🦴', 'Orthopedics'),
      ('👁️', 'Ophthalmology'),
      ('👶', 'Pediatrics'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        Text('Popular specialties', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: popularSpecialties.map((item) {
            return InkWell(
              onTap: () => _onSearch(item.$2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: Chip(
                avatar: Text(item.$1),
                label: Text(item.$2),
                backgroundColor: AppColors.primaryContainer,
                labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResults() {
    // Selector2 rebuilds only when the three selected values change reference,
    // avoiding unnecessary rebuilds from unrelated state (e.g. errorMessage).
    return Selector2<DepartmentProvider, DoctorProvider,
        ({List<Department> departments, List<Doctor> allDoctors, bool isLoading})>(
      selector: (_, deptP, docP) => (
        departments: deptP.departments,
        allDoctors: docP.doctors,
        isLoading: deptP.isLoading || docP.isLoading,
      ),
      builder: (context, data, _) {
        final departments = data.departments;
        final doctors = _filteredDoctors(data.allDoctors);

        if (data.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (departments.isEmpty && doctors.isEmpty) {
          return Center(
            child: Text(
              'No results for "$_query"',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          children: [
            if (departments.isNotEmpty) ...[
              Text('Departments', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...departments.map((dept) => _DepartmentResultTile(
                department: dept,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DoctorListScreen(department: dept)),
                ),
              )),
              const SizedBox(height: 16),
            ],
            if (doctors.isNotEmpty) ...[
              Text('Doctors', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...doctors.map((doc) => _DoctorResultTile(
                doctor: doc,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctorId: doc.id)),
                ),
              )),
            ],
          ],
        );
      },
    );
  }
}

// ── Result tile widgets ───────────────────────────────────────────────────────

class _DepartmentResultTile extends StatelessWidget {
  final Department department;
  final VoidCallback onTap;
  const _DepartmentResultTile({required this.department, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primaryContainer,
          child: BasilIcon('heartbeat-solid', color: AppColors.primary),
        ),
        title: Text(department.name),
        subtitle: Text(department.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const BasilIcon('arrow-right-outline', color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

class _DoctorResultTile extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  const _DoctorResultTile({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryContainer,
          backgroundImage: doctor.imageProvider,
          child: doctor.imageProvider == null
              ? const BasilIcon('user-solid', color: AppColors.primary)
              : null,
        ),
        title: Text(doctor.name),
        subtitle: Text(doctor.specialty),
        trailing: Text('₦${doctor.consultationFee}',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        onTap: onTap,
      ),
    );
  }
}
