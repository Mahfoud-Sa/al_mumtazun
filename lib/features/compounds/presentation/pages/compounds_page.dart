import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/index_view_toggle.dart';
import '../../../../di/service_locator.dart';
import '../../../../theme/app_colors.dart';
import '../../../home/app_shell.dart';
import '../../domain/entities/compound.dart';
import '../cubit/compounds_cubit.dart';
import '../cubit/compounds_state.dart';
import 'add_spare_part_page.dart';
import 'compound_details_page.dart';

class CompoundsPage extends StatelessWidget {
  const CompoundsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CompoundsCubit>()..fetch(),
      child: const _SparePartsView(),
    );
  }
}

class _SparePartsView extends StatefulWidget {
  const _SparePartsView();

  @override
  State<_SparePartsView> createState() => _SparePartsViewState();
}

class _SparePartsViewState extends State<_SparePartsView> {
  final _scrollController = ScrollController();
  IndexViewMode _viewMode = IndexViewMode.list;

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
    if (_viewMode != IndexViewMode.grid) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 360) {
      context.read<CompoundsCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: () => context.read<CompoundsCubit>().fetch(page: 1),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SparePartsHeader(),
                const SizedBox(height: 24),
                const _SparePartsFilters(),
                const SizedBox(height: 16),
                IndexViewControls(
                  viewMode: _viewMode,
                  onViewModeChanged: (mode) {
                    setState(() => _viewMode = mode);
                    context.read<CompoundsCubit>().fetch(page: 1);
                  },
                ),
                const SizedBox(height: 24),
                _SparePartsTable(viewMode: _viewMode),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SparePartsHeader extends StatelessWidget {
  const _SparePartsHeader();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;
    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.end
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
                  'مخزون قطع الغيار',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'إدارة وتتبع قطع الغيار وأسعار البيع في المستودعات.',
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
        ElevatedButton.icon(
          onPressed: () async {
            final cubit = context.read<CompoundsCubit>();
            final created = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: const AddSparePartPage(),
                ),
              ),
            );
            if (created == true && context.mounted) {
              context.read<CompoundsCubit>().fetch(page: 1);
            }
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('إضافة قطعة غيار'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

class _SparePartsFilters extends StatefulWidget {
  const _SparePartsFilters();

  @override
  State<_SparePartsFilters> createState() => _SparePartsFiltersState();
}

class _SparePartsFiltersState extends State<_SparePartsFilters> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  Timer? _debounce;
  String _sortBy = 'id';
  String _sortDirection = 'asc';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: isWide ? 3 : 1,
                  child: _SearchField(
                    controller: _searchController,
                    onChanged: _queueApply,
                    onSubmitted: (_) => _apply(),
                  ),
                ),
                if (isWide) const SizedBox(width: 24),
                if (isWide)
                  SizedBox(
                    width: 280,
                    child: _SortBox(
                      sortBy: _sortBy,
                      sortDirection: _sortDirection,
                      onChanged: (sortBy, direction) {
                        setState(() {
                          _sortBy = sortBy;
                          _sortDirection = direction;
                        });
                        _apply();
                      },
                    ),
                  ),
              ],
            ),
            if (!isWide) ...[
              const SizedBox(height: 16),
              _SortBox(
                sortBy: _sortBy,
                sortDirection: _sortDirection,
                onChanged: (sortBy, direction) {
                  setState(() {
                    _sortBy = sortBy;
                    _sortDirection = direction;
                  });
                  _apply();
                },
              ),
            ],
            const SizedBox(height: 16),
            _AdvancedFilters(
              minPriceController: _minPriceController,
              maxPriceController: _maxPriceController,
              onChanged: _queueApply,
              onQuickFilter: _setQuickFilter,
              onClear: _clear,
            ),
          ],
        );
      },
    );
  }

  void _queueApply(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _apply);
  }

  void _setQuickFilter(double? min, double? max) {
    _minPriceController.text = min == null ? '' : min.toStringAsFixed(0);
    _maxPriceController.text = max == null ? '' : max.toStringAsFixed(0);
    _apply();
  }

  void _apply() {
    _debounce?.cancel();
    context.read<CompoundsCubit>().applyQuery(
      search: _searchController.text,
      minPrice: _readDouble(_minPriceController.text),
      maxPrice: _readDouble(_maxPriceController.text),
      sortBy: _sortBy,
      sortDirection: _sortDirection,
    );
  }

  void _clear() {
    _debounce?.cancel();
    _searchController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    setState(() {
      _sortBy = 'id';
      _sortDirection = 'asc';
    });
    context.read<CompoundsCubit>().clearQuery();
  }

  double? _readDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll(',', '.'));
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.outline),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: const TextStyle(color: AppColors.onSurface),
              decoration: const InputDecoration(
                hintText: 'ابحث باسم القطعة أو الوصف...',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortBox extends StatelessWidget {
  final String sortBy;
  final String sortDirection;
  final void Function(String sortBy, String direction) onChanged;

  const _SortBox({
    required this.sortBy,
    required this.sortDirection,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final value = '$sortBy:$sortDirection';
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.sort, color: AppColors.outline),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'id:asc',
                    child: Text('الرقم تصاعدي'),
                  ),
                  DropdownMenuItem(
                    value: 'id:desc',
                    child: Text('الرقم تنازلي'),
                  ),
                  DropdownMenuItem(
                    value: 'name:asc',
                    child: Text('الاسم تصاعدي'),
                  ),
                  DropdownMenuItem(
                    value: 'name:desc',
                    child: Text('الاسم تنازلي'),
                  ),
                  DropdownMenuItem(
                    value: 'sellPrice:asc',
                    child: Text('سعر البيع تصاعدي'),
                  ),
                  DropdownMenuItem(
                    value: 'sellPrice:desc',
                    child: Text('سعر البيع تنازلي'),
                  ),
                  DropdownMenuItem(
                    value: 'date:asc',
                    child: Text('التاريخ تصاعدي'),
                  ),
                  DropdownMenuItem(
                    value: 'date:desc',
                    child: Text('التاريخ تنازلي'),
                  ),
                ],
                onChanged: (next) {
                  if (next == null) return;
                  final parts = next.split(':');
                  onChanged(parts[0], parts[1]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedFilters extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final ValueChanged<String> onChanged;
  final void Function(double? min, double? max) onQuickFilter;
  final VoidCallback onClear;

  const _AdvancedFilters({
    required this.minPriceController,
    required this.maxPriceController,
    required this.onChanged,
    required this.onQuickFilter,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'نطاق السعر:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          _PriceInput(
            controller: minPriceController,
            hint: 'الأدنى',
            onChanged: onChanged,
          ),
          const Text('-', style: TextStyle(color: AppColors.outline)),
          _PriceInput(
            controller: maxPriceController,
            hint: 'الأعلى',
            onChanged: onChanged,
          ),
          const SizedBox(width: 8),
          const Text(
            'فلاتر سريعة:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          _QuickFilterButton(
            label: 'أقل من 100',
            onPressed: () => onQuickFilter(null, 100),
          ),
          _QuickFilterButton(
            label: '100 - 500',
            onPressed: () => onQuickFilter(100, 500),
          ),
          _QuickFilterButton(
            label: 'أكثر من 500',
            onPressed: () => onQuickFilter(500, null),
          ),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.filter_list_off, size: 18),
            label: const Text('مسح'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _PriceInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _PriceInput({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.secondary),
          ),
        ),
      ),
    );
  }
}

