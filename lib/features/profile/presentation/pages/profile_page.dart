import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/service_locator.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/profile_user.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          previous.error != current.error ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        final message = state.error ?? state.successMessage;
        if (message == null || message.isEmpty) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primary),
          title: const Text(
            'الملف الشخصي',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () => context.read<ProfileCubit>().refreshProfile(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.isLoading && state.profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = state.profile;
            if (profile == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.error ?? 'لا توجد بيانات للملف الشخصي.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<ProfileCubit>().refreshProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 900;
                    final summary = _ProfileSummary(profile: profile);
                    final details = _ProfileDetails(
                      profile: profile,
                      isSaving: state.isSavingProfile,
                    );
                    final password = _PasswordPanel(
                      isSaving: state.isSavingPassword,
                    );

                    if (!isWide) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          summary,
                          const SizedBox(height: 16),
                          details,
                          const SizedBox(height: 16),
                          password,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 320, child: summary),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              details,
                              const SizedBox(height: 16),
                              password,
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  final ProfileUser profile;

  const _ProfileSummary({required this.profile});

  @override
  Widget build(BuildContext context) {
    final imageUrl = profile.profileImageUrl;

    return _Panel(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primary,
            backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
            child: imageUrl == null
                ? Text(
                    _initials(profile.fullName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName.isEmpty ? 'مستخدم' : profile.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            profile.role.isEmpty ? '-' : profile.role,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _StatusPill(isActive: profile.isActive),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showImageUrlDialog(context, imageUrl),
              icon: const Icon(Icons.image_outlined),
              label: const Text('تحديث صورة الملف الشخصي'),
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ').where((part) => part.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0]).join();
    return initials.isEmpty ? 'U' : initials.toUpperCase();
  }

  static Future<void> _showImageUrlDialog(
    BuildContext context,
    String? currentUrl,
  ) async {
    final controller = TextEditingController(text: currentUrl ?? '');

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('صورة الملف الشخصي'),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: 'رابط الصورة',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                controller.clear();
                Navigator.pop(dialogContext, true);
              },
              child: const Text('حذف'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || shouldSave != true) return;
    await context.read<ProfileCubit>().updateProfileImageUrl(
      controller.text.trim(),
    );
  }
}

class _ProfileDetails extends StatefulWidget {
  final ProfileUser profile;
  final bool isSaving;

  const _ProfileDetails({required this.profile, required this.isSaving});

  @override
  State<_ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<_ProfileDetails> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _birthDayController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _addressController = TextEditingController(text: widget.profile.address);
    _birthDayController = TextEditingController(text: widget.profile.birthDay);
  }

  @override
  void didUpdateWidget(covariant _ProfileDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _fullNameController.text = widget.profile.fullName;
      _phoneController.text = widget.profile.phoneNumber;
      _addressController.text = widget.profile.address;
      _birthDayController.text = widget.profile.birthDay;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.person_outline,
            title: 'بيانات المستخدم',
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'الرقم', value: widget.profile.id?.toString() ?? '-'),
          _InfoRow(label: 'الدور', value: widget.profile.role),
          _InfoRow(label: 'تاريخ التوظيف', value: widget.profile.employeDate),
          const SizedBox(height: 8),
          _ProfileTextField(
            controller: _fullNameController,
            label: 'الاسم الكامل',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _ProfileTextField(
            controller: _phoneController,
            label: 'رقم الهاتف',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _ProfileTextField(
            controller: _addressController,
            label: 'العنوان',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          _ProfileTextField(
            controller: _birthDayController,
            label: 'تاريخ الميلاد',
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: _pickBirthDay,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.isSaving
                  ? null
                  : () => context.read<ProfileCubit>().updateProfile(
                      fullName: _fullNameController.text,
                      phoneNumber: _phoneController.text,
                      address: _addressController.text,
                      birthDay: _birthDayController.text,
                    ),
              icon: widget.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('حفظ بيانات الملف الشخصي'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBirthDay() async {
    final parsed = DateTime.tryParse(_birthDayController.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: parsed ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;
    _birthDayController.text = picked.toUtc().toIso8601String();
  }
}

class _PasswordPanel extends StatefulWidget {
  final bool isSaving;

  const _PasswordPanel({required this.isSaving});

  @override
  State<_PasswordPanel> createState() => _PasswordPanelState();
}

class _PasswordPanelState extends State<_PasswordPanel> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.lock_outline,
            title: 'تغيير كلمة المرور',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _currentPasswordController,
            obscureText: _obscureCurrentPassword,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'كلمة المرور الحالية',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                },
                icon: Icon(
                  _obscureCurrentPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'كلمة المرور الجديدة',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'تأكيد كلمة المرور',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.isSaving
                  ? null
                  : () async {
                      await context.read<ProfileCubit>().changePassword(
                        currentPassword: _currentPasswordController.text,
                        newPassword: _newPasswordController.text,
                        confirmPassword: _confirmPasswordController.text,
                      );

                      if (!context.mounted) return;
                      final state = context.read<ProfileCubit>().state;
                      if (state.error == null) {
                        _currentPasswordController.clear();
                        _newPasswordController.clear();
                        _confirmPasswordController.clear();
                      }
                    },
              icon: widget.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('حفظ كلمة المرور'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PanelTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? '-' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(label),
                const SizedBox(height: 4),
                _Value(displayValue),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 160, child: _Label(label)),
              Expanded(child: _Value(displayValue)),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool readOnly;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.readOnly = false,
    this.keyboardType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Value extends StatelessWidget {
  final String text;

  const _Value(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: AppColors.primary));
  }
}

class _StatusPill extends StatelessWidget {
  final bool isActive;

  const _StatusPill({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.green : AppColors.outline;
    final bg = isActive ? AppColors.greenBg : AppColors.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'نشط' : 'غير نشط',
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
