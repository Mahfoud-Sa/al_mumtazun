import 'package:flutter/material.dart';

import '../domain/entities/device.dart';

extension DeviceStatusPresentation on DeviceStatus {
  String get label {
    switch (this) {
      case DeviceStatus.received:
        return 'استلام';
      case DeviceStatus.waiting:
        return 'انتظار';
      case DeviceStatus.inMaintenance:
        return 'قيد الصيانة';
      case DeviceStatus.ready:
        return 'جاهز';
      case DeviceStatus.delivered:
        return 'تم تسليم العميل';
    }
  }

  Color indicatorColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (this) {
      case DeviceStatus.received:
        return Colors.blue;
      case DeviceStatus.waiting:
        return colorScheme.outline;
      case DeviceStatus.inMaintenance:
        return colorScheme.secondary;
      case DeviceStatus.ready:
      case DeviceStatus.delivered:
        return Colors.green;
    }
  }

  Color backgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    switch (this) {
      case DeviceStatus.received:
        return Colors.blue.withValues(alpha: isDark ? 0.2 : 0.12);
      case DeviceStatus.waiting:
        return colorScheme.surfaceContainerLow;
      case DeviceStatus.inMaintenance:
        return colorScheme.secondary.withValues(alpha: isDark ? 0.2 : 0.12);
      case DeviceStatus.ready:
        return Colors.green.withValues(alpha: isDark ? 0.2 : 0.12);
      case DeviceStatus.delivered:
        return Colors.green.withValues(alpha: isDark ? 0.25 : 0.15);
    }
  }

  Color foregroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    switch (this) {
      case DeviceStatus.received:
        return isDark ? Colors.blue.shade300 : Colors.blue.shade800;
      case DeviceStatus.waiting:
        return colorScheme.onSurfaceVariant;
      case DeviceStatus.inMaintenance:
        return isDark ? colorScheme.secondary : const Color(0xFFC05600);
      case DeviceStatus.ready:
        return isDark ? Colors.green.shade300 : Colors.green.shade800;
      case DeviceStatus.delivered:
        return isDark ? Colors.green.shade200 : Colors.green.shade900;
    }
  }

  Color borderColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    switch (this) {
      case DeviceStatus.received:
        return Colors.blue.withValues(alpha: isDark ? 0.4 : 0.28);
      case DeviceStatus.waiting:
        return colorScheme.outlineVariant;
      case DeviceStatus.inMaintenance:
        return colorScheme.secondary.withValues(alpha: isDark ? 0.4 : 0.28);
      case DeviceStatus.ready:
        return Colors.green.withValues(alpha: isDark ? 0.4 : 0.28);
      case DeviceStatus.delivered:
        return Colors.green.withValues(alpha: isDark ? 0.5 : 0.35);
    }
  }
}
