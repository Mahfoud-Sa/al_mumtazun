import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme/app_colors.dart';
import '../../domain/entities/role.dart';
import '../cubit/roles_cubit.dart';
import '../cubit/roles_state.dart';

class PermissionOption {
  final String key;
  final String label;
  final String group;

  const PermissionOption({
    required this.key,
    required this.label,
    required this.group,
  });
}

const permissionCatalog = [
  PermissionOption(
    key: 'dashboard.view',
    label: 'عرض لوحة التحكم',
    group: 'لوحة التحكم',
  ),
  PermissionOption(key: 'devices.view', label: 'عرض الأجهزة', group: 'الأجهزة'),
  PermissionOption(
    key: 'devices.manage',
    label: 'إضافة وتعديل الأجهزة',
    group: 'الأجهزة',
  ),
  PermissionOption(
    key: 'devices.update_status',
    label: 'تحديث حالة الجهاز',
    group: 'الأجهزة',
  ),
  PermissionOption(
    key: 'devices.add_notes',
    label: 'إضافة ملاحظات المهندس',
    group: 'الأجهزة',
  ),
  PermissionOption(
    key: 'invoices.view',
    label: 'عرض الفواتير',
    group: 'الفواتير',
  ),
  PermissionOption(
    key: 'invoices.manage',
    label: 'إضافة وتعديل وحذف الفواتير',
    group: 'الفواتير',
  ),
  PermissionOption(
    key: 'spare_parts.view',
    label: 'عرض قطع الغيار',
    group: 'قطع الغيار',
  ),
  PermissionOption(
    key: 'spare_parts.manage',
    label: 'إضافة وتعديل وحذف قطع الغيار',
    group: 'قطع الغيار',
  ),
  PermissionOption(
    key: 'users.view',
    label: 'عرض المستخدمين',
    group: 'المستخدمون',
  ),
  PermissionOption(
    key: 'users.manage',
    label: 'إضافة وتعديل وتفعيل وتعطيل المستخدمين',
    group: 'المستخدمون',
  ),
  PermissionOption(
    key: 'roles.manage',
    label: 'إدارة الأدوار والصلاحيات',
    group: 'الأدوار',
  ),
  PermissionOption(
    key: 'profile.manage',
    label: 'إدارة الملف الشخصي',
    group: 'الملف الشخصي',
  ),
];

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  @override
  void initState() {
    super.initState();
    context.read<RolesCubit>().fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primary),
          title: const Text(
            'الأدوار والصلاحيات',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: ElevatedButton.icon(
                onPressed: () => _showRoleDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('دور جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<RolesCubit, RolesState>(
          builder: (context, state) {
            if (state is RolesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is RolesError) {
              return Center(child: Text(state.message));
            }

            final roles = state is RolesLoaded ? state.roles : const <Role>[];
            if (roles.isEmpty) {
              return Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showRoleDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إنشاء أول دور'),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: roles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final role = roles[index];
                return _RoleCard(
                  role: role,
                  isSaving: state is RolesSaving,
                  onEdit: () => _showRoleDialog(context, role: role),
                  onDelete: () => _confirmDelete(context, role),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Role role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الدور'),
        content: Text(
          'هل تريد حذف "${role.name}"؟ سيبقى اسم الدور لدى المستخدمين المرتبطين به حتى يتم تغييره.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await context.read<RolesCubit>().removeRole(role.id);
  }

  Future<void> _showRoleDialog(BuildContext context, {Role? role}) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _RoleDialog(
        role: role,
        permissionGroups: _permissionGroups(),
        roleIdFromName: _roleIdFromName,
      ),
    );
  }

  Map<String, List<PermissionOption>> _permissionGroups() {
    final grouped = <String, List<PermissionOption>>{};
    for (final option in permissionCatalog) {
      grouped.putIfAbsent(option.group, () => []).add(option);
    }
    return grouped;
  }

  int _roleIdFromName(String name) => DateTime.now().millisecondsSinceEpoch;
}

class _RoleDialog extends StatefulWidget {
  final Role? role;
  final Map<String, List<PermissionOption>> permissionGroups;
  final int Function(String name) roleIdFromName;

  const _RoleDialog({
    required this.role,
    required this.permissionGroups,
    required this.roleIdFromName,
  });

  @override
  State<_RoleDialog> createState() => _RoleDialogState();
}

class _RoleDialogState extends State<_RoleDialog> {
  late final TextEditingController _nameController;
  late final Set<String> _selectedPermissions;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');
    _selectedPermissions = widget.role?.permissions.toSet() ?? <String>{};
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    final saved = await context.read<RolesCubit>().saveRole(
      Role(
        id: widget.role?.id ?? widget.roleIdFromName(name),
        name: name,
        permissions: _selectedPermissions.toList()..sort(),
      ),
    );

    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
      return;
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.role == null ? 'إنشاء دور' : 'تعديل الدور'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'اسم الدور',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'الصلاحيات',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...widget.permissionGroups.entries.map((entry) {
                return _PermissionGroup(
                  title: entry.key,
                  options: entry.value,
                  selected: _selectedPermissions,
                  onChanged: _isSaving
                      ? (_, _) {}
                      : (key, checked) {
                          setState(() {
                            if (checked) {
                              _selectedPermissions.add(key);
                            } else {
                              _selectedPermissions.remove(key);
                            }
                          });
                        },
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('حفظ'),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final Role role;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoleCard({
    required this.role,
    required this.isSaving,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    role.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'تعديل',
                  onPressed: isSaving ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'حذف',
                  onPressed: isSaving ? null : onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: role.permissions.isEmpty
                  ? const [Chip(label: Text('لا توجد صلاحيات'))]
                  : role.permissions.map((permission) {
                      return Chip(
                        label: Text(_permissionLabel(permission)),
                        backgroundColor: AppColors.surfaceContainerHigh,
                      );
                    }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _permissionLabel(String key) {
    for (final option in permissionCatalog) {
      if (option.key == key) return option.label;
    }
    return key;
  }
}

class _PermissionGroup extends StatelessWidget {
  final String title;
  final List<PermissionOption> options;
  final Set<String> selected;
  final void Function(String key, bool checked) onChanged;

  const _PermissionGroup({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              ...options.map((option) {
                return CheckboxListTile(
                  value: selected.contains(option.key),
                  onChanged: (checked) =>
                      onChanged(option.key, checked ?? false),
                  title: Text(option.label),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
