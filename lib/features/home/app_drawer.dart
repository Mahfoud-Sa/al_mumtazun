import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../theme/theme_cubit.dart';
import '../auth/auth_cubit.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSectionTitle(context, 'Settings'),
                BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, state) {
                    return SwitchListTile(
                      secondary: Icon(
                        state.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode_outlined,
                        color: colorScheme.primary,
                      ),
                      title: const Text('Dark Mode'),
                      value: state.isDarkMode,
                      onChanged: context.read<ThemeCubit>().setDarkMode,
                      activeColor: colorScheme.secondary,
                    );
                  },
                ),
                const Divider(),
                _buildSectionTitle(context, 'System'),
                ListTile(
                  leading: Icon(
                    Icons.developer_mode,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Developer Options'),
                  onTap: () {
                    // Navigate to developer options.
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('App Developer Rights'),
                  onTap: () {
                    // Open developer rights dialogue.
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: colorScheme.primary),
                  title: const Text('Logout'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    try {
                      context.read<AuthCubit>().logout();
                    } catch (_) {}
                  },
                ),
                const Divider(),
                _buildSectionTitle(context, 'About'),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform().catchError(
                    (_) => PackageInfo(
                      appName: 'EngineeredPrecision',
                      packageName: 'com.example.app',
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
                      title: const Text('App Version'),
                      subtitle: Text('v$version (Build $buildNumber)'),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'EngineeredPrecision',
                          applicationVersion: 'v$version (Build $buildNumber)',
                          applicationIcon: Icon(
                            Icons.engineering,
                            size: 48,
                            color: colorScheme.secondary,
                          ),
                          applicationLegalese:
                              '© 2026 EngineeredPrecision Inc.',
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DrawerHeader(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
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
              child: Text(
                'AD',
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
                  'Admin User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'admin@engineeredprecision.com',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
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
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorScheme.outline,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.engineering, size: 16, color: colorScheme.outline),
            const SizedBox(width: 8),
            Text(
              'EngineeredPrecision Ops',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
