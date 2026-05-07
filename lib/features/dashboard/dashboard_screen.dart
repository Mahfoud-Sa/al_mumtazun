import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../localization/l10n.dart';
import '../../localization/locale_cubit.dart';
import '../../theme/app_colors.dart';
import 'state/dashboard_cubit.dart';
import '../home/home_shell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) => DashboardCubit(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, dash) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isLarge = width >= 1100;
              final isMedium = width >= 760 && width < 1100;
              final horizontalPadding = isLarge ? 32.0 : 16.0;

              return Scaffold(
                body: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: AppColors.surface,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      toolbarHeight: 64,
                      titleSpacing: horizontalPadding,
                      title: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: AppColors.primary),
                            onPressed: () => HomeShell.openDrawer(context),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                l10n.appBarTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      actionsPadding: EdgeInsets.only(right: horizontalPadding),
                      actions: [
                        if (isLarge || isMedium) ...[
                          _TopNavLink(
                            label: l10n.dashboard,
                            selected: true,
                            onTap: () {},
                          ),
                          _TopNavLink(
                            label: l10n.income,
                            selected: false,
                            onTap: () {},
                          ),
                          _TopNavLink(
                            label: l10n.inventory,
                            selected: false,
                            onTap: () {},
                          ),
                          _TopNavLink(
                            label: l10n.engineering,
                            selected: false,
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                        ],
                        IconButton(
                          tooltip: l10n.language,
                          onPressed: () => _showLanguageSheet(context),
                          icon:
                              const Icon(Icons.language, color: AppColors.primary),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.outlineVariant),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: const _ProfileAvatar(),
                            ),
                          ),
                        ),
                      ],
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(1),
                        child: Container(
                          height: 1,
                          color: AppColors.outlineVariant,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        24,
                        horizontalPadding,
                        96,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeaderRow(
                              isStacked: !(isLarge || isMedium),
                              rangeIndex: dash.rangeIndex,
                              onRangeChanged: (i) =>
                                  context.read<DashboardCubit>().setRangeIndex(i),
                            ),
                            const SizedBox(height: 24),
                            _BentoGrid(isLarge: isLarge, isMedium: isMedium),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final l10n = context.l10n;
    final current = context.read<LocaleCubit>().state.locale?.languageCode;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(l10n.language),
                  subtitle: Text(current == 'ar' ? l10n.arabic : l10n.english),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.abc),
                  title: Text(l10n.english),
                  trailing: current == 'en' ? const Icon(Icons.check) : null,
                  onTap: () async {
                    await context.read<LocaleCubit>().setLocale(const Locale('en'));
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: Text(l10n.arabic),
                  trailing: current == 'ar' ? const Icon(Icons.check) : null,
                  onTap: () async {
                    await context.read<LocaleCubit>().setLocale(const Locale('ar'));
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopNavLink extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TopNavLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            label,
            style: style.copyWith(
              color: selected ? AppColors.secondary : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final bool isStacked;
  final int rangeIndex;
  final ValueChanged<int> onRangeChanged;

  const _HeaderRow({
    required this.isStacked,
    required this.rangeIndex,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.managementSystem.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.dashboardInsights,
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: AppColors.primary,
              ),
        ),
      ],
    );

    final right = _RangeSelector(
      selectedIndex: rangeIndex,
      onChanged: onRangeChanged,
    );

    if (isStacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          const SizedBox(height: 12),
          right,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Flexible(
          child: Align(
            alignment: Alignment.bottomRight,
            child: right,
          ),
        ),
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _RangeSelector({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RangeChip(
              label: l10n.weekly,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
            _RangeChip(
              label: l10n.last30Days,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
            _RangeChip(
              label: l10n.yearly,
              selected: selectedIndex == 2,
              onTap: () => onChanged(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge!;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: style.copyWith(
            color: selected ? Colors.white : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BentoGrid extends StatelessWidget {
  final bool isLarge;
  final bool isMedium;

  const _BentoGrid({required this.isLarge, required this.isMedium});

  @override
  Widget build(BuildContext context) {
    int incomeSpan;
    int logisticsSpan;
    int resourceSpan;
    int logsSpan;

    if (isLarge) {
      incomeSpan = 8;
      logisticsSpan = 4;
      resourceSpan = 6;
      logsSpan = 6;
    } else if (isMedium) {
      incomeSpan = 12;
      logisticsSpan = 6;
      resourceSpan = 6;
      logsSpan = 12;
    } else {
      incomeSpan = 12;
      logisticsSpan = 12;
      resourceSpan = 12;
      logsSpan = 12;
    }

    return StaggeredGrid.count(
      crossAxisCount: 12,
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      children: [
        StaggeredGridTile.fit(
          crossAxisCellCount: incomeSpan,
          child: const _TotalIncomeCard(),
        ),
        StaggeredGridTile.fit(
          crossAxisCellCount: logisticsSpan,
          child: const _LogisticsPerformanceCard(),
        ),
        StaggeredGridTile.fit(
          crossAxisCellCount: resourceSpan,
          child: const _ResourceAllocationCard(),
        ),
        StaggeredGridTile.fit(
          crossAxisCellCount: logsSpan,
          child: const _CriticalLogsCard(),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _TotalIncomeCard extends StatelessWidget {
  const _TotalIncomeCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalIncome.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      r'$1,248,392.50',
                      style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 16,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.incomeDelta,
                          style:
                              Theme.of(context).textTheme.labelLarge!.copyWith(
                                    color: AppColors.green,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: CustomPaint(
                        painter: _IncomeChartPainter(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 10,
                    child: Text(
                      'Jun 01',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 10,
                    child: Text(
                      'Jun 30',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paddingBottom = 18.0;
    final h = size.height - paddingBottom;
    final w = size.width;

    final points = <Offset>[
      Offset(0, h * 0.75),
      Offset(w * 0.25, h * 0.80),
      Offset(w * 0.50, h * 0.55),
      Offset(w * 0.75, h * 0.35),
      Offset(w, h * 0.18),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final cx = (p0.dx + p1.dx) / 2;
      path.quadraticBezierTo(cx, p0.dy, p1.dx, p1.dy);
    }

    final strokePaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, h + paddingBottom)
      ..lineTo(0, h + paddingBottom)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.secondaryContainer.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LogisticsPerformanceCard extends StatelessWidget {
  const _LogisticsPerformanceCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.logisticsPerformance.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.inventoryTurnoverRate.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: AppColors.outline,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.turnoverValue,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.efficiency.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.efficiencyValue,
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.efficiencyDelta,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResourceAllocationCard extends StatelessWidget {
  const _ResourceAllocationCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.resourceAllocation.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final isTight = c.maxWidth < 420;
              return isTight
                  ? Column(
                      children: const [
                        _CapacityRing(),
                        SizedBox(height: 16),
                        _AllocationLegend(),
                      ],
                    )
                  : const Row(
                      children: [
                        Expanded(child: _CapacityRing()),
                        SizedBox(width: 16),
                        Expanded(child: _AllocationLegend()),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _CapacityRing extends StatelessWidget {
  const _CapacityRing();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: SizedBox(
        width: 132,
        height: 132,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 132,
              height: 132,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 12,
                color: AppColors.surfaceContainer,
                backgroundColor: AppColors.surfaceContainer,
              ),
            ),
            SizedBox(
              width: 132,
              height: 132,
              child: Transform.rotate(
                angle: -math.pi / 2,
                child: CircularProgressIndicator(
                  value: 0.82,
                  strokeWidth: 12,
                  color: AppColors.secondary,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '82%',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.capacity.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AllocationLegend extends StatelessWidget {
  const _AllocationLegend();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        _LegendRow(color: AppColors.green, label: l10n.active, value: '126'),
        const SizedBox(height: 10),
        _LegendRow(color: Colors.amber, label: l10n.onLeave, value: '14'),
        const SizedBox(height: 10),
        _LegendRow(
          color: AppColors.outlineVariant,
          label: l10n.available,
          value: '14',
        ),
        const SizedBox(height: 14),
        Text(
          l10n.avgResponseTime.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.avgResponseValue,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: AppColors.primary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _CriticalLogsCard extends StatelessWidget {
  const _CriticalLogsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.criticalEngineeringLogs.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    l10n.viewAll,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _LogRow(
            bg: AppColors.redBg,
            fg: AppColors.red,
            icon: Icons.report_outlined,
            title: l10n.log1Title,
            subtitle: l10n.log1Subtitle,
            chipLabel: l10n.log1Chip,
          ),
          _LogRow(
            bg: AppColors.yellowBg,
            fg: AppColors.yellow,
            icon: Icons.inventory_2_outlined,
            title: l10n.log2Title,
            subtitle: l10n.log2Subtitle,
            chipLabel: l10n.log2Chip,
          ),
          _LogRow(
            bg: AppColors.blueBg,
            fg: AppColors.blue,
            icon: Icons.notification_important_outlined,
            title: l10n.log3Title,
            subtitle: l10n.log3Subtitle,
            chipLabel: l10n.log3Chip,
          ),
          _LogRow(
            bg: AppColors.greenBg,
            fg: AppColors.green,
            icon: Icons.verified_outlined,
            title: l10n.log4Title,
            subtitle: l10n.log4Subtitle,
            chipLabel: l10n.log4Chip,
          ),
          _LogRow(
            bg: AppColors.redBg,
            fg: AppColors.red,
            icon: Icons.priority_high,
            title: l10n.log5Title,
            subtitle: l10n.log5Subtitle,
            chipLabel: l10n.log5Chip,
          ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final Color bg;
  final Color fg;
  final IconData icon;
  final String title;
  final String subtitle;
  final String chipLabel;

  const _LogRow({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.chipLabel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bg.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                chipLabel.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: fg,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  static const _url =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDZnWQ7hM2PyDY7Li8u0DD1vmxDWQ1APHRuL4RaYgyxEmBynLYXIJTBidSo4fr2UNxKy4kcH8O_wru3HY8cHiqFSYIUFMCAGqzMei08I58FW_CdfuiR3ToaUKpZpHnYBOU4lkC9waJuLMAa4NeD5d6EP_M3LDQJyXEZVTOYQBsUFAMeZyR0V39HHLg9MkAzXB-Ii894Kn9FNaiyPfr9-lGkozdD8NFkVC2NLC0EWXecnfLHGCPxrYOVRP91W2CmvFtdIDGYSMwFTcj8';

  @override
  Widget build(BuildContext context) {
    const isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');
    if (isFlutterTest) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: ColoredBox(
          color: AppColors.surfaceContainer,
          child: Center(child: Icon(Icons.person)),
        ),
      );
    }

    return Image.network(
      _url,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) {
        return const SizedBox(
          width: 40,
          height: 40,
          child: Center(child: Icon(Icons.person)),
        );
      },
    );
  }
}

