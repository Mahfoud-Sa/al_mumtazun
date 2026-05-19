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
import 'add_invoice_page.dart';
import 'invoice_details_page.dart';

enum _InvoiceViewMode { list, grid }

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
  _InvoiceViewMode _viewMode = _InvoiceViewMode.grid;

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
    if (_viewMode != _InvoiceViewMode.grid) return;
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
              previous.errorMessage != current.errorMessage ||
              previous.deleteErrorMessage != current.deleteErrorMessage,
          listener: (context, state) {
            final message = state.errorMessage ?? state.deleteErrorMessage;
            if (message != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
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
                children: [
                  const _InvoicesHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  const _InvoiceQueryPanel(),
                  const SizedBox(height: AppSpacing.md),
                  _InvoiceViewControls(
                    viewMode: _viewMode,
                    onViewModeChanged: (mode) {
                      setState(() => _viewMode = mode);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // const _InvoicesSummary(),
                  const SizedBox(height: AppSpacing.xl),
                  _InvoicesList(viewMode: _viewMode),
                  if (_viewMode == _InvoiceViewMode.list) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const _InvoicesPagination(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceQueryPanel extends StatefulWidget {
  const _InvoiceQueryPanel();

  @override
  State<_InvoiceQueryPanel> createState() => _InvoiceQueryPanelState();
}

class _InvoiceQueryPanelState extends State<_InvoiceQueryPanel> {
  final _searchController = TextEditingController();
  final _deviceController = TextEditingController();
  final _customerController = TextEditingController();
  final _minTotalController = TextEditingController();
  final _maxTotalController = TextEditingController();

  DateTime? _fromDate;
  DateTime? _toDate;
  String _sortBy = 'date';
  String _sortDirection = 'desc';
  int _pageSize = 10;

  @override
  void dispose() {
    _searchController.dispose();
    _deviceController.dispose();
    _customerController.dispose();
    _minTotalController.dispose();
    _maxTotalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvoicesCubit, InvoicesState>(
      listenWhen: (previous, current) => previous.query != current.query,
      listener: (context, state) {
        final query = state.query;
        setState(() {
          _setText(_searchController, query.search);
          _setText(_deviceController, query.deviceId?.toString());
          _setText(_customerController, query.customerId?.toString());
          _setText(_minTotalController, query.minTotal?.toString());
          _setText(_maxTotalController, query.maxTotal?.toString());
          _sortBy = query.sortBy;
          _sortDirection = query.sortDirection;
          _pageSize = query.size;
          _fromDate = query.fromDate;
          _toDate = query.toDate;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 840;
                final fields = [
                  _PanelField(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _apply(context),
                      decoration: const InputDecoration(
                        hintText: 'بحث برقم الفاتورة أو الجهاز أو العميل',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  _PanelField(
                    child: TextField(
                      controller: _deviceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'رقم الجهاز',
                        prefixIcon: Icon(
                          Icons.precision_manufacturing_outlined,
                        ),
                      ),
                    ),
                  ),
                  _PanelField(
                    child: TextField(
                      controller: _customerController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'رقم العميل',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),
                ];

                if (!isWide) {
                  return Column(
                    children: [
                      for (var i = 0; i < fields.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.md),
                        fields[i].child,
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    for (var i = 0; i < fields.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.md),
                      Expanded(flex: fields[i].flex, child: fields[i].child),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 840;
                final controls = [
                  _DateFilterButton(
                    label: 'من تاريخ',
                    value: _fromDate,
                    onPressed: () => _pickDate(context, isFrom: true),
                    onClear: _fromDate == null
                        ? null
                        : () => setState(() => _fromDate = null),
                  ),
                  _DateFilterButton(
                    label: 'إلى تاريخ',
                    value: _toDate,
                    onPressed: () => _pickDate(context, isFrom: false),
                    onClear: _toDate == null
                        ? null
                        : () => setState(() => _toDate = null),
                  ),
                  TextField(
                    controller: _minTotalController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'أقل إجمالي'),
                  ),
                  TextField(
                    controller: _maxTotalController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'أعلى إجمالي'),
                  ),
                ];

                if (!isWide) {
                  return Column(
                    children: [
                      for (var i = 0; i < controls.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.md),
                        controls[i],
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    for (var i = 0; i < controls.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.md),
                      Expanded(child: controls[i]),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _DropdownBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('sort-by-$_sortBy'),
                    initialValue: _sortBy,
                    decoration: const InputDecoration(labelText: 'ترتيب حسب'),
                    items: const [
                      DropdownMenuItem(value: 'date', child: Text('التاريخ')),
                      DropdownMenuItem(value: 'total', child: Text('الإجمالي')),
                      DropdownMenuItem(
                        value: 'id',
                        child: Text('رقم الفاتورة'),
                      ),
                      DropdownMenuItem(value: 'device', child: Text('الجهاز')),
                      DropdownMenuItem(
                        value: 'customer',
                        child: Text('العميل'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _sortBy = value);
                    },
                  ),
                ),
                _DropdownBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('sort-direction-$_sortDirection'),
                    initialValue: _sortDirection,
                    decoration: const InputDecoration(labelText: 'الاتجاه'),
                    items: const [
                      DropdownMenuItem(value: 'desc', child: Text('تنازلي')),
                      DropdownMenuItem(value: 'asc', child: Text('تصاعدي')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sortDirection = value);
                      }
                    },
                  ),
                ),
                _DropdownBox(
                  width: 140,
                  child: DropdownButtonFormField<int>(
                    key: ValueKey('page-size-$_pageSize'),
                    initialValue: _pageSize,
                    decoration: const InputDecoration(labelText: 'عدد الصفوف'),
                    items: const [
                      DropdownMenuItem(value: 10, child: Text('10')),
                      DropdownMenuItem(value: 25, child: Text('25')),
                      DropdownMenuItem(value: 50, child: Text('50')),
                      DropdownMenuItem(value: 100, child: Text('100')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _pageSize = value);
                    },
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _apply(context),
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('تطبيق'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _clear(context),
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('مسح'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isFrom}) async {
    final initialDate = isFrom
        ? _fromDate ?? DateTime.now()
        : _toDate ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _fromDate = DateTime(selected.year, selected.month, selected.day);
      } else {
        _toDate = DateTime(
          selected.year,
          selected.month,
          selected.day,
          23,
          59,
          59,
        );
      }
    });
  }

  void _apply(BuildContext context) {
    final deviceId = _readInt(_deviceController.text);
    final customerId = _readInt(_customerController.text);
    final minTotal = _readDouble(_minTotalController.text);
    final maxTotal = _readDouble(_maxTotalController.text);

    context.read<InvoicesCubit>().updateFilters(
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text,
      clearSearch: _searchController.text.trim().isEmpty,
      deviceId: deviceId,
      clearDeviceId: deviceId == null,
      customerId: customerId,
      clearCustomerId: customerId == null,
      fromDate: _fromDate,
      clearFromDate: _fromDate == null,
      toDate: _toDate,
      clearToDate: _toDate == null,
      minTotal: minTotal,
      clearMinTotal: minTotal == null,
      maxTotal: maxTotal,
      clearMaxTotal: maxTotal == null,
      sortBy: _sortBy,
      sortDirection: _sortDirection,
      size: _pageSize,
    );
  }

  void _clear(BuildContext context) {
    _searchController.clear();
    _deviceController.clear();
    _customerController.clear();
    _minTotalController.clear();
    _maxTotalController.clear();
    setState(() {
      _fromDate = null;
      _toDate = null;
      _sortBy = 'date';
      _sortDirection = 'desc';
      _pageSize = 10;
    });
    context.read<InvoicesCubit>().resetQuery();
  }

  int? _readInt(String value) => int.tryParse(value.trim());

  double? _readDouble(String value) => double.tryParse(value.trim());

  void _setText(TextEditingController controller, String? value) {
    final next = value ?? '';
    if (controller.text == next) return;
    controller.text = next;
  }
}

class _PanelField {
  final Widget child;
  final int flex;

  const _PanelField({required this.child, this.flex = 1});
}

class _DropdownBox extends StatelessWidget {
  final double width;
  final Widget child;

  const _DropdownBox({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: child);
  }
}

class _DateFilterButton extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onPressed;
  final VoidCallback? onClear;

  const _DateFilterButton({
    required this.label,
    required this.value,
    required this.onPressed,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        alignment: Alignment.centerRight,
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(value == null ? label : _formatDate(value!))),
          if (onClear != null)
            IconButton(
              tooltip: 'مسح',
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 16),
            ),
        ],
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
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _openAddInvoicePage(context),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('إضافة فاتورة'),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  context.read<InvoicesCubit>().fetch(refresh: true),
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
        ),
      ],
    );
  }

  Future<void> _openAddInvoicePage(BuildContext context) async {
    final cubit = context.read<InvoicesCubit>();
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const AddInvoicePage()),
      ),
    );

    if (created == true && context.mounted) {
      cubit.fetch(refresh: true);
    }
  }
}

class _InvoiceViewToggle extends StatelessWidget {
  static const _activeColor = Color(0xFFF39C12);
  static const _borderColor = Color(0xFFE2E8F0);

  final _InvoiceViewMode value;
  final ValueChanged<_InvoiceViewMode> onChanged;

  const _InvoiceViewToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InvoiceViewToggleButton(
            selected: value == _InvoiceViewMode.list,
            activeColor: _activeColor,
            icon: Icons.format_list_bulleted,
            label: 'قائمة',
            onPressed: () => onChanged(_InvoiceViewMode.list),
          ),
          _InvoiceViewToggleButton(
            selected: value == _InvoiceViewMode.grid,
            activeColor: _activeColor,
            icon: Icons.grid_view_outlined,
            label: 'شبكة',
            onPressed: () => onChanged(_InvoiceViewMode.grid),
          ),
        ],
      ),
    );
  }
}

