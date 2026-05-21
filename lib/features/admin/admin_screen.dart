import 'dart:async';

import 'package:engineering_ops_dashboard/features/admin/add_user_screen.dart';
import 'package:engineering_ops_dashboard/features/admin/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'users_cubit.dart';
import '../../di/service_locator.dart';
import '../../core/widgets/index_view_toggle.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../home/home_shell.dart';
import '../roles/presentation/cubit/roles_cubit.dart';
import '../roles/presentation/cubit/roles_state.dart';
import '../roles/presentation/pages/roles_page.dart';
import 'user_model.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UsersCubit()..fetchUsers()),
        BlocProvider(create: (_) => getIt<RolesCubit>()..fetch()),
      ],
      child: const _AdminView(),
    );
  }
}

class _AdminView extends StatefulWidget {
  const _AdminView();

  @override
  State<_AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<_AdminView> {
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
    if (position.pixels < position.maxScrollExtent - 320) return;

    final state = context.read<UsersCubit>().state;
    if (state is! UsersLoaded || state.page >= state.totalPages) return;

    context.read<UsersCubit>().nextPage(append: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<UsersCubit>().fetchUsers(
          page: 1,
          size: UsersCubit.defaultPageSize,
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HeaderSection(),
              const SizedBox(height: 24),
              const _UsersQueryPanel(),
              const SizedBox(height: 16),
              IndexViewControls(
                viewMode: _viewMode,
                onViewModeChanged: (mode) {
                  setState(() => _viewMode = mode);
                  context.read<UsersCubit>().fetchUsers(
                    page: 1,
                    size: UsersCubit.defaultPageSize,
                  );
                },
              ),
              const SizedBox(height: 16),
              _ActivePersonnelTable(viewMode: _viewMode),
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
    final title = Row(
      children: [
        IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () => HomeShell.openDrawer(context),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المستخدمون',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final roleButton = OutlinedButton.icon(
      onPressed: () async {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<RolesCubit>(),
              child: const RolesPage(),
            ),
          ),
        );
        if (context.mounted) context.read<RolesCubit>().fetch();
      },
      icon: const Icon(Icons.admin_panel_settings_outlined),
      label: const Text('الأدوار'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    final addButton = ElevatedButton.icon(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: 16),
          roleButton,
          const SizedBox(height: 12),
          addButton,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: title),
        const SizedBox(width: 12),
        SizedBox(width: 160, child: roleButton),
        const SizedBox(width: 12),
        SizedBox(width: 180, child: addButton),
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
  Timer? _searchDebounce;
  bool? _isActive;
  int? _roleId;
  String _sortBy = 'id';
  String _sortDirection = 'asc';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
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
              _RoleFilter(
                value: _roleId,
                onChanged: (value) {
                  setState(() => _roleId = value);
                  _applyQuery();
                },
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
      roleId: _roleId,
      isActive: _isActive,
      sortBy: _sortBy,
      sortDirection: _sortDirection,
    );
  }

  void _clearQuery() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _isActive = null;
      _roleId = null;
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

class _RoleFilter extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const _RoleFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: BlocBuilder<RolesCubit, RolesState>(
        builder: (context, state) {
          final roles = state is RolesLoaded ? state.roles : const [];
          return DropdownButtonFormField<int?>(
            initialValue: roles.any((role) => role.id == value) ? value : null,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.badge_outlined),
              hintText: 'الدور',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('الكل')),
              ...roles.map(
                (role) => DropdownMenuItem<int?>(
                  value: role.id,
                  child: Text(role.name),
                ),
              ),
            ],
            onChanged: onChanged,
          );
        },
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
    return SizedBox(
      width: 180,
      child: DropdownButton<bool?>(
        value: value,
        isExpanded: true,
        hint: const Text('الحالة', overflow: TextOverflow.ellipsis),
        items: const [
          DropdownMenuItem<bool?>(value: null, child: Text('الكل')),
          DropdownMenuItem<bool?>(value: true, child: Text('نشط')),
          DropdownMenuItem<bool?>(value: false, child: Text('غير نشط')),
        ],
        onChanged: onChanged,
      ),
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
    return SizedBox(
      width: 220,
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
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
      ),
    );
  }
}

