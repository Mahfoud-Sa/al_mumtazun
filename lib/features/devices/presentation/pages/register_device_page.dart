import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/entities/device.dart';
import '../cubit/devices_cubit.dart';
import '../cubit/devices_state.dart';

class RegisterDevicePage extends StatefulWidget {
  const RegisterDevicePage({super.key});

  @override
  State<RegisterDevicePage> createState() => _RegisterDevicePageState();
}

class _RegisterDevicePageState extends State<RegisterDevicePage> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _receivedByName = TextEditingController();
  final List<TextEditingController> _phoneControllers = [
    TextEditingController(),
  ];
  final _deviceNameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _problemController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _customerController.dispose();
    _receivedByName.dispose();
    for (final controller in _phoneControllers) {
      controller.dispose();
    }
    _deviceNameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _problemController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          elevation: 0,
          title: const Text(
            'تسجيل جهاز جديد',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          shape: const Border(
            bottom: BorderSide(color: AppColors.outlineVariant),
          ),
        ),
        body: BlocListener<DevicesCubit, DevicesState>(
          listenWhen: (previous, current) =>
              previous.submitSucceeded != current.submitSucceeded,
          listener: (context, state) {
            if (state.submitSucceeded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تسجيل الجهاز بنجاح')),
              );
              context.read<DevicesCubit>().clearSubmitFlag();
              Navigator.of(context).pop();
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              48,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _PageTitle(),
                      const SizedBox(height: AppSpacing.xxl),
                      _SectionCard(
                        title: "01.بيانات المستلم",
                        icon: Icons.import_contacts,
                        children: [
                          _FormField(
                            label: 'استلم بواسطة',
                            hint: 'الاسم الكامل   ',
                            controller: _receivedByName,
                            validator: _required,
                          ),
                          _DateField(
                            label: 'تاريخ الاستلام',
                            hint: 'اختر تاريخ استلام الجهاز',
                            controller: TextEditingController(
                              text: DateTime.now().toIso8601String().substring(
                                0,
                                10,
                              ),
                            ),
                            validator: _required,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      _SectionCard(
                        title: '02. بيانات العميل',
                        icon: Icons.person_outline,
                        children: [
                          _ResponsiveFields(
                            children: [
                              _FormField(
                                label: 'اسم العميل',
                                hint: 'الاسم الكامل أو اسم الشركة',
                                controller: _customerController,
                                validator: _required,
                              ),

                              // const _ReadOnlyInfo(
                              //   label: 'استلم بواسطة',
                              //   value: 'TechID: Admin_042',
                              //   icon: Icons.badge_outlined,
                              // ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _FormField(
                            label: 'رقم الهاتف',
                            hint: '+962 7 0000 0000',
                            controller: _phoneControllers.first,
                            keyboardType: TextInputType.phone,
                            validator: _required,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          for (
                            var i = 1;
                            i < _phoneControllers.length;
                            i++
                          ) ...[
                            _FormField(
                              label: 'رقم هاتف إضافي',
                              hint: '+962 7 0000 0000',
                              controller: _phoneControllers[i],
                              keyboardType: TextInputType.phone,
                              validator: _required,
                              trailing: IconButton(
                                tooltip: 'حذف الرقم',
                                onPressed: () => _removePhoneNumber(i),
                                icon: const Icon(Icons.delete_outline),
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: _addPhoneNumber,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('إضافة رقم هاتف'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionCard(
                        title: '03. معلومات الجهاز',
                        icon: Icons.devices_other_outlined,
                        children: [
                          _ResponsiveFields(
                            minFieldWidth: 220,
                            children: [
                              _FormField(
                                label: 'اسم الجهاز',
                                hint: 'مثال: راسم إشارة',
                                controller: _deviceNameController,
                                validator: _required,
                              ),
                              _FormField(
                                label: 'الماركة',
                                hint: 'مثال: PrecisionTech',
                                controller: _brandController,
                                validator: _required,
                              ),
                              _FormField(
                                label: 'الموديل / SKU',
                                hint: 'مثال: PX-900-V2',
                                controller: _modelController,
                                validator: _required,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionCard(
                        title: '04. التشخيص وملاحظات الاستلام',
                        icon: Icons.assignment_outlined,
                        children: [
                          _FormField(
                            label: 'وصف المشكلة',
                            hint:
                                'اكتب وصف العطل الميكانيكي أو البرمجي بالتفصيل...',
                            controller: _problemController,
                            maxLines: 4,
                            validator: _required,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _FormField(
                            label: 'ملاحظات داخلية إضافية',
                            hint: 'ملاحظات خاصة بفريق الصيانة (اختياري)...',
                            controller: _notesController,
                            maxLines: 2,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      BlocBuilder<DevicesCubit, DevicesState>(
                        builder: (context, state) {
                          return Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: state.isSubmitting ? null : _submit,
                              icon: state.isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                state.isSubmitting
                                    ? 'جاري التسجيل...'
                                    : 'تسجيل سجل الجهاز',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.outlineVariant,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl,
                                  vertical: AppSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.xs,
                                  ),
                                ),
                                textStyle: AppTextStyles.labelStrong,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        "بهذا النموذج يلتقط كل التفاصيل اللازمة لاستلام الجهاز بدقة، مما يسهل على فريق الصيانة فهم المشكلة وتقديم خدمة سريعة وفعالة.",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
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
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'مطلوب';
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final now = DateTime.now();
    final serialSuffix = now.millisecondsSinceEpoch.toString();
    final device = Device(
      id: 'device-${now.microsecondsSinceEpoch}',
      name: _deviceNameController.text.trim(),
      serialNumber: '#ENG-${serialSuffix.substring(serialSuffix.length - 4)}-N',
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      customerName: _customerController.text.trim(),
      phoneNumbers: _phoneControllers
          .map((controller) => controller.text.trim())
          .where((phone) => phone.isNotEmpty)
          .toList(),
      receivedBy: _receivedByName.text.trim(),
      status: DeviceStatus.received,
      problemDescription: _problemController.text.trim(),
      internalNotes: _notesController.text.trim(),
      createdAt: now,
    );

    context.read<DevicesCubit>().addDevice(device);
  }

  void _addPhoneNumber() {
    setState(() => _phoneControllers.add(TextEditingController()));
  }

  void _removePhoneNumber(int index) {
    if (_phoneControllers.length == 1) {
      _phoneControllers.first.clear();
      return;
    }

    final controller = _phoneControllers.removeAt(index);
    controller.dispose();
    setState(() {});
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.engineering_outlined,
          color: AppColors.secondary,
          size: 32,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تسجيل جهاز جديد',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'نموذج استلام دقيق لطلبات الصيانة الهندسية.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceContainer,
      elevation: 1,
      shadowColor: AppColors.shadow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              border: Border(
                bottom: BorderSide(color: AppColors.outlineVariant),
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.xs),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  final List<Widget> children;
  final double minFieldWidth;

  const _ResponsiveFields({required this.children, this.minFieldWidth = 280});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < minFieldWidth * 2) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.lg),
                children[i],
              ],
            ],
          );
        }

        return Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.lg,
          children: children
              .map(
                (child) => SizedBox(
                  width:
                      (constraints.maxWidth -
                          (AppSpacing.xl * (children.length.clamp(1, 3) - 1))) /
                      children.length.clamp(1, 3),
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final Widget? trailing;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                validator: validator,
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: AppColors.surfaceContainer,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.secondary),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.error),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.error),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              SizedBox(height: 48, child: trailing!),
            ],
          ],
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.labelStrong);
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const _DateField({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();

    DateTime initialDate = now;

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceContainer,
              onSurface: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

      controller.text = formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: true,
          onTap: () => _pickDate(context),
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surfaceContainer,
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              //color: AppColors.caption,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              borderSide: const BorderSide(color: AppColors.error, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
