import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_colors.dart';
import '../../../../di/service_locator.dart';
import '../../domain/entities/compound.dart';
import '../cubit/compounds_cubit.dart';

/// تفاصيل العنصر (Compound) مع عرض تاريخ المبيعات والكمية وإضافة كمية.
class CompoundDetailsPage extends StatelessWidget {
  final Compound compound;

  const CompoundDetailsPage({Key? key, required this.compound})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocProvider<CompoundsCubit>(
      create: (_) => getIt<CompoundsCubit>(),
      child: Builder(
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              title: Text('تفاصيل العنصر #${compound.id}'),
              leading: IconButton(
                tooltip: 'رجوع',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              shape: Border(
                  bottom: BorderSide(color: colorScheme.outlineVariant)),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeaderCard(compound: compound),
                        const SizedBox(height: AppSpacing.xl),
                        _InfoRow(
                            label: 'الاسم', value: compound.name),
                        _InfoRow(
                            label: 'الوصف',
                            value: compound.description ?? '-'),
                        _InfoRow(
                            label: 'سعر البيع',
                            value: _formatMoney(compound.sellPrice)),
                        _InfoRow(
                            label: 'الكمية المتبقية',
                            value: compound.quantity.toString()),
                        _InfoRow(
                            label: 'التاريخ',
                            value: _formatDate(compound.date)),
                        const SizedBox(height: AppSpacing.xl),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _addQuantity(context),
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة كمية'),
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

  void _addQuantity(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('إضافة كمية'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'الكمية',
                hintText: 'أدخل الكمية المراد إضافتها',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () {
                  final value = int.tryParse(controller.text);
                  if (value != null && value > 0) {
                    Navigator.of(dialogContext).pop(value);
                  }
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return;

    final cubit = context.read<CompoundsCubit>();
    final updated =
        compound.copyWith(quantity: compound.quantity + result);
    final success = await cubit.editCompound(updated);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
          content:
              Text(success ? 'تمت إضافة الكمية' : 'فشل إضافة الكمية')),
    );
    if (success) Navigator.of(context).pop(updated);
  }
}

class _HeaderCard extends StatelessWidget {
  final Compound compound;

  const _HeaderCard({required this.compound});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: const Icon(Icons.inventory, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  compound.name,
                  style: AppTextStyles.pageTitle
                      .copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatDate(compound.date),
                  style: AppTextStyles.body
                      .copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            _formatMoney(compound.sellPrice),
            style: AppTextStyles.pageTitle
                .copyWith(color: colorScheme.secondary),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.labelStrong
                  .copyWith(color: colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body
                  .copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    date.toIso8601String().split('T').first;
String _formatMoney(double value) => value.toStringAsFixed(2);
