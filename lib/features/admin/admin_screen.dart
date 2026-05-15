import 'package:engineering_ops_dashboard/features/admin/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'users_cubit.dart';
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
      // floatingActionButton: MediaQuery.of(context).size.width < 1024
      //     ? FloatingActionButton(
      //         onPressed: () {},
      //         backgroundColor: AppColors.secondary,
      //         foregroundColor: Colors.white,
      //         child: const Icon(Icons.person_add),
      //       )
      //     : null,
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
        IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () => HomeShell.openDrawer(context),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'اداره المستخدمين',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "قم باداره المستخدمين و المهندسين في النظام عبر هذه الشاشة يمكنك اضافه مهندسين جدد و تعديل بياناتهم و حذفهم",
              maxLines: 3,
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
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
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'البحث بالاسم او الهويه ...',
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

    // Provide UsersCubit to children and fetch initial data
    return BlocProvider(
      create: (_) => UsersCubit()..fetchUsers(),
      child: Builder(
        builder: (context) {
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 4, child: _AddEngineerForm()),
                SizedBox(width: 24),
                Expanded(flex: 8, child: _ActivePersonnelTable()),
              ],
            );
          }

          return Column(
            children: const [
              _AddEngineerForm(),
              SizedBox(height: 24),
              _ActivePersonnelTable(),
            ],
          );
        },
      ),
    );
  }
}

class _AddEngineerForm extends StatefulWidget {
  const _AddEngineerForm();

  @override
  _AddEngineerFormState createState() => _AddEngineerFormState();
}

class _AddEngineerFormState extends State<_AddEngineerForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _employDateController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _birthController.dispose();
    _employDateController.dispose();
    super.dispose();
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.person_add, color: AppColors.secondary),
                SizedBox(width: 8),
                Text(
                  'اضافه مهندس جديد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildField(
              "اسم المهندس",
              "م.ث: محمد احمد علي",
              controller: _nameController,
            ),
            _buildField(
              "الموقع",
              "م.ث:المكلا\\عدن\\تولبه",
              controller: _locationController,
            ),
            _buildField(
              "رقم الهاتف",
              "م.ث: 771234567",
              controller: _phoneController,
            ),
            _buildField("الدور", "م.ث: مهندس", controller: _roleController),
            _buildDateField(
              "تاريخ الميلاد",
              "يوم/شهر/سنة",
              controller: _birthController,
            ),
            _buildDateField(
              "تاريخ التوظيف",
              "يوم/شهر/سنة",
              controller: _employDateController,
            ),
            const SizedBox(height: 16),
            //   _buildField('EMPLOYEE ID', 'ENG-XXXX'),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submitEngineer(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'اضافه المهندس',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint, {
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF7F9FB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.secondary),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    String hint, {
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF7F9FB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.secondary),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(1990),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                // store dates in ISO yyyy-MM-dd expected by the API
                controller.text = picked.toIso8601String().split('T').first;
              });
            }
          },
        ),
      ],
    );
  }

  Future<void> _submitEngineer(BuildContext context) async {
    final uri = Uri.parse('http://al-mumtazun-api.runasp.net/api/Users');
    final payload = {
      'id': 0,
      'fullName': _nameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'birthDay': _birthController.text.isEmpty
          ? DateTime.now().toIso8601String().split('T').first
          : _birthController.text,
      'employeDate': _employDateController.text.isEmpty
          ? DateTime.now().toIso8601String().split('T').first
          : _employDateController.text,
      'address': _locationController.text.trim(),
      'role': _roleController.text.trim(),
    };

    try {
      final resp = await http.post(
        uri,
        headers: {'accept': 'text/plain', 'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('مهندس تم اضافته بنجاح')));
        // clear form
        _nameController.clear();
        _locationController.clear();
        _phoneController.clear();
        _roleController.clear();
        _birthController.clear();
        _employDateController.clear();
        // refresh users via cubit
        try {
          context.read<UsersCubit>().fetchUsers();
        } catch (_) {}
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${resp.statusCode} ${resp.reasonPhrase}'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل بالاتصال: $e')));
    }
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
    if (s.contains('INACTIVE') || s.contains('OFF') || s.contains('OFFLINE')) {
      return AppColors.outline;
    }
    if (s.contains('ACTIVE')) return AppColors.green;
    if (s.contains('ON')) return AppColors.secondaryContainer;
    return AppColors.onSurfaceVariant;
  }

  Color _statusBg(String status) {
    final s = status.toUpperCase();
    if (s.contains('INACTIVE') || s.contains('OFF') || s.contains('OFFLINE')) {
      return AppColors.surfaceContainerHighest;
    }
    if (s.contains('ACTIVE')) return AppColors.greenBg;
    if (s.contains('ON')) {
      return AppColors.secondaryContainer.withValues(alpha: 0.2);
    }
    return AppColors.surface;
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
                  "المهندسين",
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
                        'TOTAL $total',
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
                  child: Text('خطأ في جلب البيانات: ${state.message}'),
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
                        'المهندس',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'رقم الهوية',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'الوظيفة',
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
                        'العمليات',
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
                      name.isEmpty ? '—' : name,
                    );
                    final userId = (u['employeeId'] ?? u['id'] ?? '')
                        .toString();
                    final role = (u['role'] ?? '') as String;
                    final isActive = u['isActive'] == true;
                    final status =
                        (u['status'] ?? u['state'])?.toString() ??
                        (isActive ? 'ACTIVE' : 'INACTIVE');
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
                                                        labelText: 'الوظيفة',
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
                                                      'id': int.parse(userId),
                                                      'fullName':
                                                          nameController.text,
                                                      'role':
                                                          roleController.text,
                                                      'address':
                                                          addressController
                                                              .text,
                                                      'phoneNumber':
                                                          phoneController.text,
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

                                            Text('الوظيفة: $role'),

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
                      'Showing $start-$end of $totalCount | Page $page of $totalPages',
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
