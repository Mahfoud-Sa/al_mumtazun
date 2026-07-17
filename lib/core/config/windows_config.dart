import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowsConfig {
  WindowsConfig._();

  static Future<void> initialize() async {
    // Only execute on Windows.
    if (!Platform.isWindows) return;

    await windowManager.ensureInitialized();

    const options = WindowOptions(
      title: 'محل المتميزون',
      // size: Size(1366, 768),
      // minimumSize: Size(1100, 650),
      center: true,
      // backgroundColor: Colors.white,
      // skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
