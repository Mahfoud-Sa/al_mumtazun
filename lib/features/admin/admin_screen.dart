import 'dart:async';

import 'package:engineering_ops_dashboard/features/admin/add_user_screen.dart';
import 'package:engineering_ops_dashboard/features/admin/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'users_cubit.dart';
import '../../theme/app_colors.dart';
import '../home/home_shell.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UsersCubit()..fetchUsers(),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _HeaderSection(),
              SizedBox(height: 24),
              _UsersQueryPanel(),
              SizedBox(height: 16),
              _ActivePersonnelTable(),
            ],
          ),
        ),
      ),
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
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
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
                  'المستخدمون',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'إدارة المستخدمين والأدوار والحالة والتفاصيل',
                  maxLines: 2,
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
        SizedBox(
          width: isWide ? 180 : double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const AddUserScreen()),
              );
              if (created == true && context.mounted) {
                context.read<UsersCubit>().fetchUsers(page: 1);
              }
            },
            icon: const Icon(Icons.person_add),
            label: const Text('إضافة مستخدم'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UsersQueryPanel extends StatefulWidget {
  const _UsersQueryPanel();

  @override
  State<_UsersQueryPanel> createState() => _UsersQueryPanelState();
}

class _UsersQueryPanelState extends State<_UsersQueryPanel> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  Timer? _searchDebounce;
  bool? _isActive;
  String _sortBy = 'id';
  String _sortDirection = 'asc';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final controls = <Widget>[
              _SearchBox(
                controller: _searchController,
                onChanged: _queueSearch,
                onSubmitted: (_) => _applyQuery(),
              ),
              _RoleBox(
                controller: _roleController,
                onChanged: _queueSearch,
                onSubmitted: _applyQuery,
              ),
              _StatusFilter(
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                  _applyQuery();
                },
              ),
              _SortFilter(
                sortBy: _sortBy,
                sortDirection: _sortDirection,
                onChanged: (sortBy, sortDirection) {
                  setState(() {
                    _sortBy = sortBy;
                    _sortDirection = sortDirection;
                  });
                  _applyQuery();
                },
              ),
              OutlinedButton.icon(
                onPressed: _clearQuery,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('تصفية'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.outlineVariant),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ];

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: controls
                    .map(
                      (control) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: control,
                      ),
                    )
                    .toList(),
              );
            }

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: controls,
            );
          },
        ),
      ),
    );
  }

  void _queueSearch(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), _applyQuery);
  }

  void _applyQuery() {
    _searchDebounce?.cancel();
    context.read<UsersCubit>().applyQuery(
      search: _searchController.text,
      role: _roleController.text,
      isActive: _isActive,
      sortBy: _sortBy,
      sortDirection: _sortDirection,
    );
  }

  void _clearQuery() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _roleController.clear();
    setState(() {
      _isActive = null;
      _sortBy = 'id';
      _sortDirection = 'asc';
    });
    context.read<UsersCubit>().clearQuery();
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _SearchBox({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: AppColors.outline),
          hintText: 'البحث بالاسم أو الهاتف',
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.secondary),
          ),
          isDense: true,
        ),
      ),
    );
  }
}

class _RoleBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  const _RoleBox({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted(),
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.badge_outlined),
          hintText: 'الدور',
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.secondary),
          ),
          isDense: true,
        ),
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?> onChanged;

  const _StatusFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<bool?>(
      value: value,
      hint: const Text('الحالة'),
      items: const [
        DropdownMenuItem<bool?>(value: null, child: Text('الكل')),
        DropdownMenuItem<bool?>(value: true, child: Text('نشط')),
        DropdownMenuItem<bool?>(value: false, child: Text('غير نشط')),
      ],
      onChanged: onChanged,
    );
  }
}

class _SortFilter extends StatelessWidget {
  final String sortBy;
  final String sortDirection;
  final void Function(String sortBy, String sortDirection) onChanged;

  const _SortFilter({
    required this.sortBy,
    required this.sortDirection,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final value = '$sortBy:$sortDirection';
    return DropdownButton<String>(
      value: value,
      items: const [
        DropdownMenuItem(value: 'id:asc', child: Text('الرقم تصاعدي')),
        DropdownMenuItem(value: 'id:desc', child: Text('الرقم تنازلي')),
        DropdownMenuItem(value: 'fullName:asc', child: Text('الاسم تصاعدي')),
        DropdownMenuItem(value: 'fullName:desc', child: Text('الاسم تنازلي')),
        DropdownMenuItem(value: 'salary:asc', child: Text('الراتب تصاعدي')),
        DropdownMenuItem(value: 'salary:desc', child: Text('الراتب تنازلي')),
      ],
      onChanged: (next) {
        if (next == null) return;
        final parts = next.split(':');
        onChanged(parts[0], parts[1]);
      },
    );
  }
}

class _ActivePersonnelTable extends StatelessWidget {
  const _ActivePersonnelTable();

