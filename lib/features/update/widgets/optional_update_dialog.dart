import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/update_info.dart';

/// A dismissible dialog shown when an optional update is available.
///
/// The user can either update or dismiss the dialog and continue using the app.
class OptionalUpdateDialog extends StatelessWidget {
  final UpdateInfo info;

  const OptionalUpdateDialog._({required this.info});

  /// Shows the optional update dialog using the provided [context].
  ///
  /// The [context] must have [MaterialLocalizations] in scope (i.e. it must
  /// be below a [MaterialApp]).
  static void show(BuildContext context, UpdateInfo info) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => OptionalUpdateDialog._(info: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: Icon(
        Icons.system_update_outlined,
        size: 48,
        color: colorScheme.secondary,
      ),
      title: const Text('تحديث متاح'),
      titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'يتوفر إصدار جديد (${info.latestVersion}). هل تود التحديث الآن؟',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (info.releaseNotes != null &&
              info.releaseNotes!.isNotEmpty) ...[
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'لاحقًا',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton.icon(
          onPressed: () async {
            // TODO: Replace with actual Play Store / App Store URL.
            final url = Uri.parse(
              'https://play.google.com/store/apps/details?id=YOUR_APP_ID',
            );
            await launchUrl(url, mode: LaunchMode.externalApplication);
          },
          icon: const Icon(Icons.download_outlined),
          label: const Text('تحديث'),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
