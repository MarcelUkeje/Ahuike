import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/department_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _bioController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _feeController = TextEditingController();
  final _imageController = TextEditingController();
  
  String? _selectedDepartmentId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentProvider>().loadDepartments();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _bioController.dispose();
    _qualificationsController.dispose();
    _feeController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _addDoctor() async {
    if (!_formKey.currentState!.validate() || _selectedDepartmentId == null) {
      if (_selectedDepartmentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a department')));
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final qualifications = _qualificationsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final fee = int.tryParse(_feeController.text) ?? 0;

      final body = {
        'name': _nameController.text.trim(),
        'specialty': _specialtyController.text.trim(),
        'departmentId': _selectedDepartmentId,
        'bio': _bioController.text.trim(),
        'qualifications': qualifications,
        'consultationFee': fee,
        'imageUrl': _imageController.text.trim().isNotEmpty ? _imageController.text.trim() : null,
      };

      final apiClient = ApiClient();
      await apiClient.post(
        '/doctors', 
        body: body,
        headers: {'x-admin-password': 'admin123'},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doctor added successfully!'), backgroundColor: Colors.green));
      
      // Clear form
      _nameController.clear();
      _specialtyController.clear();
      _bioController.clear();
      _qualificationsController.clear();
      _feeController.clear();
      _imageController.clear();
      setState(() => _selectedDepartmentId = null);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding doctor: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add New Doctor', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Fill in the details below to add a new doctor to the hospital registry.', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', hintText: 'e.g. Dr. John Doe', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: 16),
                
                // Specialty
                TextFormField(
                  controller: _specialtyController,
                  decoration: const InputDecoration(labelText: 'Specialty', hintText: 'e.g. Neurologist', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: 16),
                
                // Department
                Consumer<DepartmentProvider>(
                  builder: (context, provider, child) {
                    return DropdownButtonFormField<String>(
                      value: _selectedDepartmentId,
                      decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                      items: provider.departments.map((dept) {
                        return DropdownMenuItem(value: dept.id, child: Text(dept.name));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedDepartmentId = val),
                      validator: (v) => v == null ? 'Please select a department' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Bio
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Biography', hintText: 'Short summary about the doctor...', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: 16),
                
                // Qualifications
                TextFormField(
                  controller: _qualificationsController,
                  decoration: const InputDecoration(labelText: 'Qualifications (comma separated)', hintText: 'e.g. MBBS, MD, PhD', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Required field' : null,
                ),
                const SizedBox(height: 16),
                
                // Consultation Fee
                TextFormField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Consultation Fee (₦)', hintText: 'e.g. 20000', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v!.isEmpty) return 'Required field';
                    if (int.tryParse(v) == null) return 'Must be a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Image URL / Path
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor Photo Asset Path (Optional)', 
                    hintText: 'e.g. assets/images/my_doctor.png', 
                    border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addDoctor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Add Doctor to Registry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