  String _initialsFromName(String name) {
    final parts = name.trim().split(' ').where((part) => part.isNotEmpty);
    return parts
        .map((p) => p.isNotEmpty ? p[0] : '')
        .take(2)
        .join()
        .toUpperCase();
  }

  Color _statusColor(String status) {
    final s = status.toUpperCase();
    if (status.contains('غير نشط') ||
        s.contains('INACTIVE') ||
        s.contains('OFF') ||
        s.contains('OFFLINE')) {
      return AppColors.outline;
    }
    if (status.contains('نشط') || s.contains('ACTIVE')) return AppColors.green;
    if (s.contains('ON')) return AppColors.secondaryContainer;
    return AppColors.onSurfaceVariant;
  }

  Color _statusBg(String status) {
    final s = status.toUpperCase();
    if (status.contains('غير نشط') ||
        s.contains('INACTIVE') ||
        s.contains('OFF') ||
        s.contains('OFFLINE')) {
      return AppColors.surfaceContainerHighest;
    }
    if (status.contains('نشط') || s.contains('ACTIVE'))
      return AppColors.greenBg;
    if (s.contains('ON')) {
      return AppColors.secondaryContainer.withValues(alpha: 0.2);
    }
    return AppColors.surface;
  }

  double _readDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
  }

  String _dateOrToday(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return DateTime.now().toIso8601String().split('T').first;
  }

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
                const Text(
                  "المستخدمون",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                BlocBuilder<UsersCubit, UsersState>(
                  builder: (context, state) {
                    final total = state is UsersLoaded ? state.totalCount : 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8E3FA),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'الإجمالي $total',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2A3B),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          BlocBuilder<UsersCubit, UsersState>(
            builder: (context, state) {
              if (state is UsersLoading) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is UsersError) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('فشل تحميل المستخدمين: ${state.message}'),
                );
              }