class _QuickFilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _QuickFilterButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onSurfaceVariant,
        side: const BorderSide(color: AppColors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(label),
    );
  }
}

class _SparePartsTable extends StatelessWidget {
  final IndexViewMode viewMode;

  const _SparePartsTable({required this.viewMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: BlocBuilder<CompoundsCubit, CompoundsState>(
        builder: (context, state) {
          if (state is CompoundsLoading || state is CompoundsInitial) {
            return const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is CompoundsError) {
            return _ErrorState(message: state.message);
          }

          final loaded = state as CompoundsLoaded;
          if (loaded.compounds.isEmpty) {
            return Column(
              children: const [
                Padding(
                  padding: EdgeInsets.all(48),
                  child: Text(
                    'لا توجد قطع غيار.',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ),
                Divider(height: 1, color: AppColors.outlineVariant),
                _SparePartsPaginationFooter(),
              ],
            );
          }

          return Column(
            children: [
              if (viewMode == IndexViewMode.grid)
                _SparePartsGrid(parts: loaded.compounds)
              else
                _SparePartsRows(parts: loaded.compounds),
              const Divider(height: 1, color: AppColors.outlineVariant),
              if (viewMode == IndexViewMode.list)
                const _SparePartsPaginationFooter()
              else
                _SparePartsGridFooter(loaded: loaded),
            ],
          );
        },
      ),
    );
  }
}

class _SparePartsGridFooter extends StatelessWidget {
  final CompoundsLoaded loaded;