class _RolePickerField extends StatelessWidget {
  final TextEditingController controller;

  const _RolePickerField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RolesCubit, RolesState>(
      builder: (context, state) {
        final roles = state is RolesLoaded ? state.roles : const [];
        if (roles.isEmpty) {
          return TextField(
            controller: controller,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(labelText: 'الدور'),
          );
        }

        final roleIds = roles.map((role) => role.id).toSet();
        final selectedRoleId = int.tryParse(controller.text);
        final current = roleIds.contains(selectedRoleId)
            ? selectedRoleId
            : null;

        return DropdownButtonFormField<int>(
          initialValue: current,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'الدور',
            border: OutlineInputBorder(),
          ),
          items: roles
              .map(
                (role) => DropdownMenuItem<int>(
                  value: role.id,
                  child: Text(role.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) controller.text = value.toString();
          },
        );
      },
    );
  }
}

class _ActivePersonnelTable extends StatelessWidget {
  final IndexViewMode viewMode;

  const _ActivePersonnelTable({required this.viewMode});

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
    if (status.contains('نشط') || s.contains('ACTIVE')) {
      return AppColors.green;
    }
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
    if (status.contains('نشط') || s.contains('ACTIVE')) {
      return AppColors.greenBg;
    }
    if (s.contains('ON')) {
      return AppColors.secondaryContainer.withValues(alpha: 0.2);
    }
    return AppColors.surface;
  }

  double _readDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
  }

  String? _dateOrNull(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return DateTime.tryParse(trimmed)?.toIso8601String() ?? trimmed;
  }

  String _formatDateInput(DateTime? value) {
    if (value == null) return '';
    return value.toIso8601String().split('T').first;
  }

  Future<void> _handleUserAction({
    required BuildContext context,
    required String value,
    required UserModel user,
    required String userId,
    required String name,
    required String roleName,
    required bool isActive,
    required String status,
  }) async {
    if (value == 'details') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => UserDetailsPage(user: user.toJson())),
      );
      return;
    }

    if (value == 'active' || value == 'inactive') {
      final cubit = context.read<UsersCubit>();
      final success = value == 'active'
          ? await cubit.activateUser(int.parse(userId))
          : await cubit.deactivateUser(int.parse(userId));

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (value == 'active'
                      ? 'تم تفعيل المستخدم'
                      : 'تم تعطيل المستخدم')
                : (value == 'active'
                      ? 'فشل تفعيل المستخدم'
                      : 'فشل تعطيل المستخدم'),
          ),
        ),
      );
      return;
    }

    if (value == 'update') {
      await _showUpdateDialog(
        context: context,
        user: user,
        userId: userId,
        name: name,
        roleId: user.roleId,
        isActive: isActive,
      );
    }
  }

  Future<void> _showUpdateDialog({
    required BuildContext context,
    required UserModel user,
    required String userId,
    required String name,
    required int roleId,
    required bool isActive,
  }) async {
    final nameController = TextEditingController(text: name);
    final roleController = TextEditingController(text: roleId.toString());
    final addressController = TextEditingController(text: user.address ?? '');
    final phoneController = TextEditingController(text: user.phoneNumber);
    final salaryController = TextEditingController(
      text: user.salary.toString(),
    );
    final workPercentageController = TextEditingController(
      text: user.workPercentage.toString(),
    );
    final birthController = TextEditingController(
      text: _formatDateInput(user.birthDay),
    );
    final employDateController = TextEditingController(
      text: _formatDateInput(user.employeDate),
    );
    final rolesCubit = context.read<RolesCubit>();

    await showDialog<void>(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: rolesCubit,
          child: AlertDialog(
            title: const Text('تعديل المستخدم'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(labelText: 'الاسم'),
                    ),
                    const SizedBox(height: 12),
                    _RolePickerField(controller: roleController),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(labelText: 'العنوان'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: salaryController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(labelText: 'الراتب'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: workPercentageController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'نسبة العمل',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: birthController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'تاريخ الميلاد',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: employDateController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'تاريخ التوظيف',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final success = await context.read<UsersCubit>().updateUser(
                    id: int.parse(userId),
                    data: {
                      'fullName': nameController.text.trim(),
                      'phoneNumber': phoneController.text.trim(),
                      'salary': _readDouble(salaryController.text),
                      'workPercentage': _readDouble(
                        workPercentageController.text,
                      ),
                      'birthDay': _dateOrNull(birthController.text),
                      'employeDate': _dateOrNull(employDateController.text),
                      'address': addressController.text.trim(),
                      'roleId': int.tryParse(roleController.text) ?? 0,
                      'isActive': isActive,
                    },
                  );

                  if (!context.mounted) return;

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'تم تحديث المستخدم' : 'فشل تحديث المستخدم',
                      ),
                    ),
                  );
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _userMenuItems() {
    return [
      const PopupMenuItem(
        value: 'active',
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text('تفعيل'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'inactive',
        child: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text('تعطيل'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'update',
        child: Row(
          children: [
            Icon(Icons.edit, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text('تعديل'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'details',
        child: Row(
          children: [
            Icon(Icons.visibility, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text('عرض التفاصيل'),
          ],
        ),
      ),
    ];
  }

  Future<void> _openAddUserPage(BuildContext context) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddUserScreen()),
    );

    if (created == true && context.mounted) {
      context.read<UsersCubit>().fetchUsers(
        page: 1,
        size: UsersCubit.defaultPageSize,
      );
    }
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
                const Expanded(
                  child: Text(
                    'المستخدمون',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
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
                        'المجموع $total',
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

              if (viewMode == IndexViewMode.grid) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 1080
                          ? 3
                          : width >= 680
                          ? 2
                          : 1;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 188,
                        ),
                        itemCount: users.length + 1,
                        itemBuilder: (context, index) {
                          if (index == users.length) {
                            return InkWell(
                              onTap: () => _openAddUserPage(context),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.xs,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainer,
                                  border: Border.all(
                                    color: AppColors.outlineVariant,
                                    width: 1,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.xs,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      size: 48,
                                      color: AppColors.outline,
                                    ),
                                    SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'إضافة مستخدم جديد',
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

                          final u = users[index];
                          final name = u.fullName;
                          final userId = u.id.toString();
                          final role = u.roleName;
                          final isActive = u.isActive;
                          final status = isActive ? 'نشط' : 'غير نشط';
                          final initials = _initialsFromName(
                            name.isEmpty ? '-' : name,
                          );

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
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
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name.isEmpty ? userId : name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '#$userId',
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.settings,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                      onSelected: (value) => _handleUserAction(
                                        context: context,
                                        value: value,
                                        user: u,
                                        userId: userId,
                                        name: name,
                                        roleName: role,
                                        isActive: isActive,
                                        status: status,
                                      ),
                                      itemBuilder: (_) => _userMenuItems(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  role.isEmpty ? '-' : role,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
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
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }

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
                    final u = entry.value;
                    final name = u.fullName;
                    final initials = _initialsFromName(
                      name.isEmpty ? '-' : name,
                    );
                    final userId = u.id.toString();
                    final role = u.roleName;
                    final isActive = u.isActive;
                    final status = isActive ? 'نشط' : 'غير نشط';
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
                              onSelected: (value) => _handleUserAction(
                                context: context,
                                value: value,
                                user: u,
                                userId: userId,
                                name: name,
                                roleName: role,
                                isActive: isActive,
                                status: status,
                              ),
                              itemBuilder: (_) => _userMenuItems(),
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
          if (viewMode == IndexViewMode.list) ...[
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
                                ? () =>
                                      context.read<UsersCubit>().previousPage()
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