              final users = state is UsersLoaded ? state.users : <dynamic>[];

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.surfaceContainerLow,
                  ),
                  columnSpacing: 32,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'المستخدم',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'الرقم',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'الدور',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'الحالة',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'الإجراءات',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  rows: users.asMap().entries.map((entry) {
                    final i = entry.key;
                    final u = entry.value as Map<String, dynamic>;
                    final name = (u['fullName'] ?? u['name'] ?? '') as String;
                    final initials = _initialsFromName(
                      name.isEmpty ? '-' : name,
                    );
                    final userId = (u['employeeId'] ?? u['id'] ?? '')
                        .toString();
                    final role = (u['role'] ?? '') as String;
                    final isActive = u['isActive'] == true;
                    final status =
                        (u['status'] ?? u['state'])?.toString() ??
                        (isActive ? 'نشط' : 'غير نشط');
                    return DataRow(
                      color: WidgetStateProperty.all(
                        i.isOdd ? AppColors.surfaceContainerLow : Colors.white,
                      ),
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFF1A2B3C),
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF8192A7),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                name.isEmpty ? userId : name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            userId,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            role,
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusBg(status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _statusColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _statusColor(status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.settings,
                                color: AppColors.onSurfaceVariant,
                              ),
                              onSelected: (value) async {
                                // ================= ACTIVATE =================
                                if (value == 'details') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UserDetailsPage(user: u),
                                    ),
                                  );
                                }
                                if (value == 'active') {
                                  final success = await context
                                      .read<UsersCubit>()
                                      .activateUser(int.parse(userId));

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'تم تفعيل المستخدم'
                                            : 'فشل تفعيل المستخدم',
                                      ),
                                    ),
                                  );
                                }

                                // ================= DEACTIVATE =================

                                if (value == 'inactive') {
                                  final success = await context
                                      .read<UsersCubit>()
                                      .deactivateUser(int.parse(userId));

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'تم تعطيل المستخدم'
                                            : 'فشل تعطيل المستخدم',
                                      ),
                                    ),
                                  );
                                }

                                // ================= UPDATE =================

                                if (value == 'update') {
                                  final nameController = TextEditingController(
                                    text: name,
                                  );

                                  final roleController = TextEditingController(
                                    text: role,
                                  );

                                  final addressController =
                                      TextEditingController(
                                        text: u['address']?.toString() ?? '',
                                      );

                                  final phoneController = TextEditingController(
                                    text: u['phoneNumber']?.toString() ?? '',
                                  );

                                  final salaryController =
                                      TextEditingController(
                                        text: (u['salary'] ?? 0).toString(),
                                      );

                                  final workPercentageController =
                                      TextEditingController(
                                        text: (u['workPercentage'] ?? 0)
                                            .toString(),
                                      );

                                  final birthController = TextEditingController(
                                    text: u['birthDay']?.toString() ?? '',
                                  );

                                  final employDateController =
                                      TextEditingController(
                                        text:
                                            u['employeDate']?.toString() ?? '',
                                      );

                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: const Text('تعديل المستخدم'),
                                        content: SingleChildScrollView(
                                          child: SizedBox(
                                            width: 400,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: nameController,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'الاسم',
                                                      ),
                                                ),

                                                const SizedBox(height: 12),

                                                TextField(
                                                  controller: roleController,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'الدور',
                                                      ),
                                                ),

                                                const SizedBox(height: 12),

                                                TextField(
                                                  controller: addressController,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'العنوان',
                                                      ),
                                                ),

                                                const SizedBox(height: 12),

                                                TextField(
                                                  controller: phoneController,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'رقم الهاتف',
                                                      ),
                                                ),
                                                const SizedBox(height: 12),

                                                TextField(
                                                  controller: salaryController,
                                                  keyboardType:
                                                      const TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'الراتب',
                                                      ),
                                                ),
                                                const SizedBox(height: 12),

                                                TextField(
                                                  controller:
                                                      workPercentageController,
                                                  keyboardType:
                                                      const TextInputType.numberWithOptions(
                                                        decimal: true,
                                                      ),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'نسبة العمل',
                                                      ),
                                                ),
                                                const SizedBox(height: 12),

                                                TextField(
                                                  controller: birthController,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            'تاريخ الميلاد',
                                                      ),
                                                ),
                                                const SizedBox(height: 12),

                                                TextField(
                                                  controller:
                                                      employDateController,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            'تاريخ التوظيف',
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('إلغاء'),
                                          ),

                                          ElevatedButton(
                                            onPressed: () async {
                                              final success = await context
                                                  .read<UsersCubit>()
                                                  .updateUser(
                                                    id: int.parse(userId),
                                                    data: {
                                                      'fullName': nameController
                                                          .text
                                                          .trim(),
                                                      'phoneNumber':
                                                          phoneController.text
                                                              .trim(),
                                                      'salary': _readDouble(
                                                        salaryController.text,
                                                      ),
                                                      'workPercentage': _readDouble(
                                                        workPercentageController
                                                            .text,
                                                      ),
                                                      'birthDay': _dateOrToday(
                                                        birthController.text,
                                                      ),
                                                      'employeDate':
                                                          _dateOrToday(
                                                            employDateController
                                                                .text,
                                                          ),
                                                      'address':
                                                          addressController.text
                                                              .trim(),
                                                      'role': roleController
                                                          .text
                                                          .trim(),
                                                      'isActive': isActive,
                                                    },
                                                  );

                                              if (!context.mounted) return;

                                              Navigator.pop(context);

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    success
                                                        ? 'تم تحديث المستخدم'
                                                        : 'فشل تحديث المستخدم',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text('حفظ'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }

                                // ================= DETAILS =================

                                if (value == 'details') {
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: Text(name),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('الرقم: $userId'),

                                            const SizedBox(height: 8),

                                            Text('الدور: $role'),

                                            const SizedBox(height: 8),

                                            Text(
                                              'رقم الهاتف: ${u['phoneNumber'] ?? '-'}',
                                            ),

                                            const SizedBox(height: 8),

                                            Text(
                                              'العنوان: ${u['address'] ?? '-'}',
                                            ),

                                            const SizedBox(height: 8),

                                            Text('الحالة: $status'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('إغلاق'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'active',
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('تفعيل'),
                                    ],
                                  ),
                                ),

                                PopupMenuItem(
                                  value: 'inactive',
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('تعطيل'),
                                    ],
                                  ),
                                ),

                                PopupMenuItem(
                                  value: 'update',
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('تعديل'),
                                    ],
                                  ),
                                ),

                                PopupMenuItem(
                                  value: 'details',
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.visibility,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text('عرض التفاصيل'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),
          BlocBuilder<UsersCubit, UsersState>(
            builder: (context, state) {
              final loaded = state is UsersLoaded ? state : null;
              final page = loaded?.page ?? 1;
              final size = loaded?.size ?? UsersCubit.defaultPageSize;
              final totalCount = loaded?.totalCount ?? 0;
              final totalPages = loaded?.totalPages ?? 1;
              final start = totalCount == 0 ? 0 : ((page - 1) * size) + 1;
              final end = totalCount == 0
                  ? 0
                  : (start + (loaded?.users.length ?? 0) - 1).clamp(
                      start,
                      totalCount,
                    );
              final canGoPrevious = loaded != null && page > 1;
              final canGoNext = loaded != null && page < totalPages;

              return Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final summary = Text(
                      'عرض $start-$end من $totalCount | الصفحة $page من $totalPages',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    );
                    final controls = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PaginationButton(
                          icon: Icons.chevron_left,
                          onPressed: canGoPrevious
                              ? () => context.read<UsersCubit>().previousPage()
                              : null,
                        ),
                        const SizedBox(width: 8),
                        _PaginationButton(
                          icon: Icons.chevron_right,
                          onPressed: canGoNext
                              ? () => context.read<UsersCubit>().nextPage()
                              : null,
                        ),
                      ],
                    );

                    if (constraints.maxWidth < 420) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          summary,
                          const SizedBox(height: 12),
                          controls,
                        ],
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
          ),
        ],
      ),
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
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}
