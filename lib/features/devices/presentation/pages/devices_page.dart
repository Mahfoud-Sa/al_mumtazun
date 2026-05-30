import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/index_view_toggle.dart';
import '../../../../di/service_locator.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../home/home_shell.dart';
import '../../domain/entities/device.dart';
import '../cubit/devices_cubit.dart';
import '../cubit/devices_state.dart';
import '../device_status_presentation.dart';
import 'device_details_page.dart';
import 'register_device_page.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DevicesCubit>()..fetch(),
      child: const _DevicesView(),
    );
  }
}

class _DevicesView extends StatefulWidget {
  const _DevicesView();

  @override
  State<_DevicesView> createState() => _DevicesViewState();
}

class _DevicesViewState extends State<_DevicesView> {
  final _scrollController = ScrollController();
  IndexViewMode _viewMode = IndexViewMode.grid;

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
      context.read<DevicesCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          backgroundColor: colorScheme.secondary,
          foregroundColor: Colors.white,
          onPressed: () => _openRegisterPage(context),
          child: const Icon(Icons.add),
        ),
        body: BlocListener<DevicesCubit, DevicesState>(
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
            onRefresh: () => context.read<DevicesCubit>().fetch(refresh: true),
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
                  const _DevicesHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  const _SearchAndActions(),
                  const SizedBox(height: AppSpacing.md),
                  IndexViewControls(
                    viewMode: _viewMode,
                    onViewModeChanged: (mode) {
                      setState(() => _viewMode = mode);
                      context.read<DevicesCubit>().fetch(refresh: true);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _DevicesIndex(viewMode: _viewMode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openRegisterPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<DevicesCubit>(),
          child: const RegisterDevicePage(),
        ),
      ),
    );
  }
}

