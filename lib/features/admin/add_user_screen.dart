import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/clients/http_client.dart';
import '../../di/service_locator.dart';
import '../../theme/app_colors.dart';
import '../roles/presentation/cubit/roles_cubit.dart';
import '../roles/presentation/cubit/roles_state.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _workPercentageController =
      TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _employDateController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _salaryController.dispose();
    _workPercentageController.dispose();
    _birthController.dispose();
    _employDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RolesCubit>()..fetch(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.primary),
            title: const Text(
              'إضافة مستخدم',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.person_add, color: AppColors.secondary),
                            SizedBox(width: 8),
                            Text(
                              'إضافة مستخدم جديد',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildField(
                          'الاسم الكامل',
                          'مثال: محمد أحمد',
                          controller: _nameController,
                        ),
                        _buildField(
                          'العنوان',
                          'مثال: المكلا',
                          controller: _locationController,
                        ),
                        _buildField(
                          'رقم الهاتف',
                          'مثال: 771234567',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildRoleField(),
                        _buildField(
                          'الراتب',
                          '0',
                          controller: _salaryController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        _buildField(
                          'نسبة العمل',
                          '0',
                          controller: _workPercentageController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        _buildDateField(
                          'تاريخ الميلاد',
                          'yyyy-MM-dd',
                          controller: _birthController,
                        ),
                        _buildDateField(
                          'تاريخ التوظيف',
                          'yyyy-MM-dd',
                          controller: _employDateController,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting
                                ? null
                                : () => _submitUser(context),
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: const Text('حفظ المستخدم'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: BlocBuilder<RolesCubit, RolesState>(
        builder: (context, state) {
          final roles = state is RolesLoaded ? state.roles : const [];
          if (roles.isEmpty) {
            return _buildField(
              'الدور الوظيفي',
              'مثال: مهندس',
              controller: _roleController,
            );
          }

          final values = roles.map((role) => role.name).toSet().toList()
            ..sort();
          final current = values.contains(_roleController.text)
              ? _roleController.text
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الدور الوظيفي',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: current,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF7F9FB),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.secondary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                items: values
                    .map(
                      (roleName) => DropdownMenuItem<String>(
                        value: roleName,
                        child: Text(roleName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) _roleController.text = value;
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint, {
    TextEditingController? controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF7F9FB),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(4),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.secondary),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    String label,
    String hint, {
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            readOnly: true,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF7F9FB),
              suffixIcon: const Icon(Icons.calendar_today_outlined),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(4),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.secondary),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(1990),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  controller.text = picked.toIso8601String().split('T').first;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitUser(BuildContext context) async {
    setState(() => _isSubmitting = true);

    final uri = Uri.parse('http://al-mumtazun-api.runasp.net/api/Users');
    final payload = {
      'fullName': _nameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'salary': _readDouble(_salaryController.text),
      'workPercentage': _readDouble(_workPercentageController.text),
      'birthDay': _dateOrToday(_birthController.text),
      'employeDate': _dateOrToday(_employDateController.text),
      'address': _locationController.text.trim(),
      'role': _roleController.text.trim(),
    };

    try {
      final resp = await getIt<AppHttpClient>().post(
        uri,
        headers: {'accept': 'text/plain', 'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (!context.mounted) return;

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة المستخدم بنجاح')),
        );
        Navigator.pop(context, true);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${resp.statusCode} ${resp.reasonPhrase}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل الاتصال: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  double _readDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
  }

  String _dateOrToday(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return DateTime.now().toIso8601String().split('T').first;
  }
}
