import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/service_locator.dart';
import '../../../../theme/app_colors.dart';
import '../../../home/home_shell.dart';
import '../../domain/entities/compound.dart';
import '../cubit/compounds_cubit.dart';
import '../cubit/compounds_state.dart';

class CompoundsPage extends StatelessWidget {
  const CompoundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CompoundsCubit>()..fetch(),
      child: const _CompoundsView(),
    );
  }
}

class _CompoundsView extends StatelessWidget {
  const _CompoundsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () => context.read<CompoundsCubit>().fetch(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _CompoundsHeader(),
                SizedBox(height: 24),
                _SummaryRow(),
                SizedBox(height: 24),
                _ContentGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompoundsHeader extends StatelessWidget {
  const _CompoundsHeader();

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
              onPressed: () => HomeShell.openDrawer(context),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'القطع',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'إدارة سجلات المكونات وأسعار الخلايا والتواريخ المعتمدة.',
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
          onPressed: () => context.read<CompoundsCubit>().fetch(),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('تحديث'),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompoundsCubit, CompoundsState>(
      builder: (context, state) {
        final compounds = state is CompoundsLoaded
            ? state.compounds
            : <Compound>[];
        final totalCount = state is CompoundsLoaded
            ? state.totalCount
            : compounds.length;
        final totalValue = compounds.fold<double>(
          0,
          (sum, compound) => sum + compound.cellPrice,
        );
        final average = compounds.isEmpty ? 0 : totalValue / compounds.length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final cards = [
              _SummaryCard(
                icon: Icons.category_outlined,
                label: 'إجمالي المركبات',
                value: totalCount.toString(),
              ),
              _SummaryCard(
                icon: Icons.payments_outlined,
                label: 'إجمالي سعر الخلية',
                value: totalValue.toStringAsFixed(2),
              ),
              _SummaryCard(
                icon: Icons.analytics_outlined,
                label: 'متوسط سعر الخلية',
                value: average.toStringAsFixed(2),
              ),
            ];

            if (isWide) {
              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            }

            return Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  cards[i],
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.secondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          Expanded(flex: 4, child: _CompoundForm()),
          SizedBox(width: 24),
          Expanded(flex: 8, child: _CompoundsTable()),
        ],
      );
    }

    return Column(
      children: const [
        _CompoundForm(),
        SizedBox(height: 24),
        _CompoundsTable(),
      ],
    );
  }
}

class _CompoundForm extends StatefulWidget {
  const _CompoundForm();

  @override
  State<_CompoundForm> createState() => _CompoundFormState();
}

class _CompoundFormState extends State<_CompoundForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(DateTime.now());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
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
                  Icon(Icons.add_box_outlined, color: AppColors.secondary),
                  SizedBox(width: 8),
                  Text(
                    'إضافة مركب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'الاسم',
                hint: 'اسم المكون',
                controller: _nameController,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'الوصف',
                hint: 'وصف اختياري',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'سعر الخلية',
                hint: '0.00',
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final price = double.tryParse(value?.trim() ?? '');
                  if (price == null || price < 0) return 'أدخل سعرا صحيحا';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDateField(context),
              const SizedBox(height: 24),
              BlocBuilder<CompoundsCubit, CompoundsState>(
                builder: (context, state) {
                  final isSubmitting =
                      state is CompoundsLoaded && state.isSubmitting;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSubmitting ? null : () => _submit(context),
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined, size: 18),
                      label: Text(isSubmitting ? 'جار الحفظ...' : 'حفظ المركب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.outlineVariant,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
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
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.error),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.error),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    return _buildTextField(
      label: 'التاريخ',
      hint: 'سنة-شهر-يوم',
      controller: _dateController,
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate:
              DateTime.tryParse(_dateController.text) ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          helpText: 'اختر التاريخ',
          cancelText: 'إلغاء',
          confirmText: 'اختيار',
        );
        if (picked != null) {
          _dateController.text = _formatDate(picked);
        }
      },
      validator: (value) =>
          DateTime.tryParse(value?.trim() ?? '') == null ? 'مطلوب' : null,
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final compound = Compound(
      id: 0,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      cellPrice: double.parse(_priceController.text.trim()),
      date: DateTime.parse(_dateController.text.trim()),
    );

    final success = await context.read<CompoundsCubit>().addCompound(compound);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'تم حفظ المركب بنجاح' : 'فشل حفظ المركب'),
      ),
    );

    if (success) {
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _dateController.text = _formatDate(DateTime.now());
    }
  }

  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}

