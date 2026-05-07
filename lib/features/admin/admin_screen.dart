import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../home/home_shell.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeaderSection(),
            const SizedBox(height: 24),
            _ContentGrid(),
          ],
        ),
      ),
      floatingActionButton: MediaQuery.of(context).size.width < 1024
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;
    return Flex(
      direction: isWide ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isWide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () => HomeShell.openDrawer(context),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'User Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                SizedBox(height: 4),
                Text(
                  'Configure and monitor access for engineering personnel.',
                  style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
        if (!isWide) const SizedBox(height: 16),
        Container(
          width: isWide ? 384 : double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: const [
              Icon(Icons.search, color: AppColors.outline, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID or role...',
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContentGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1024;
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 4, child: _AddEngineerForm()),
          const SizedBox(width: 24),
          Expanded(flex: 8, child: _ActivePersonnelTable()),
        ],
      );
    }
    return Column(
      children: [
        const _AddEngineerForm(),
        const SizedBox(height: 24),
        _ActivePersonnelTable(),
      ],
    );
  }
}

class _AddEngineerForm extends StatelessWidget {
  const _AddEngineerForm();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.person_add, color: AppColors.secondary),
                SizedBox(width: 8),
                Text('Add New Engineer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 24),
            _buildField('ENGINEER NAME', 'e.g. Marcus Thorne'),
            const SizedBox(height: 16),
            _buildField('EMPLOYEE ID', 'ENG-XXXX'),
            const SizedBox(height: 16),
            const Text('ROLE ALLOCATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FB),
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: 'Structural Engineer',
                  items: const [
                    DropdownMenuItem(value: 'Structural Engineer', child: Text('Structural Engineer')),
                    DropdownMenuItem(value: 'Systems Architect', child: Text('Systems Architect')),
                    DropdownMenuItem(value: 'Precision Lead', child: Text('Precision Lead')),
                    DropdownMenuItem(value: 'Field Technician', child: Text('Field Technician')),
                  ],
                  onChanged: (val) {},
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('PROVISION ACCOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF7F9FB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.outlineVariant), borderRadius: BorderRadius.circular(4)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.secondary), borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }
}

class _ActivePersonnelTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Personnel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFD8E3FA), borderRadius: BorderRadius.circular(999)),
                  child: const Text('34 TOTAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1F2A3B))),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.surfaceContainerLow),
              columnSpacing: 32,
              columns: const [
                DataColumn(label: Text('ENGINEER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant))),
                DataColumn(label: Text('ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant))),
                DataColumn(label: Text('ROLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant))),
              ],
              rows: [
                _buildRow('Jane Doe', 'JD', 'ENG-9042', 'Systems Architect', 'ACTIVE', AppColors.green, AppColors.greenBg, isAlternate: false),
                _buildRow('Samuel Kincaid', 'SK', 'ENG-8811', 'Lead Structural', 'ON SITE', AppColors.secondaryContainer, AppColors.secondaryContainer.withValues(alpha: 0.2), isAlternate: true),
                _buildRow('Aisha Lopez', 'AL', 'ENG-7729', 'Precision Lead', 'ACTIVE', AppColors.green, AppColors.greenBg, isAlternate: false),
                _buildRow('Robert Vance', 'RV', 'ENG-4402', 'Systems Architect', 'OFFLINE', AppColors.outline, AppColors.surfaceContainerHighest, isAlternate: true),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Showing 1-4 of 34', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: AppColors.outlineVariant), borderRadius: BorderRadius.circular(4)),
                      child: IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: AppColors.outlineVariant), borderRadius: BorderRadius.circular(4)),
                      child: IconButton(icon: const Icon(Icons.chevron_right, size: 20), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(String name, String initials, String id, String role, String status, Color statusColor, Color statusBg, {required bool isAlternate}) {
    return DataRow(
      color: WidgetStateProperty.all(isAlternate ? AppColors.surfaceContainerLow : Colors.white),
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(radius: 16, backgroundColor: const Color(0xFF1A2B3C), child: Text(initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF8192A7)))),
              const SizedBox(width: 16),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
        ),
        DataCell(Text(id, style: const TextStyle(fontFamily: 'monospace', color: AppColors.onSurfaceVariant))),
        DataCell(Text(role, style: const TextStyle(color: AppColors.onSurfaceVariant))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
              ],
            ),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.settings, color: AppColors.onSurfaceVariant),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
