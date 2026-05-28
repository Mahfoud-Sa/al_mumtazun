import 'package:engineering_ops_dashboard/features/admin/admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../di/service_locator.dart';
import '../../theme/theme_cubit.dart';
import '../auth/auth_cubit.dart';
import '../auth/role_guard.dart';
import '../profile/presentation/cubit/profile_cubit.dart';
import '../profile/presentation/pages/profile_page.dart';
import '../roles/presentation/cubit/roles_cubit.dart';
import '../roles/presentation/pages/roles_page.dart';
import '../tools/tools_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfile(),
      child: Drawer(
        backgroundColor: colorScheme.surface,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.account_circle_outlined,
                      color: colorScheme.primary,
                    ),
                    title: const Text('الملف الشخصي'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.calculate_outlined,
                      color: colorScheme.primary,
                    ),
                    title: const Text('الادوات'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EngineeringToolsPage()),
                      );
                    },
                  ),
                  const Divider(),
                  _buildSectionTitle(context, 'الإعدادات'),
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, state) {
                      return SwitchListTile(
                        secondary: Icon(
                          state.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode_outlined,
                          color: colorScheme.primary,
                        ),
                        title: const Text('الوضع الداكن'),
                        value: state.isDarkMode,
                        onChanged: context.read<ThemeCubit>().setDarkMode,
                        activeThumbColor: colorScheme.secondary,
                      );
                    },
                  ),
                  const Divider(),
                  _buildSectionTitle(context, 'النظام'),
                  // ListTile(
                  //   leading: Icon(
                  //     Icons.developer_mode,
                  //     color: colorScheme.primary,
                  //   ),
                  //   title: const Text('Developer Options'),
                  //   onTap: () {
                  //     // Navigate to developer options.
                  //   },
                  // ),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (!_canOpenAdmin(state.user?.role)) {
                        return const SizedBox.shrink();
                      }

                      return ListTile(
                        leading: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: colorScheme.primary,
                        ),
                        title: const Text('لوحة الإدارة'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) {
                                return RoleGuard(
                                  allowedRoles: const ['Admin'],
                                  child: AdminScreen(),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (!_canOpenAdmin(state.user?.role)) {
                        return const SizedBox.shrink();
                      }

                      return ListTile(
                        leading: Icon(
                          Icons.security_outlined,
                          color: colorScheme.primary,
                        ),
                        title: const Text('الأدوار والصلاحيات'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) {
                                return RoleGuard(
                                  allowedRoles: const ['Admin'],
                                  child: BlocProvider(
                                    create: (_) => getIt<RolesCubit>(),
                                    child: const RolesPage(),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: colorScheme.primary),
                    title: const Text('تسجيل الخروج'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        context.read<AuthCubit>().logout();
                      } catch (_) {}
                    },
                  ),
                  const Divider(),
                  _buildSectionTitle(context, 'عن التطبيق'),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform().catchError(
                      (_) => PackageInfo(
                        appName: 'نظام المتميزون',
                        packageName: 'com.GidTeam.app',
                        version: '1.0.0',
                        buildNumber: '1',
                      ),
                    ),
                    builder: (context, snapshot) {
                      final version = snapshot.data?.version ?? '1.0.0';
                      final buildNumber = snapshot.data?.buildNumber ?? '1';
                      return ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                        ),
                        title: const Text('إصدار التطبيق'),
                        subtitle: Text('v$version (Build $buildNumber)'),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'نظام المتميزون',
                            applicationVersion:
                                'v$version (Build $buildNumber)',
                            applicationIcon: Icon(
                              Icons.engineering,
                              size: 48,
                              color: colorScheme.secondary,
                            ),
                            applicationLegalese:
                                'تم تطوير هذا التطبيق بواسطة فريق GidTeam. جميع الحقوق محفوظة.',
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final name = _displayValue(user?.fullName, 'المستخدم');
        final phoneNumber = _displayValue(
          user?.phoneNumber,
          'رقم الهاتف غير متوفر',
        );
        final role = _displayValue(
          user?.roleDisplayName ?? user?.role,
          'الدور غير متوفر',
        );

        return DrawerHeader(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          margin: EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: state.isLoading && user == null
                      ? SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          _initials(name),
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phoneNumber,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _displayValue(String? value, String fallback) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return fallback;
    return trimmed;
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';

    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts.last.characters.first : '';
    return (first + second).toUpperCase();
  }

  bool _canOpenAdmin(String? role) {
    final normalized = role?.trim().toLowerCase();
    return normalized == 'admin' || normalized == 'مطور';
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.engineering, size: 16, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              'نظام المتميزون - لوحة التحكم',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