class _DevicesHeader extends StatelessWidget {
  const _DevicesHeader();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;
    final colorScheme = Theme.of(context).colorScheme;

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
              icon: Icon(Icons.menu, color: colorScheme.primary),
              onPressed: () => HomeShell.openDrawer(context),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الأجهزة',
                  style: AppTextStyles.pageTitle.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'إدارة استلام الأجهزة وحالة الصيانة وسجلات العملاء.',
                  style: AppTextStyles.body.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (!isWide) const SizedBox(height: AppSpacing.lg),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: context.read<DevicesCubit>(),
                child: const RegisterDevicePage(),
              ),
            ),
          ),
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text('تسجيل جهاز جديد'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchAndActions extends StatelessWidget {
  const _SearchAndActions();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<DevicesCubit, DevicesState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                final search = TextField(
                  onChanged: context.read<DevicesCubit>().updateSearch,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText:
                        'ابحث باسم الجهاز أو العميل او البراند او المودل ...',
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.secondary),
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                  ),
                );
                final actions = Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _FilterMenu(selected: state.statusFilter),
                    _SortMenu(
                      sortBy: state.sortBy,
                      sortDirection: state.sortDirection,
                      onChanged: context.read<DevicesCubit>().updateSorting,
                    ),
                    _SortDirectionMenu(
                      sortBy: state.sortBy,
                      sortDirection: state.sortDirection,
                      onChanged: context.read<DevicesCubit>().updateSorting,
                    ),
                  ],
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: search),
                      const SizedBox(width: AppSpacing.xl),
                      actions,
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    search,
                    const SizedBox(height: AppSpacing.md),
                    Align(alignment: Alignment.centerLeft, child: actions),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'النشط:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.4,
                  ),
                ),
                if (state.statusFilter == null && state.searchQuery.isEmpty)
                  Text(
                    'لا يوجد',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                if (state.statusFilter != null)
                  InputChip(
                    label: Text(
                      'الحالة: ${state.statusFilter!.label}',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    onDeleted: () =>
                        context.read<DevicesCubit>().setStatusFilter(null),
                    backgroundColor: colorScheme.surfaceContainerLow,
                    deleteIconColor: colorScheme.onSurfaceVariant,
                    side: BorderSide.none,
                  ),
                if (state.searchQuery.isNotEmpty)
                  Chip(
                    label: Text(
                      'البحث: ${state.searchQuery}',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    backgroundColor: colorScheme.surfaceContainerLow,
                    side: BorderSide.none,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _FilterMenu extends StatelessWidget {
  final DeviceStatus? selected;

  const _FilterMenu({required this.selected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<DeviceStatus?>(
      initialValue: selected,
      onSelected: context.read<DevicesCubit>().setStatusFilter,
      itemBuilder: (context) => [
        const PopupMenuItem<DeviceStatus?>(
          value: null,
          child: Text('كل الحالات'),
        ),
        ...DeviceStatus.values.map(
          (status) => PopupMenuItem<DeviceStatus?>(
            value: status,
            child: Text(status.label),
          ),
        ),
      ],
      child: OutlinedButton.icon(
        onPressed: null,
        icon: Icon(Icons.filter_list, size: 18, color: colorScheme.primary),
        label: Text(selected == null ? 'تصفية' : selected!.label),
        style: OutlinedButton.styleFrom(
          disabledForegroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          textStyle: AppTextStyles.labelStrong,
        ),
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  final String sortBy;
  final String sortDirection;
  final void Function(String sortBy, String sortDirection) onChanged;

  const _SortMenu({
    required this.sortBy,
    required this.sortDirection,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      initialValue: sortBy,
      onSelected: (value) => onChanged(value, sortDirection),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'date', child: Text('التاريخ')),
        PopupMenuItem(value: 'name', child: Text('اسم الجهاز')),
        PopupMenuItem(value: 'status', child: Text('الحالة')),
        PopupMenuItem(value: 'id', child: Text('رقم الجهاز')),
      ],
      child: OutlinedButton.icon(
        onPressed: null,
        icon: Icon(Icons.sort, size: 18, color: colorScheme.primary),
        label: Text('ترتيب: ${_deviceSortLabel(sortBy)}'),
        style: OutlinedButton.styleFrom(
          disabledForegroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          textStyle: AppTextStyles.labelStrong,
        ),
      ),
    );
  }
}

class _SortDirectionMenu extends StatelessWidget {
  final String sortBy;
  final String sortDirection;
  final void Function(String sortBy, String sortDirection) onChanged;

  const _SortDirectionMenu({
    required this.sortBy,
    required this.sortDirection,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      initialValue: sortDirection,
      onSelected: (value) => onChanged(sortBy, value),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'desc', child: Text('تنازلي')),
        PopupMenuItem(value: 'asc', child: Text('تصاعدي')),
      ],
      child: OutlinedButton.icon(
        onPressed: null,
        icon: Icon(
          sortDirection == 'desc' ? Icons.south_outlined : Icons.north_outlined,
          size: 18,
          color: colorScheme.primary,
        ),
        label: Text(_deviceSortDirectionLabel(sortDirection)),
        style: OutlinedButton.styleFrom(
          disabledForegroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          textStyle: AppTextStyles.labelStrong,
        ),
      ),
    );
  }
}

class _DevicesIndex extends StatelessWidget {
  final IndexViewMode viewMode;

  const _DevicesIndex({required this.viewMode});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicesCubit, DevicesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        void registerAction() {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: context.read<DevicesCubit>(),
                child: const RegisterDevicePage(),
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                if (viewMode == IndexViewMode.list)
                  _DeviceRows(devices: state.visibleDevices)
                else
                  _DeviceGrid(
                    devices: state.visibleDevices,
                    maxWidth: constraints.maxWidth,
                    onRegister: registerAction,
                  ),
                if (state.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (viewMode == IndexViewMode.list)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.lg),
                    child: _DevicesPagination(),
                  )
                else if (state.devices.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: Text(
                      state.hasReachedEnd
                          ? 'تم تحميل كل الأجهزة'
                          : 'مرر للأسفل لتحميل المزيد',
                      style: AppTextStyles.label,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DevicesPagination extends StatelessWidget {
  const _DevicesPagination();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevicesCubit, DevicesState>(
      builder: (context, state) {
        if (state.totalCount == 0 && state.devices.isEmpty) {
          return const SizedBox.shrink();
        }

        final colorScheme = Theme.of(context).colorScheme;

        final start = state.devices.isEmpty
            ? 0
            : ((state.page - 1) * state.size) + 1;
        final end = state.devices.isEmpty
            ? 0
            : (((state.page - 1) * state.size) + state.devices.length).clamp(
                start,
                state.totalCount,
              );

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outlineVariant),
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
                style: AppTextStyles.labelStrong.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: state.page <= 1 || state.isLoading
                        ? null
                        : context.read<DevicesCubit>().previousPage,
                    icon: const Icon(Icons.chevron_right, size: 18),
                    label: const Text('السابق'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: state.page >= state.totalPages || state.isLoading
                        ? null
                        : context.read<DevicesCubit>().nextPage,
                    icon: const Icon(Icons.chevron_left, size: 18),
                    label: const Text('التالي'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.outline),
                    ),
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

class _DeviceGrid extends StatelessWidget {
  final List<Device> devices;
  final double maxWidth;
  final VoidCallback onRegister;

  const _DeviceGrid({
    required this.devices,
    required this.maxWidth,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final columns = maxWidth >= 1024
        ? 3
        : maxWidth >= 640
        ? 2
        : 1;
    final cards = [
      ...devices.map((device) => _DeviceCard(device: device)),
      _RegisterDeviceCard(onTap: onRegister),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.xl,
        mainAxisSpacing: AppSpacing.xl,
        mainAxisExtent: 238,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }
}

class _DeviceRows extends StatelessWidget {
  final List<Device> devices;

  const _DeviceRows({required this.devices});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 760 ? 760.0 : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      border: Border(
                        bottom: BorderSide(color: colorScheme.outline),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'الجهاز',
                            style: AppTextStyles.labelStrong.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'الماركة',
                            style: AppTextStyles.labelStrong.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'العميل',
                            style: AppTextStyles.labelStrong.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: Text(
                            'الحالة',
                            style: AppTextStyles.labelStrong.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 132,
                          child: Text(
                            'إجراءات',
                            style: AppTextStyles.labelStrong.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var index = 0; index < devices.length; index++)
                    _DeviceRow(
                      device: devices[index],
                      showDivider: index < devices.length - 1,
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

class _DeviceRow extends StatelessWidget {
  final Device device;
  final bool showDivider;

  const _DeviceRow({required this.device, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _openDetails(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
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
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelStrong.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    device.serialNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Text(
                device.brand,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            Expanded(
              child: Text(
                device.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            SizedBox(width: 150, child: _StatusBadge(status: device.status)),
            SizedBox(
              width: 132,
              child: TextButton.icon(
                onPressed: () => _openDetails(context),
                icon: const Icon(Icons.chevron_right, size: 18),
                label: const Text('التفاصيل'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.secondary,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  textStyle: AppTextStyles.labelStrong,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DeviceDetailsPage(device: device),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final Device device;

  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      onTap: () => _openDetails(context),
      child: Card(
        color: colorScheme.surface,
        elevation: 1,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'الرقم التسلسلي: ${device.serialNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StatusBadge(status: device.status),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: AppSpacing.md),
              _DeviceInfoRow(label: 'الماركة', value: device.brand),
              const SizedBox(height: AppSpacing.sm),
              _DeviceInfoRow(label: 'العميل', value: device.customerName),
              const Spacer(),
              Divider(height: 1, color: colorScheme.outlineVariant),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _openDetails(context),
                  icon: const Icon(Icons.chevron_right, size: 18),
                  label: const Text('عرض التفاصيل'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.secondary,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DeviceDetailsPage(device: device),
      ),
    );
  }
}

class _DeviceInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DeviceInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DeviceStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.backgroundColor(context),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(color: status.borderColor(context)),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: status.foregroundColor(context),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _RegisterDeviceCard extends StatelessWidget {
  final VoidCallback onTap;

  const _RegisterDeviceCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'تسجيل جهاز جديد',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.outline,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _deviceSortLabel(String sortBy) {
  return switch (sortBy) {
    'name' => 'اسم الجهاز',
    'status' => 'الحالة',
    'date' => 'التاريخ',
    _ => 'رقم الجهاز',
  };
}

String _deviceSortDirectionLabel(String sortDirection) {
  return sortDirection == 'desc' ? 'تنازلي' : 'تصاعدي';
}
