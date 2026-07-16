import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/service_locator.dart';
import '../../../../theme/app_colors.dart';
import '../../../home/app_shell.dart';
import '../../domain/entities/income_engineer.dart';
import '../../domain/entities/income_entry.dart';
import '../cubit/incomes_cubit.dart';
import '../cubit/incomes_state.dart';

class IncomesPage extends StatelessWidget {
  const IncomesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<IncomesCubit>()..loadEngineers(),
      child: const _IncomesView(),
    );
  }
}

class _IncomesView extends StatelessWidget {
  const _IncomesView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocListener<IncomesCubit, IncomesState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage ||
              previous.submitSucceeded != current.submitSucceeded,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('حدث خطأ: ${state.errorMessage}')),
              );
            }
            if (state.submitSucceeded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تسجيل الدخل بنجاح')),
              );
            }
          },
          child: RefreshIndicator(
            onRefresh: () => context.read<IncomesCubit>().loadEngineers(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  _IncomeHeader(),
                  SizedBox(height: 24),
                  _ContentGrid(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IncomeHeader extends StatelessWidget {
  const _IncomeHeader();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'القائمة',
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () => AppShell.openDrawer(context),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'الدخل',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'تسجيل إيرادات المهندسين وربطها بالعنصر والتاريخ.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (!isWide) const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => context.read<IncomesCubit>().loadEngineers(),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('تحديث المهندسين'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            side: const BorderSide(color: AppColors.secondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContentGrid extends StatelessWidget {
  const _ContentGrid();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1024;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(flex: 4, child: _OverviewPanel()),
          SizedBox(width: 24),
          Expanded(flex: 8, child: _IncomeForm()),
        ],
      );
    }

    return Column(
      children: const [_OverviewPanel(), SizedBox(height: 24), _IncomeForm()],
    );
  }
}

class _OverviewPanel extends StatelessWidget {
  const _OverviewPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncomesCubit, IncomesState>(
      builder: (context, state) {
        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.payments_outlined, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text(
                      'ملخص الدخل',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'استخدم هذا النموذج لإضافة دخل جديد إلى النظام بنفس صيغة واجهة API.',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                _InfoTile(
                  icon: Icons.engineering_outlined,
                  label: 'المهندسون المتاحون',
                  value: state.isLoadingEngineers
                      ? 'جار التحميل'
                      : state.engineers.length.toString(),
                ),
                const SizedBox(height: 12),
                const _InfoTile(
                  icon: Icons.api_outlined,
                  label: 'نقطة الإرسال',
                  value: '/api/Income',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeForm extends StatefulWidget {
  const _IncomeForm();

  @override
  State<_IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<_IncomeForm> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _itemController = TextEditingController();
  final _dateController = TextEditingController();
  int? _engineerId;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toIso8601String();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    _itemController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.add_card_outlined, color: AppColors.secondary),
                  SizedBox(width: 8),
                  Text(
                    'تسجيل دخل جديد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildPriceField(),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'الوصف',
                hint: 'تفاصيل مختصرة عن الدخل',
                controller: _descriptionController,
                maxLines: 3,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'العنصر',
                hint: 'اسم العنصر أو الخدمة',
                controller: _itemController,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              _buildEngineerDropdown(),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return _buildTextField(
      label: 'السعر',
      hint: '0.00',
      controller: _priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        final price = double.tryParse(value?.trim() ?? '');
        if (price == null || price < 0) return 'أدخل سعرا صحيحا';
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return _buildTextField(
      label: 'التاريخ',
      hint: 'تاريخ ووقت الدخل',
      controller: _dateController,
      readOnly: true,
      onTap: _pickDate,
      validator: (value) =>
          DateTime.tryParse(value?.trim() ?? '') == null ? 'مطلوب' : null,
    );
  }

  Widget _buildEngineerDropdown() {
    return BlocBuilder<IncomesCubit, IncomesState>(
      builder: (context, state) {
        if (state.isLoadingEngineers) {
          return const SizedBox(
            height: 56,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('المهندس'),
            const SizedBox(height: 4),
            DropdownButtonFormField<int>(
              initialValue: _engineerId,
              isExpanded: true,
              items: state.engineers.map(_buildEngineerItem).toList(),
              onChanged: (value) => setState(() => _engineerId = value),
              validator: (value) => value == null ? 'اختر مهندسا' : null,
              decoration: _inputDecoration('اختر المهندس'),
            ),
          ],
        );
      },
    );
  }

  DropdownMenuItem<int> _buildEngineerItem(IncomeEngineer engineer) {
    return DropdownMenuItem<int>(
      value: engineer.id,
      child: Text(engineer.name, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildActions() {
    return BlocConsumer<IncomesCubit, IncomesState>(
      listenWhen: (previous, current) =>
          previous.submitSucceeded != current.submitSucceeded,
      listener: (context, state) {
        if (state.submitSucceeded) {
          _clearForm();
          context.read<IncomesCubit>().clearSubmitFlag();
        }
      },
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: state.isSubmitting ? null : _clearForm,
              child: const Text('إلغاء'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: state.isSubmitting ? null : _submit,
              icon: state.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined, size: 18),
              label: Text(state.isSubmitting ? 'جار الإرسال...' : 'إرسال'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.outlineVariant,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          style: const TextStyle(color: Colors.black),
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF7F9FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.secondary),
        borderRadius: BorderRadius.circular(4),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Future<void> _pickDate() async {
    final current = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'اختر التاريخ',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );
    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      helpText: 'اختر الوقت',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime?.hour ?? current.hour,
      pickedTime?.minute ?? current.minute,
    );
    _dateController.text = dateTime.toIso8601String();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final income = IncomeEntry(
      price: double.parse(_priceController.text.trim()),
      date: DateTime.parse(_dateController.text.trim()),
      description: _descriptionController.text.trim(),
      item: _itemController.text.trim(),
      engineerId: _engineerId!,
    );

    context.read<IncomesCubit>().submitIncome(income);
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _priceController.clear();
    _descriptionController.clear();
    _itemController.clear();
    _dateController.text = DateTime.now().toIso8601String();
    setState(() => _engineerId = null);
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}
