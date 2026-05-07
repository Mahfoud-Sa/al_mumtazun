import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSectionTitle('Settings'),
                ListTile(
                  leading: const Icon(
                    Icons.dark_mode_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: false, // Placeholder for theme toggle
                    onChanged: (val) {
                      // Trigger theme change here
                    },
                    activeColor: AppColors.secondary,
                  ),
                ),
                const Divider(),
                _buildSectionTitle('System'),
                ListTile(
                  leading: const Icon(
                    Icons.developer_mode,
                    color: AppColors.primary,
                  ),
                  title: const Text('Developer Options'),
                  onTap: () {
                    // Navigate to developer options
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('App Developer Rights'),
                  onTap: () {
                    // Open developer rights dialogue
                  },
                ),
                const Divider(),
                _buildSectionTitle('About'),
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
                      leading: const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                      ),
                      title: const Text('App Version'),
                      subtitle: Text('v$version (Build $buildNumber)'),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'EngineeredPrecision',
                          applicationVersion: 'v$version (Build $buildNumber)',
                          applicationIcon: const Icon(
                            Icons.engineering,
                            size: 48,
                            color: AppColors.secondary,
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
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      margin: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'AD',
                style: TextStyle(
                  color: Colors.white,
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
              children: const [
                Text(
                  'Admin User',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'admin@engineeredprecision.com',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.outline,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.engineering, size: 16, color: AppColors.outline),
            SizedBox(width: 8),
            Text(
              'EngineeredPrecision Ops',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
