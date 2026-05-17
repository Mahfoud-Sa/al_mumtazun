import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/service_locator.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../home/home_shell.dart';
import '../../domain/entities/invoice.dart';
import '../cubit/invoices_cubit.dart';
import '../cubit/invoices_state.dart';

class InvoiceIndexPage extends StatelessWidget {
  const InvoiceIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InvoicesCubit>()..fetch(refresh: true),
      child: const _InvoiceView(),
    );
  }
}

class _InvoiceView extends StatefulWidget {
  const _InvoiceView();

  @override
  State<_InvoiceView> createState() => _InvoiceViewState();
}

class _InvoiceViewState extends State<_InvoiceView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 360) {
      context.read<InvoicesCubit>().fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocListener<InvoicesCubit, InvoicesState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          child: RefreshIndicator(
            onRefresh: () => context.read<InvoicesCubit>().fetch(refresh: true),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                96,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  _InvoicesHeader(),
                  SizedBox(height: AppSpacing.xl),
                  _InvoicesSummary(),
                  SizedBox(height: AppSpacing.xl),
                  _InvoicesList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoicesHeader extends StatelessWidget {
  const _InvoicesHeader();

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
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الفواتير', style: AppTextStyles.pageTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'متابعة فواتير الأجهزة والخصومات والإجماليات.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (!isWide) const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: () => context.read<InvoicesCubit>().fetch(refresh: true),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('تحديث'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            side: const BorderSide(color: AppColors.secondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
          ),
        ),
      ],
    );
  }
}

class _InvoicesSummary extends StatelessWidget {
  const _InvoicesSummary();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoicesCubit, InvoicesState>(
      builder: (context, state) {
        final invoices = state.invoices;
        final subTotal = invoices.fold<double>(
          0,
          (sum, invoice) => sum + invoice.subTotal,
        );
        final total = invoices.fold<double>(
          0,
          (sum, invoice) => sum + invoice.total,
        );
        final discount = invoices.fold<double>(
          0,
          (sum, invoice) => sum + invoice.discount,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            final cards = [
              _SummaryCard(
                icon: Icons.receipt_long_outlined,
                label: 'عدد الفواتير',
                value: state.totalCount == 0
                    ? invoices.length.toString()
                    : state.totalCount.toString(),
              ),
              _SummaryCard(
                icon: Icons.payments_outlined,
                label: 'الإجمالي',
                value: _formatMoney(total),
              ),
              _SummaryCard(
                icon: Icons.discount_outlined,
                label: 'الخصومات',
                value: _formatMoney(discount),
              ),
              _SummaryCard(
                icon: Icons.summarize_outlined,
                label: 'قبل الخصم',
                value: _formatMoney(subTotal),
              ),
            ];

            if (isWide) {
              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.md),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            }

            return Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
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

class _InvoicesList extends StatelessWidget {
  const _InvoicesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoicesCubit, InvoicesState>(
      builder: (context, state) {
        if (state.isLoading && state.invoices.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.invoices.isEmpty) {
          return _EmptyState(
            isError: state.errorMessage != null,
            message: state.errorMessage ?? 'لا توجد فواتير حتى الآن.',
          );
        }

        return Column(
          children: [
            for (final invoice in state.invoices) ...[
              _InvoiceCard(invoice: invoice),
              const SizedBox(height: AppSpacing.md),
            ],
            if (state.isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(),
              ),
          ],
        );
      },
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final deviceName = invoice.device?.name.trim();
    final customerName = invoice.device?.customerName.trim();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فاتورة #${invoice.id}',
                      style: AppTextStyles.labelStrong,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatDate(invoice.date),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatMoney(invoice.total),
                style: AppTextStyles.sectionHeading.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _InfoChip(
                icon: Icons.precision_manufacturing_outlined,
                label: 'الجهاز',
                value: _displayValue(deviceName, 'رقم ${invoice.deviceId}'),
              ),
              _InfoChip(
                icon: Icons.person_outline,
                label: 'العميل',
                value: _displayValue(customerName, 'رقم ${invoice.customerId}'),
              ),
              _InfoChip(
                icon: Icons.inventory_2_outlined,
                label: 'العناصر',
                value: invoice.items.length.toString(),
              ),
              _InfoChip(
                icon: Icons.discount_outlined,
                label: 'الخصم',
                value: _formatMoney(invoice.discount),
              ),
            ],
          ),
          if (invoice.items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1, color: AppColors.outlineVariant),
            const SizedBox(height: AppSpacing.md),
            for (final item in invoice.items.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _displayValue(item.sparePartName, 'قطعة بدون اسم'),
                        style: AppTextStyles.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${item.quantity} x ${_formatMoney(item.unitPrice)}',
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.xs),
          Text('$label: ', style: AppTextStyles.label),
          Text(value, style: AppTextStyles.labelStrong),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: AppTextStyles.labelStrong),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isError;
  final String message;

  const _EmptyState({required this.isError, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Column(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.receipt_long_outlined,
            color: isError ? AppColors.error : AppColors.onSurfaceVariant,
            size: 40,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
          if (isError) ...[
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () =>
                  context.read<InvoicesCubit>().fetch(refresh: true),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ],
      ),
    );
  }
}

String _displayValue(String? value, String fallback) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return fallback;
  return trimmed;
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
}

String _formatMoney(double value) => value.toStringAsFixed(2);