class _InvoiceViewControls extends StatelessWidget {
  final _InvoiceViewMode viewMode;
  final ValueChanged<_InvoiceViewMode> onViewModeChanged;

  const _InvoiceViewControls({
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: _InvoiceViewToggle(value: viewMode, onChanged: onViewModeChanged),
    );
  }
}

class _InvoiceViewToggleButton extends StatelessWidget {
  final bool selected;
  final Color activeColor;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _InvoiceViewToggleButton({
    required this.selected,
    required this.activeColor,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: selected ? null : onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        foregroundColor: selected ? Colors.white : AppColors.onSurface,
        disabledForegroundColor: Colors.white,
        backgroundColor: selected ? activeColor : Colors.transparent,
        disabledBackgroundColor: activeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        textStyle: AppTextStyles.labelStrong,
      ),
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
  final _InvoiceViewMode viewMode;

  const _InvoicesList({required this.viewMode});

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

        return LayoutBuilder(
          builder: (context, constraints) {
            final body = viewMode == _InvoiceViewMode.list
                ? _InvoiceRows(invoices: state.invoices)
                : _InvoiceGrid(
                    invoices: state.invoices,
                    maxWidth: constraints.maxWidth,
                  );

            return Column(
              children: [
                body,
                if (state.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _InvoiceGrid extends StatelessWidget {
  final List<Invoice> invoices;
  final double maxWidth;

  const _InvoiceGrid({required this.invoices, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final columns = maxWidth >= 1180
        ? 3
        : maxWidth >= 760
        ? 2
        : 1;
    final spacing = AppSpacing.md * (columns - 1);
    final itemWidth = (maxWidth - spacing) / columns;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final invoice in invoices)
          SizedBox(
            width: itemWidth,
            child: _InvoiceCard(invoice: invoice),
          ),
      ],
    );
  }
}

class _InvoiceRows extends StatelessWidget {
  final List<Invoice> invoices;

  const _InvoiceRows({required this.invoices});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 680 ? 680.0 : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      border: Border(
                        bottom: BorderSide(color: AppColors.outline),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'الفاتورة',
                            style: AppTextStyles.labelStrong,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'الجهاز',
                            style: AppTextStyles.labelStrong,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'العميل',
                            style: AppTextStyles.labelStrong,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'الإجمالي',
                            style: AppTextStyles.labelStrong,
                          ),
                        ),
                        SizedBox(
                          width: 132,
                          child: Text(
                            'إجراءات',
                            style: AppTextStyles.labelStrong,
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var index = 0; index < invoices.length; index++)
                    _InvoiceRow(
                      invoice: invoices[index],
                      showDivider: index < invoices.length - 1,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final Invoice invoice;
  final bool showDivider;

  const _InvoiceRow({required this.invoice, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final deviceName = invoice.device?.name.trim();
    final customerName = invoice.device?.customerName.trim();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.outlineVariant))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('فاتورة #${invoice.id}', style: AppTextStyles.labelStrong),
                const SizedBox(height: AppSpacing.xs),
                Text(_formatDate(invoice.date), style: AppTextStyles.label),
              ],
            ),
          ),
          Expanded(
            child: Text(
              _displayValue(deviceName, 'رقم ${invoice.deviceId}'),
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              _displayValue(customerName, 'رقم ${invoice.customerId}'),
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              _formatMoney(invoice.total),
              style: AppTextStyles.labelStrong,
            ),
          ),
          SizedBox(width: 132, child: _InvoiceActions(invoice: invoice)),
        ],
      ),
    );
  }
}