  const _SparePartsGridFooter({required this.loaded});

  @override
  Widget build(BuildContext context) {
    if (loaded.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        loaded.page >= loaded.totalPages
            ? 'تم تحميل كل قطع الغيار'
            : 'مرر للأسفل لتحميل المزيد',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
      ),
    );
  }
}

class _SparePartsRows extends StatelessWidget {
  final List<Compound> parts;

  const _SparePartsRows({required this.parts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.primary),
        dataRowMinHeight: 56,
        dataRowMaxHeight: 64,
        columnSpacing: 32,
        columns: const [
          DataColumn(label: _HeaderCell('الرقم')),
          DataColumn(label: _HeaderCell('اسم القطعة')),
          DataColumn(label: _HeaderCell('الوصف')),
          DataColumn(label: _HeaderCell('سعر البيع')),
          DataColumn(label: _HeaderCell('الكمية')),
          DataColumn(label: _HeaderCell('آخر تحديث')),
          DataColumn(label: _HeaderCell('الإجراءات')),
        ],
        rows: parts.asMap().entries.map((entry) {
          final index = entry.key;
          final part = entry.value;
          return DataRow(
            color: WidgetStateProperty.all(
              index.isEven ? Colors.white : AppColors.surface,
            ),
            cells: [
              DataCell(Text('#${part.id}')),
              DataCell(
                Text(
                  part.name.isEmpty ? '-' : part.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 240,
                  child: Text(
                    part.description?.trim().isNotEmpty == true
                        ? part.description!
                        : '-',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ),
              ),
              DataCell(
                Text(
                  _formatMoney(part.sellPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              DataCell(Text(part.quantity.toString())),
              DataCell(Text(_formatDate(part.date))),
              DataCell(_PartActions(part: part)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SparePartsGrid extends StatelessWidget {
  final List<Compound> parts;

  const _SparePartsGrid({required this.parts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1080
              ? 3
              : constraints.maxWidth >= 680
              ? 2
              : 1;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 240,
            ),
            itemCount: parts.length,
            itemBuilder: (context, index) {
              return _SparePartCard(part: parts[index]);
            },
          );
        },
      ),
    );
  }
}

class _SparePartCard extends StatelessWidget {
  final Compound part;

  const _SparePartCard({required this.part});

  @override
  Widget build(BuildContext context) {
    final description = part.description?.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  part.name.isEmpty ? '-' : part.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '#${part.id}',
                style: const TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description?.isNotEmpty == true ? description! : 'لا يوجد وصف',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _PartMeta(
                  label: 'سعر البيع',
                  value: _formatMoney(part.sellPrice),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PartMeta(
                  label: 'الكمية',
                  value: part.quantity.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PartMeta(
                  label: 'آخر تحديث',
                  value: _formatDate(part.date),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.outlineVariant),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _PartActions(part: part),
          ),
        ],
      ),
    );
  }
}

class _PartMeta extends StatelessWidget {
  final String label;
  final String value;

  const _PartMeta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PartActions extends StatelessWidget {
  final Compound part;

  const _PartActions({required this.part});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 50,
      child: Align(
        alignment: Alignment.centerRight,
        child: PopupMenuButton<String>(
          icon: Icon(Icons.settings, color: colorScheme.onSurfaceVariant),
          onSelected: (value) {
            switch (value) {
              case 'details':
                _showDetails(context);
                break;
              case 'edit':
                _showUpdateDialog(context);
                break;
              case 'delete':
                _confirmDelete(context);
                break;
            }
          },
          itemBuilder: (_) => _partMenuItems(),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CompoundDetailsPage(compound: part)),
    );
  }

  Future<void> _showUpdateDialog(BuildContext context) async {
    final cubit = context.read<CompoundsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    await showDialog<void>(
      context: context,
      builder: (_) => _EditSparePartDialog(
        part: part,
        onSave: cubit.editCompound,
        onResult: (success) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                success ? 'تم تحديث قطعة الغيار' : 'فشل تحديث قطعة الغيار',
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف قطعة الغيار'),
        content: Text('هل تريد حذف "${part.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await context.read<CompoundsCubit>().removeCompound(
      part.id,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'تم حذف قطعة الغيار' : 'فشل حذف قطعة الغيار'),
      ),
    );
  }
}

List<PopupMenuEntry<String>> _partMenuItems() {
  return const [
    PopupMenuItem(
      value: 'details',
      child: Row(
        children: [
          Icon(Icons.visibility, color: Colors.blue, size: 20),
          SizedBox(width: 8),
          Text('عرض التفاصيل'),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          Icon(Icons.edit_outlined, color: AppColors.secondary, size: 20),
          SizedBox(width: 8),
          Text('تعديل'),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          SizedBox(width: 8),
          Text('حذف'),
        ],
      ),
    ),
  ];
}

class _EditSparePartDialog extends StatefulWidget {
  final Compound part;
  final Future<bool> Function(Compound part) onSave;
  final ValueChanged<bool> onResult;

  const _EditSparePartDialog({
    required this.part,
    required this.onSave,
    required this.onResult,
  });

  @override
  State<_EditSparePartDialog> createState() => _EditSparePartDialogState();
}

class _EditSparePartDialogState extends State<_EditSparePartDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _dateController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final part = widget.part;
    _nameController = TextEditingController(text: part.name);
    _descriptionController = TextEditingController(
      text: part.description ?? '',
    );
    _priceController = TextEditingController(
      text: part.sellPrice.toStringAsFixed(2),
    );
    _quantityController = TextEditingController(text: part.quantity.toString());
    _dateController = TextEditingController(text: _formatDate(part.date));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل قطعة غيار'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'الاسم'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'سعر البيع'),
                  validator: (value) {
                    final price = double.tryParse(value?.trim() ?? '');
                    return price == null || price < 0
                        ? 'أدخل سعراً صالحاً'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الكمية'),
                  validator: (value) {
                    final quantity = int.tryParse(value?.trim() ?? '');
                    return quantity == null || quantity < 0
                        ? 'أدخل كمية صالحة'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'التاريخ'),
                  validator: (value) =>
                      DateTime.tryParse(value?.trim() ?? '') == null
                      ? 'مطلوب'
                      : null,
                  onTap: _pickDate,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('حفظ'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? widget.part.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = _formatDate(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final updated = Compound(
      id: widget.part.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      sellPrice: double.parse(_priceController.text.trim()),
      quantity: int.parse(_quantityController.text.trim()),
      date: DateTime.parse(_dateController.text.trim()),
    );

    final success = await widget.onSave(updated);
    if (!mounted) return;
    Navigator.pop(context);
    widget.onResult(success);
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onSurfaceVariant),
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
}

class _SparePartsPaginationFooter extends StatelessWidget {
  const _SparePartsPaginationFooter();

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
          color: AppColors.surface,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final summary = Text(
                'عرض $start إلى $end من $totalCount قطعة',
                style: const TextStyle(
                  fontSize: 14,
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
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$page',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('من $totalPages'),
                  const SizedBox(width: 8),
                  _PaginationButton(
                    icon: Icons.chevron_left,
                    onPressed: canGoNext
                        ? () => context.read<CompoundsCubit>().nextPage()
                        : null,
                  ),
                ],
              );

              if (constraints.maxWidth < 520) {
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return date.toIso8601String().split('T').first;
}

String _formatMoney(double value) {
  return value.toStringAsFixed(2);
}
