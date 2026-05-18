// lib/features/inventory/inventory_screen.dart

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../localization/l10n.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 1024;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderSection(),
          const SizedBox(height: 24),
          _WarehouseGrid(isWide: isWide),
          const SizedBox(height: 24),
          const _InventoryTable(),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// Header with search & filter
// ------------------------------------------------------------------
class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory Systems',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Centralized management for global warehouse logistics and part tracking.',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        Row(
          children: [
            // Search field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.search,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 180,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search spare parts...',
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.filter_list),
              label: const Text('FILTERS'),
            ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------
// Warehouse cards grid
// ------------------------------------------------------------------
class _WarehouseGrid extends StatelessWidget {
  final bool isWide;
  const _WarehouseGrid({required this.isWide});

  @override
  Widget build(BuildContext context) {
    // Use two‑column layout on wide screens, single column otherwise.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 8, child: _MainHubCard()),
              SizedBox(width: 16),
              Expanded(flex: 4, child: _SecondaryCard()),
            ],
          );
        }
        return Column(
          children: const [
            _MainHubCard(),
            SizedBox(height: 16),
            _SecondaryCard(),
          ],
        );
      },
    );
  }
}

class _MainHubCard extends StatelessWidget {
  const _MainHubCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                // color: AppColors.secondaryFixed,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PRIORITY ALPHA',
                style: TextStyle(
                  //color: AppColors.onSecondaryFixedVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'North Sector Logistics Hub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.location_on, color: AppColors.primary, size: 16),
                SizedBox(width: 4),
                Text(
                  'Chicago, IL - Terminal 4',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Capacity',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.outline,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '88.4%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Metrics grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _MetricBox(
                  label: 'CRITICAL PARTS',
                  value: '12',
                  color: AppColors.error,
                ),
                _MetricBox(
                  label: 'TOTAL SKUs',
                  value: '4,102',
                  color: AppColors.primary,
                ),
                _MetricBox(
                  label: 'ACTIVE STAFF',
                  value: '24',
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              icon: Icon(Icons.arrow_forward),
              label: Text('VIEW INVENTORY'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryCard extends StatelessWidget {
  const _SecondaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'SECONDARY',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Eastern Transit Point',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.location_on, color: AppColors.primary, size: 16),
                SizedBox(width: 4),
                Text(
                  'Newark, NJ',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Storage Level',
              value: '42%',
              valueColor: AppColors.primary,
            ),
            _InfoRow(
              label: 'Incoming Today',
              value: '156 Units',
              valueColor: AppColors.secondary,
            ),
            _InfoRow(
              label: 'Pending Audits',
              value: '3',
              valueColor: AppColors.error,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
              onPressed: () {},
              child: const Text('EXPAND DETAILS'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricBox({
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 10,
              color: AppColors.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------
// Inventory table (static mock data)
// ------------------------------------------------------------------
class _InventoryTable extends StatelessWidget {
  const _InventoryTable({super.key});

  @override
  Widget build(BuildContext context) {
    // Header row
    Widget headerCell(String text) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: AppColors.outline,
        ),
      ),
    );
    return Card(
      child: Column(
        children: [
          Container(
            color: AppColors.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(child: headerCell('Part Identity')),
                Expanded(child: headerCell('Category')),
                Expanded(child: headerCell('Bin Location')),
                Expanded(child: headerCell('Quantity')),
                Expanded(child: headerCell('Status')),
                const SizedBox(width: 40), // actions column placeholder
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.outlineVariant,
          ),
          // Sample rows (three rows as in the HTML mockup)
          _TableRow(
            icon: Icons.settings_input_component,
            partName: 'AX-902 Linear Actuator',
            serial: 'SN: 882-LK-9022',
            category: 'HYDRAULICS',
            location: 'A-12-09',
            qty: '14',
            status: 'OPTIMAL',
            statusColor: AppColors.green,
            statusBg: AppColors.greenBg,
          ),
          _TableRow(
            icon: Icons.memory,
            partName: 'R-Series Logic Board v4',
            serial: 'SN: 441-RT-1109',
            category: 'ELECTRONICS',
            location: 'B-04-22',
            qty: '2',
            status: 'CRITICAL',
            statusColor: AppColors.yellow,
            statusBg: AppColors.yellowBg,
          ),
          _TableRow(
            icon: Icons.bolt,
            partName: 'High-Tension Gasket Set',
            serial: 'SN: 102-GK-5541',
            category: 'MECHANICAL',
            location: 'D-31-01',
            qty: '124',
            status: 'STOCKED',
            statusColor: AppColors.green,
            statusBg: AppColors.greenBg,
          ),
          // Footer pagination placeholder
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.outlineVariant,
          ),
          Container(
            color: AppColors.surfaceContainerLow,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'DISPLAYING 12 OF 4,102 ITEMS',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.outline,
                  ),
                ),
                // Pagination controls omitted for brevity
                SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final IconData icon;
  final String partName;
  final String serial;
  final String category;
  final String location;
  final String qty;
  final String status;
  final Color statusColor;
  final Color statusBg;
  const _TableRow({
    required this.icon,
    required this.partName,
    required this.serial,
    required this.category,
    required this.location,
    required this.qty,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          // Part Identity
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          serial,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Category
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                category,
                style: const TextStyle(fontSize: 12, color: AppColors.outline),
              ),
            ),
          ),
          // Bin Location
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                location,
                style: const TextStyle(color: AppColors.onSurface),
              ),
            ),
          ),
          // Qty
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                qty,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          // Status badge
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Action placeholder
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