class _InvoicesPagination extends StatelessWidget {
  const _InvoicesPagination();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoicesCubit, InvoicesState>(
      builder: (context, state) {
        if (state.totalCount == 0 && state.invoices.isEmpty) {
          return const SizedBox.shrink();
        }

        final start = state.invoices.isEmpty
            ? 0
            : ((state.page - 1) * state.size) + 1;
        final end = ((state.page - 1) * state.size) + state.invoices.length;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'عرض $start-$end من ${state.totalCount} | صفحة ${state.page} من ${state.totalPages}',
                style: AppTextStyles.labelStrong,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: state.page <= 1 || state.isLoading
                        ? null
                        : () => context.read<InvoicesCubit>().goToPage(
                            state.page - 1,
                          ),
                    icon: const Icon(Icons.chevron_right, size: 18),
                    label: const Text('السابق'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: state.page >= state.totalPages || state.isLoading
                        ? null
                        : () => context.read<InvoicesCubit>().goToPage(
                            state.page + 1,
                          ),
                    icon: const Icon(Icons.chevron_left, size: 18),
                    label: const Text('التالي'),
                  ),
                ],
              ),
            ],
          ),
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
              const SizedBox(width: AppSpacing.sm),
              _InvoiceActions(invoice: invoice),
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

class _InvoiceActions extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceActions({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoicesCubit, InvoicesState>(
      buildWhen: (previous, current) =>
          previous.deletingInvoiceId != current.deletingInvoiceId,
      builder: (context, state) {
        final isDeleting = state.deletingInvoiceId == invoice.id;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'عرض التفاصيل',
              onPressed: isDeleting
                  ? null
                  : () => _openInvoiceDetails(context, invoice),
              icon: const Icon(Icons.visibility_outlined, size: 20),
              color: AppColors.secondary,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              tooltip: 'تعديل الفاتورة',
              onPressed: isDeleting
                  ? null
                  : () => _editInvoice(context, invoice),
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: AppColors.primary,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              tooltip: 'حذف الفاتورة',
              onPressed: isDeleting
                  ? null
                  : () => _confirmDeleteInvoice(context, invoice),
              icon: isDeleting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline, size: 20),
              color: AppColors.error,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
            ),
          ],
        );
      },
    );
  }
}

Future<void> _openInvoiceDetails(BuildContext context, Invoice invoice) async {
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => InvoiceDetailsPage(invoice: invoice)),
  );
}

Future<void> _editInvoice(BuildContext context, Invoice invoice) async {
  final cubit = context.read<InvoicesCubit>();
  final updated = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AddInvoicePage(invoice: invoice),
      ),
    ),
  );

  if (updated == true && context.mounted) {
    cubit.fetch(refresh: true);
  }
}

Future<void> _confirmDeleteInvoice(
  BuildContext context,
  Invoice invoice,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('حذف الفاتورة'),
      content: Text('هل تريد حذف الفاتورة #${invoice.id}؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('حذف'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final deleted = await context.read<InvoicesCubit>().deleteExistingInvoice(
    invoice.id,
  );
  if (!context.mounted || !deleted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('تم حذف الفاتورة بنجاح'),
      backgroundColor: AppColors.success,
    ),
  );
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
