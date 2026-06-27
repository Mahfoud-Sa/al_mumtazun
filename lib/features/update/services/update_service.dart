import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../models/update_info.dart';

/// Service responsible for checking whether an app update is available.
///
/// Fetches the latest release from GitHub, reads the current app version
/// via [PackageInfo], compares semantic versions, and returns an [UpdateInfo].
///
/// This service is context-free and designed to be registered as a singleton
/// in the service locator.
class UpdateService {
  /// GitHub repository owner.
  static const String _owner = 'Mahfoud-Sa';

  /// GitHub repository name.
  static const String _repo = 'al_mumtazun';

  /// Checks for an available update by comparing the running app version
  /// against the latest GitHub release.
  ///
  /// Returns `null` if the network request fails or the response is invalid.
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = _cleanVersion(packageInfo.version);

      final latestRelease = await _fetchLatestRelease();
      if (latestRelease == null) return null;

      final latestVersion =
          _cleanVersion(latestRelease['tag_name'] as String? ?? '0.0.0');

      final hasUpdate = _isNewer(latestVersion, currentVersion);

      // Pre-releases are never treated as forced updates.
      final isPreRelease = latestRelease['prerelease'] == true;
      final isForceUpdate =
          isPreRelease ? false : _isForceUpdate(latestRelease);

      return UpdateInfo(
        hasUpdate: hasUpdate,
        isForceUpdate: isForceUpdate,
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        releaseNotes: latestRelease['body'] as String?,
      );
    } catch (_) {
      // Network or parsing error — fail silently so the app isn't blocked.
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Fetches the latest release JSON from the GitHub API.
  Future<Map<String, dynamic>?> _fetchLatestRelease() async {
    final url = Uri.parse(
      'https://api.github.com/repos/$_owner/$_repo/releases/latest',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  /// Strips the leading "v" and surrounding whitespace from a version string.
  String _cleanVersion(String version) {
    return version.replaceAll('v', '').trim();
  }

  /// Returns `true` if [latest] is semantically newer than [current].
  ///
  /// Compares major, minor, and patch segments left-to-right.
  bool _isNewer(String latest, String current) {
    final latestParts = _parseVersionParts(latest);
    final currentParts = _parseVersionParts(current);

    for (int i = 0; i < 3; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  /// Parses a version string (e.g. "2.7.1") into three integer segments.
  ///
  /// Falls back to `0` for missing or invalid segments.
  List<int> _parseVersionParts(String version) {
    final parts = version.split('.');
    return List.generate(3, (i) {
      if (i >= parts.length) return 0;
      return int.tryParse(parts[i]) ?? 0;
    });
  }

  /// Checks whether the release body contains the `force_update: true` marker.
  bool _isForceUpdate(Map<String, dynamic> release) {
    final body = (release['body'] as String? ?? '').toLowerCase();
    return body.contains('force_update: true');
  }
}
