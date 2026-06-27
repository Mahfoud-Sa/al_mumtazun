import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/update_info.dart';

/// A non-dismissible dialog shown when a forced update is required.
///
/// The user cannot close this dialog or navigate away. The only action
/// available is "Update Now", which opens the app store.
class ForceUpdateDialog extends StatelessWidget {
  final UpdateInfo info;

  const ForceUpdateDialog._({required this.info});

  /// Shows the force update dialog using the provided [context].
  ///
  /// The [context] must have [MaterialLocalizations] in scope (i.e. it must
  /// be below a [MaterialApp]).
  static void show(BuildContext context, UpdateInfo info) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ForceUpdateDialog._(info: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      // Prevent back button from dismissing the dialog.
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.system_update_outlined,
          size: 48,
          color: colorScheme.error,
        ),
        title: const Text('تحديث مطلوب'),
        titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'يجب تحديث التطبيق إلى الإصدار ${info.latestVersion} للمتابعة.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _VersionChip(
              label: 'الحالي',
              version: info.currentVersion,
              color: colorScheme.error,
            ),
            const SizedBox(height: 6),
            _VersionChip(
              label: 'الأحدث',
              version: info.latestVersion,
              color: colorScheme.primary,
            ),
            if (info.releaseNotes != null && info.releaseNotes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                'ما الجديد:',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: SingleChildScrollView(
                  child: Text(
                    info.releaseNotes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _launchStore,
              icon: const Icon(Icons.download_outlined),
              label: const Text('تحديث الآن'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchStore() async {
    // TODO: Replace with actual Play Store / App Store URL.
    final url = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.gidteam.al_mumtazun&hl=ar',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

/// Small chip displaying a version label (e.g. "الحالي: 2.7.1").
class _VersionChip extends StatelessWidget {
  final String label;
  final String version;
  final Color color;

  const _VersionChip({
    required this.label,
    required this.version,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          version,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
