import 'package:flutter/material.dart';

import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';

class InvoiceDetailsPage extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailsPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final device = invoice.device;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text('تفاصيل الفاتورة #${invoice.id}'),
          leading: IconButton(
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          shape: Border(
            bottom: BorderSide(color: colorScheme.outlineVariant),
          ),
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
                    _HeaderCard(invoice: invoice),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionCard(
                      title: 'بيانات الفاتورة',
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'رقم الفاتورة',
                            value: '#${invoice.id}',
                          ),
                          _InfoRow(
                            label: 'التاريخ',
                            value: _formatDateTime(invoice.date),
                          ),
                          _InfoRow(
                            label: 'رقم الجهاز',
                            value: invoice.deviceId.toString(),
                          ),
                          _InfoRow(
                            label: 'رقم العميل',
                            value: invoice.customerId.toString(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionCard(
                      title: 'بيانات الجهاز والعميل',
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'الجهاز',
                            value: _displayValue(device?.name, 'غير محدد'),
                          ),
                          _InfoRow(
                            label: 'الماركة',
                            value: _displayValue(device?.brand, 'غير محدد'),
                          ),
                          _InfoRow(
                            label: 'الموديل',
                            value: _displayValue(device?.model, 'غير محدد'),
                          ),
                          _InfoRow(
                            label: 'الرقم التسلسلي',
                            value: _displayValue(
                              device?.serialNumber,
                              'غير محدد',
                            ),
                          ),
                          _InfoRow(
                            label: 'العميل',
                            value: _displayValue(
                              device?.customerName,
                              'رقم ${invoice.customerId}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ItemsSection(items: invoice.items),
                    const SizedBox(height: AppSpacing.xl),
                    _TotalsCard(invoice: invoice),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Invoice invoice;

  const _HeaderCard({required this.invoice});

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
            child: Icon(
              Icons.receipt_long_outlined,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فاتورة #${invoice.id}',
                  style: AppTextStyles.pageTitle.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatDateTime(invoice.date),
                  style: AppTextStyles.body.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            _formatMoney(invoice.total),
            style: AppTextStyles.pageTitle.copyWith(color: colorScheme.secondary),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
            ),
            child: Text(
              title,
              style: AppTextStyles.sectionHeading.copyWith(color: colorScheme.onSurface),
            ),
          ),
          Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: child),
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
              style: AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsSection extends StatelessWidget {
  final List<InvoiceItem> items;

  const _ItemsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'عناصر الفاتورة',
      child: items.isEmpty
          ? Text(
              'لا توجد عناصر في هذه الفاتورة.',
              style: AppTextStyles.body.copyWith(color: colorScheme.onSurfaceVariant),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  color: colorScheme.surface,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'العنصر',
                          style: AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'الكمية',
                          style: AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'سعر الوحدة',
                          style: AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'الإجمالي',
                          style: AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
                for (var index = 0; index < items.length; index++)
                  _ItemRow(
                    item: items[index],
                    showDivider: index < items.length - 1,
                  ),
              ],
            ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final InvoiceItem item;
  final bool showDivider;

  const _ItemRow({required this.item, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colorScheme.outlineVariant))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayValue(item.sparePartName, 'مكون بدون اسم'),
                  style: AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'رقم القطعة: ${item.sparePartId ?? 0}',
                  style: AppTextStyles.label.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              item.quantity.toString(),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              _formatMoney(item.unitPrice),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              _formatMoney(item.total),
              style: AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final Invoice invoice;

  const _TotalsCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'الإجماليات',
      child: Column(
        children: [
          _TotalRow(label: 'قبل الخصم', value: invoice.subTotal),
          Divider(height: 24, color: colorScheme.outlineVariant),
          _TotalRow(label: 'الخصم', value: invoice.discount),
          Divider(height: 24, color: colorScheme.outlineVariant),
          _TotalRow(label: 'الإجمالي', value: invoice.total, strong: true),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool strong;

  const _TotalRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: strong
                ? AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface)
                : AppTextStyles.body.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
        Text(
          _formatMoney(value),
          style: strong
              ? AppTextStyles.sectionHeading.copyWith(
                  color: colorScheme.secondary,
                )
              : AppTextStyles.labelStrong.copyWith(color: colorScheme.onSurface),
        ),
      ],
    );
  }
}

String _displayValue(String? value, String fallback) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return fallback;
  return trimmed;
}

String _formatMoney(double value) => value.toStringAsFixed(2);

String _formatDateTime(DateTime date) {
  final local = date.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')} $hour:$minute';
}