class _CompoundsTable extends StatelessWidget {
  const _CompoundsTable();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المركبات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                BlocBuilder<CompoundsCubit, CompoundsState>(
                  builder: (context, state) {
                    final count = state is CompoundsLoaded
                        ? state.totalCount
                        : 0;
                    return Chip(
                      label: Text('الإجمالي $count'),
                      backgroundColor: const Color(0xFFD8E3FA),
                      side: BorderSide.none,
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          BlocBuilder<CompoundsCubit, CompoundsState>(
            builder: (context, state) {
              if (state is CompoundsLoading || state is CompoundsInitial) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is CompoundsError) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => context.read<CompoundsCubit>().fetch(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              final compounds = (state as CompoundsLoaded).compounds;
              if (compounds.isEmpty) {
                return Column(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'لا توجد مركبات.',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: AppColors.outlineVariant),
                    _CompoundsPaginationFooter(),
                  ],
                );
              }

              return Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AppColors.surfaceContainerLow,
                      ),
                      columnSpacing: 32,
                      columns: const [
                        DataColumn(label: Text('الرقم')),
                        DataColumn(label: Text('الاسم')),
                        DataColumn(label: Text('الوصف')),
                        DataColumn(label: Text('سعر الخلية')),
                        DataColumn(label: Text('التاريخ')),
                      ],
                      rows: compounds.map((compound) {
                        return DataRow(
                          cells: [
                            DataCell(Text(compound.id.toString())),
                            DataCell(
                              Text(
                                compound.name.isEmpty ? '-' : compound.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 240,
                                child: Text(
                                  compound.description?.isNotEmpty == true
                                      ? compound.description!
                                      : '-',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(compound.cellPrice.toStringAsFixed(2)),
                            ),
                            DataCell(Text(_formatDate(compound.date))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.outlineVariant),
                  const _CompoundsPaginationFooter(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}

class _CompoundsPaginationFooter extends StatelessWidget {
  const _CompoundsPaginationFooter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompoundsCubit, CompoundsState>(
      builder: (context, state) {
        final loaded = state is CompoundsLoaded ? state : null;
        final page = loaded?.page ?? 1;
        final size = loaded?.size ?? CompoundsCubit.defaultPageSize;
        final totalCount = loaded?.totalCount ?? 0;
        final totalPages = loaded?.totalPages ?? 1;
        final currentCount = loaded?.compounds.length ?? 0;
        final start = totalCount == 0 ? 0 : ((page - 1) * size) + 1;
        final end = totalCount == 0
            ? 0
            : (start + currentCount - 1).clamp(start, totalCount);
        final canGoPrevious = loaded != null && page > 1;
        final canGoNext = loaded != null && page < totalPages;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final summary = Text(
                'عرض $start-$end من $totalCount | الصفحة $page من $totalPages',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              );
              final controls = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PaginationButton(
                    icon: Icons.chevron_right,
                    onPressed: canGoPrevious
                        ? () => context.read<CompoundsCubit>().previousPage()
                        : null,
                  ),
                  const SizedBox(width: 8),
                  _PaginationButton(
                    icon: Icons.chevron_left,
                    onPressed: canGoNext
                        ? () => context.read<CompoundsCubit>().nextPage()
                        : null,
                  ),
                ],
              );

              if (constraints.maxWidth < 420) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [summary, const SizedBox(height: 12), controls],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [summary, controls],
              );
            },
          ),
        );
      },
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PaginationButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}
