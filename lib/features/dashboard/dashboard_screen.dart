import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../di/service_locator.dart';
import '../../localization/l10n.dart';
import '../../theme/app_colors.dart';
import 'state/dashboard_cubit.dart';
import '../home/home_shell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider(
      create: (_) => getIt<DashboardCubit>()..fetch(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, dash) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isLarge = width >= 1100;
              final isMedium = width >= 760 && width < 1100;
              final horizontalPadding = isLarge ? 32.0 : 16.0;

              return Scaffold(
                body: RefreshIndicator(
                  onRefresh: () => context.read<DashboardCubit>().refresh(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // ======================================================
                      // APP BAR
                      // ======================================================
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
                              icon: const Icon(
                                Icons.menu,
                                color: AppColors.primary,
                              ),
                              onPressed: () => HomeShell.openDrawer(context),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                l10n.dashboard,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ======================================================
                      // BODY
                      // ======================================================
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
                                onRangeChanged: (i) => context
                                    .read<DashboardCubit>()
                                    .setRangeIndex(i),
                              ),
                              if (dash.isLoading) ...[
                                const SizedBox(height: 16),
                                const LinearProgressIndicator(),
                              ],
                              if (dash.errorMessage != null) ...[
                                const SizedBox(height: 16),
                                _DashboardErrorBanner(
                                  message: dash.errorMessage!,
                                  onRetry: () =>
                                      context.read<DashboardCubit>().fetch(),
                                ),
                              ],
                              const SizedBox(height: 24),

                              _BentoGrid(
                                isLarge: isLarge,
                                isMedium: isMedium,
                                state: dash,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DashboardErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.onErrorContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('إعادة المحاولة'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ======================================================
// GRID SECTION
// ======================================================
//

class _BentoGrid extends StatelessWidget {
  final bool isLarge;
  final bool isMedium;
  final DashboardState state;

  const _BentoGrid({
    required this.isLarge,
    required this.isMedium,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.count(
      crossAxisCount: 12,
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
      children: [
        StaggeredGridTile.fit(
          crossAxisCellCount: isLarge ? 8 : 12,
          child: _TotalIncomeCard(state: state),
        ),

        StaggeredGridTile.fit(
          crossAxisCellCount: isLarge ? 4 : 12,
          child: _LogisticsPerformanceCard(state: state),
        ),

        StaggeredGridTile.fit(
          crossAxisCellCount: isLarge ? 6 : 12,
          child: _ResourceAllocationCard(state: state),
        ),

        StaggeredGridTile.fit(
          crossAxisCellCount: isLarge ? 6 : 12,
          child: _CriticalLogsCard(logs: state.criticalLogs),
        ),

        // ======================================================
        // 🆕 ENGINEERING OVERVIEW (NEW SECTION)
        // ======================================================
        StaggeredGridTile.fit(
          crossAxisCellCount: isLarge ? 6 : 12,
          child: _EngineeringOverviewCard(state: state),
        ),
      ],
    );
  }
}

//
// ======================================================
// ENGINEERING OVERVIEW CARD
// ======================================================
//

class _EngineeringOverviewCard extends StatelessWidget {
  final DashboardState state;

  const _EngineeringOverviewCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.engineeringOverview,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // ================= TOP STATS =================
            Row(
              children: [
                _MiniStat(l10n.engineering, "${state.totalEngineering}"),
                const SizedBox(width: 10),
                _MiniStat(l10n.components, "${state.totalComponents}"),
                const SizedBox(width: 10),
                _MiniStat(l10n.invoices, "${state.totalInvoices}"),
              ],
            ),

            const SizedBox(height: 20),

            // ================= PIE CHART =================
            LayoutBuilder(
              builder: (context, c) {
                final compact = c.maxWidth < 420;

                return compact
                    ? Column(
                        children: [
                          _StatusPieChart(data: state.statusMetrics),
                          const SizedBox(height: 16),
                          _StatusLegend(data: state.statusMetrics),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _StatusPieChart(data: state.statusMetrics),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatusLegend(data: state.statusMetrics),
                          ),
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//
// ======================================================
// PIE CHART
// ======================================================
//

class _StatusPieChart extends StatelessWidget {
  final List<DashboardStatusMetric> data;

  const _StatusPieChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(painter: _PiePainter(data)),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<DashboardStatusMetric> data;

  _PiePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    double startAngle = -math.pi / 2;

    final total = data.fold<double>(0, (a, b) => a + b.value);
    if (total <= 0) return;

    final paint = Paint()..style = PaintingStyle.fill;

    for (final item in data) {
      final sweep = (item.value / total) * (math.pi * 2);

      paint.color = item.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) =>
      oldDelegate.data != data;
}

//
// ======================================================
// LEGEND
// ======================================================
//

class _StatusLegend extends StatelessWidget {
  final List<DashboardStatusMetric> data;

  const _StatusLegend({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: data
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: e.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_statusLabel(l10n, e.status))),
                  Text("${e.value}"),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

//
// ======================================================
// MINI STAT CARD
// ======================================================
//

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}

//
// ======================================================
// MODEL
// ======================================================
//

// ======================================================
// 💰 TOTAL INCOME CARD
// Shows income + mini chart
// ======================================================

class _TotalIncomeCard extends StatelessWidget {
  final DashboardState state;

  const _TotalIncomeCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Text(
              l10n.totalIncome,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 12),

            // BIG VALUE
            Text(
              _formatCurrency(state.monthlyIncome),
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // TREND
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${state.incomeDelta} ${l10n.thisMonth}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // SIMPLE CHART AREA (placeholder style)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: state.incomeChart.isEmpty
                  ? Center(child: Text(l10n.incomeChart))
                  : _IncomeMiniChart(data: state.incomeChart),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeMiniChart extends StatelessWidget {
  final List<DashboardIncomePoint> data;

  const _IncomeMiniChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold<double>(
      0,
      (max, item) => item.value > max ? item.value : max,
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final item in data.take(14)) ...[
            Expanded(
              child: Tooltip(
                message: '${item.label}: ${_formatCurrency(item.value)}',
                child: FractionallySizedBox(
                  heightFactor: maxValue <= 0 ? 0 : (item.value / maxValue),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

// ======================================================
// 🚚 LOGISTICS PERFORMANCE CARD
// Shows efficiency + turnover metrics
// ======================================================

class _LogisticsPerformanceCard extends StatelessWidget {
  final DashboardState state;

  const _LogisticsPerformanceCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.logisticsPerformance,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 16),

            // TURNOVER
            Text(l10n.inventoryTurnoverRate),
            const SizedBox(height: 6),
            Text(
              '${state.inventoryTurnover.toStringAsFixed(1)}x',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 16),

            // EFFICIENCY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.efficiency),
                Text(
                  _formatPercent(state.efficiency),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: state.efficiency,
              color: Colors.green,
              backgroundColor: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// 📊 RESOURCE ALLOCATION CARD
// Shows staff/resource usage
// ======================================================

class _ResourceAllocationCard extends StatelessWidget {
  final DashboardState state;

  const _ResourceAllocationCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.resourceAllocation,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 16),

            for (
              var index = 0;
              index < state.resourceMetrics.length;
              index++
            ) ...[
              if (index > 0) const SizedBox(height: 10),
              _buildRow(
                _resourceLabel(l10n, state.resourceMetrics[index].type),
                state.resourceMetrics[index].value,
                state.resourceMetrics[index].color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text("${(value * 100).toInt()}%")],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          color: color,
          backgroundColor: Colors.grey.shade300,
        ),
      ],
    );
  }
}

// ======================================================
// 🚨 CRITICAL LOGS CARD
// Shows system alerts / engineering issues
// ======================================================

class _CriticalLogsCard extends StatelessWidget {
  final List<DashboardLogEntry> logs;

  const _CriticalLogsCard({required this.logs});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.criticalEngineeringLogs,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w700),
                ),
                TextButton(onPressed: () {}, child: Text(l10n.viewAll)),
              ],
            ),
          ),

          const Divider(height: 1),

          for (final log in logs)
            _logItem(
              icon: log.icon,
              title: log.title.trim().isEmpty
                  ? _logTitle(l10n, log.type)
                  : log.title,
              subtitle: log.subtitle.trim().isEmpty
                  ? _logSubtitle(l10n, log.type)
                  : log.subtitle,
              color: log.color,
            ),
        ],
      ),
    );
  }

  Widget _logItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

String _statusLabel(dynamic l10n, DashboardDeviceStatus status) {
  switch (status) {
    case DashboardDeviceStatus.received:
      return l10n.received;
    case DashboardDeviceStatus.waiting:
      return l10n.waiting;
    case DashboardDeviceStatus.inMaintenance:
      return l10n.inMaintenance;
    case DashboardDeviceStatus.completed:
      return l10n.completed;
    case DashboardDeviceStatus.delivered:
      return l10n.delivered;
  }
}

String _resourceLabel(dynamic l10n, DashboardResourceType type) {
  switch (type) {
    case DashboardResourceType.active:
      return l10n.active;
    case DashboardResourceType.onLeave:
      return l10n.onLeave;
    case DashboardResourceType.available:
      return l10n.available;
  }
}

String _logTitle(dynamic l10n, DashboardLogType type) {
  switch (type) {
    case DashboardLogType.deviceOverheating:
      return l10n.deviceOverheatingDetected;
    case DashboardLogType.lowStock:
      return l10n.lowStockAlert;
    case DashboardLogType.repairCompleted:
      return l10n.repairCompleted;
  }
}

String _logSubtitle(dynamic l10n, DashboardLogType type) {
  switch (type) {
    case DashboardLogType.deviceOverheating:
      return l10n.deviceOverheatingSubtitle;
    case DashboardLogType.lowStock:
      return l10n.lowStockSubtitle;
    case DashboardLogType.repairCompleted:
      return l10n.repairCompletedSubtitle;
  }
}

String _formatCurrency(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final buffer = StringBuffer();
  for (var i = 0; i < parts.first.length; i++) {
    final fromEnd = parts.first.length - i;
    buffer.write(parts.first[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
  }
  return '\$${buffer.toString()}.${parts.last}';
}

String _formatPercent(double value) => '${(value * 100).round()}%';

// ======================================================
// 🧭 DASHBOARD HEADER ROW
// Shows title + time range selector
// ======================================================

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

    // LEFT SIDE (TITLE SECTION)
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.managementSystem,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          l10n.dashboardOverview,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    final right = _RangeSelector(
      selectedIndex: rangeIndex,
      onChanged: onRangeChanged,
    );
    // RESPONSIVE LAYOUT
    if (isStacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [left, const SizedBox(height: 12), right],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        right,
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
    const labels = ['أسبوع', 'شهر', 'سنة'];

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < labels.length; index++)
            TextButton(
              onPressed: selectedIndex == index ? null : () => onChanged(index),
              style: TextButton.styleFrom(
                minimumSize: const Size(64, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                foregroundColor: selectedIndex == index
                    ? Colors.white
                    : AppColors.onSurface,
                disabledForegroundColor: Colors.white,
                backgroundColor: selectedIndex == index
                    ? AppColors.secondary
                    : Colors.transparent,
                disabledBackgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(labels[index]),
            ),
        ],
      ),
    );
  }
}
