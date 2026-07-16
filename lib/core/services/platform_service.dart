import 'dart:io' show Platform;

class PlatformService {
  static bool get isWindows {
    return Platform.isWindows;
  }

  static bool get isDesktop {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static bool get isMobile {
    return Platform.isAndroid || Platform.isIOS;
  }
}
