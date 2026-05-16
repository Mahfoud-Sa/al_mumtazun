import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/service_locator.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../home/home_shell.dart';
import '../../domain/entities/device.dart';
import '../cubit/devices_cubit.dart';
import '../cubit/devices_state.dart';
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
      context.read<DevicesCubit>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.secondary,
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
                children: const [
                  _DevicesHeader(),
                  SizedBox(height: AppSpacing.xl),
                  _SearchAndActions(),
                  SizedBox(height: AppSpacing.xl),
                  _DeviceGrid(),
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
              tooltip: 'ط§ظ„ظ‚ط§ط¦ظ…ط©',
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () => HomeShell.openDrawer(context),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الأجهزة', style: AppTextStyles.pageTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'إدارة استلام الأجهزة وحالة الصيانة وسجلات العملاء.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.onSurfaceVariant,
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
            backgroundColor: AppColors.secondary,
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
                  decoration: InputDecoration(
                    hintText: 'ابحث باسم الجهاز أو العميل...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
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
                  ),
                );
                final actions = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FilterMenu(selected: state.statusFilter),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: context.read<DevicesCubit>().toggleSort,
                      icon: const Icon(Icons.sort, size: 18),
                      label: Text(state.sortNewestFirst ? 'الأحدث' : 'الأقدم'),
                      style: _outlinedButtonStyle(),
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
                const Text(
                  'النشط:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.4,
                  ),
                ),
                if (state.statusFilter == null && state.searchQuery.isEmpty)
                  const Text(
                    'لا يوجد',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                if (state.statusFilter != null)
                  InputChip(
                    label: Text('الحالة: ${state.statusFilter!.label}'),
                    onDeleted: () =>
                        context.read<DevicesCubit>().setStatusFilter(null),
                    backgroundColor: AppColors.surfaceContainerHigh,
                    side: BorderSide.none,
                  ),
                if (state.searchQuery.isNotEmpty)
                  Chip(
                    label: Text('البحث: ${state.searchQuery}'),
                    backgroundColor: AppColors.surfaceContainerHigh,
                    side: BorderSide.none,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.outline),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      textStyle: AppTextStyles.labelStrong,
    );
  }
}

class _FilterMenu extends StatelessWidget {
  final DeviceStatus? selected;

  const _FilterMenu({required this.selected});

  @override
  Widget build(BuildContext context) {
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
        icon: const Icon(Icons.filter_list, size: 18),
        label: Text(selected == null ? 'تصفية' : selected!.label),
        style: OutlinedButton.styleFrom(
          disabledForegroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outline),
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

class _DeviceGrid extends StatelessWidget {
  const _DeviceGrid();

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

        final cards = [
          ...state.visibleDevices.map((device) => _DeviceCard(device: device)),
          _RegisterDeviceCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: context.read<DevicesCubit>(),
                  child: const RegisterDevicePage(),
                ),
              ),
            ),
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1024
                ? 3
                : width >= 640
                ? 2
                : 1;
            return Column(
              children: [
                GridView.builder(
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
                ),
                if (state.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
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

class _DeviceCard extends StatelessWidget {
  final Device device;

  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      onTap: () => _openDetails(context),
      child: Card(
        color: AppColors.surfaceContainer,
        elevation: 1,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          side: const BorderSide(color: AppColors.outlineVariant),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'الرقم التسلسلي: ${device.serialNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StatusBadge(status: device.status),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1, color: AppColors.outlineVariant),
              const SizedBox(height: AppSpacing.md),
              _DeviceInfoRow(label: 'الماركة', value: device.brand),
              const SizedBox(height: AppSpacing.sm),
              _DeviceInfoRow(label: 'العميل', value: device.customerName),
              const Spacer(),
              const Divider(height: 1, color: AppColors.outlineVariant),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _openDetails(context),
                  icon: const Icon(Icons.chevron_right, size: 18),
                  label: const Text('عرض التفاصيل'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
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
    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
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
            style: const TextStyle(color: AppColors.primary),
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
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(color: status.borderColor),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: status.foregroundColor,
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
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.xs),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 48, color: AppColors.outline),
            SizedBox(height: AppSpacing.sm),
            Text(
              'تسجيل جهاز جديد',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.outline,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension DeviceStatusPresentation on DeviceStatus {
  String get label {
    switch (this) {
      case DeviceStatus.received:
        return 'استلام';
      case DeviceStatus.waiting:
        return 'انتظار';
      case DeviceStatus.inMaintenance:
        return 'قيد الصيانة';
      case DeviceStatus.completed:
        return 'تم';
      case DeviceStatus.delivered:
        return 'تم تسليم العميل';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case DeviceStatus.received:
        return AppColors.info.withValues(alpha: 0.12);
      case DeviceStatus.waiting:
        return AppColors.surfaceContainerHigh;
      case DeviceStatus.inMaintenance:
        return AppColors.secondaryContainer.withValues(alpha: 0.2);
      case DeviceStatus.completed:
        return AppColors.greenBg;
      case DeviceStatus.delivered:
        return AppColors.success.withValues(alpha: 0.14);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case DeviceStatus.received:
        return AppColors.info;
      case DeviceStatus.waiting:
        return AppColors.onSurfaceVariant;
      case DeviceStatus.inMaintenance:
        return const Color(0xFF694000);
      case DeviceStatus.completed:
        return const Color(0xFF166534);
      case DeviceStatus.delivered:
        return AppColors.success;
    }
  }

  Color get borderColor {
    switch (this) {
      case DeviceStatus.received:
        return AppColors.info.withValues(alpha: 0.28);
      case DeviceStatus.waiting:
        return AppColors.outlineVariant;
      case DeviceStatus.inMaintenance:
        return AppColors.secondaryContainer.withValues(alpha: 0.4);
      case DeviceStatus.completed:
        return const Color(0xFFBBF7D0);
      case DeviceStatus.delivered:
        return AppColors.success.withValues(alpha: 0.32);
    }
  }
}
