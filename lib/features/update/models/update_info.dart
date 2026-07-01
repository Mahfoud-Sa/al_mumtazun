import 'package:equatable/equatable.dart';

/// Immutable data model representing the result of an update check.
///
/// Returned by [UpdateService.checkForUpdate] and consumed by [UpdateCubit]
/// to determine which state to emit.
class UpdateInfo extends Equatable {
  /// Whether a newer version exists on the remote.
  final bool hasUpdate;

  /// Whether the release requires a forced update.
  ///
  /// Determined by the presence of `force_update: true` in the
  /// GitHub release body.
  final bool isForceUpdate;

  /// The cleaned semantic version string of the latest release (e.g. "2.8.0").
  final String latestVersion;

  /// The cleaned semantic version string of the currently running app.
  final String currentVersion;

  /// Optional release notes from the GitHub release body.
  final String? releaseNotes;

  /// Whether the release body contained the force_update marker.
  final bool forceUpdateMarkerDetected;

  /// Optional download URL for the update (Play Store, App Store, etc.).
  ///
  /// Can be extended later to support per-platform URLs.
  final String? downloadUrl;

  const UpdateInfo({
    required this.hasUpdate,
    required this.isForceUpdate,
    required this.latestVersion,
    required this.currentVersion,
    this.releaseNotes,
    required this.forceUpdateMarkerDetected,
    this.downloadUrl,
  });

  @override
  List<Object?> get props => [
    hasUpdate,
    isForceUpdate,
    latestVersion,
    currentVersion,
    releaseNotes,
    forceUpdateMarkerDetected,
    downloadUrl,
  ];
}
