import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../models/update_info.dart';

/// Service responsible for checking whether an app update is available.
///
/// Fetches the latest release from GitHub, reads the current app version
/// via [PackageInfo], compares semantic versions, and returns an [UpdateInfo].
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

      final latestVersion = _cleanVersion(
        latestRelease['tag_name'] as String? ?? '0.0.0',
      );

      final hasUpdate = _isNewer(latestVersion, currentVersion);

      // Pre-releases are never treated as forced updates.
      final isPreRelease = latestRelease['prerelease'] == true;
      final forceUpdateMarkerDetected = _isForceUpdate(latestRelease);
      final isForceUpdate = isPreRelease ? false : forceUpdateMarkerDetected;

      return UpdateInfo(
        hasUpdate: hasUpdate,
        isForceUpdate: isForceUpdate,
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        releaseNotes: latestRelease['body'] as String?,
        forceUpdateMarkerDetected: forceUpdateMarkerDetected,
      );
    } catch (_) {
      // Fail silently so the app isn't blocked.
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

  /// Cleans Git version strings:
  /// - removes leading "v" or "v."
  /// - removes prerelease suffixes like "-beta", "-rc", "-prerelease"
  /// - trims whitespace
  String _cleanVersion(String version) {
    return version
        .toLowerCase()
        .replaceAll(RegExp(r'^v\.?'), '')
        .replaceAll(RegExp(r'-.*$'), '')
        .trim();
  }

  /// Returns true if [latest] is semantically newer than [current].
  bool _isNewer(String latest, String current) {
    final latestParts = _parseVersionParts(latest);
    final currentParts = _parseVersionParts(current);

    for (int i = 0; i < 3; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  /// Safely parses version string into [major, minor, patch].
  ///
  /// Removes all non-numeric characters safely before parsing.
  List<int> _parseVersionParts(String version) {
    final cleaned = version.replaceAll(RegExp(r'[^0-9.]'), '');
    final parts = cleaned.split('.');

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
