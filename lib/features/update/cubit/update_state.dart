import 'package:equatable/equatable.dart';

import '../models/update_info.dart';

/// Base class for all update-related states.
///
/// Uses a sealed hierarchy so consumers can exhaustively `switch` on states.
sealed class UpdateState extends Equatable {
  const UpdateState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no update check has been performed yet.
final class UpdateInitial extends UpdateState {
  const UpdateInitial();
}

/// An update check is currently in progress.
final class UpdateChecking extends UpdateState {
  const UpdateChecking();
}

/// The app is running the latest version — no update needed.
final class UpToDate extends UpdateState {
  const UpToDate();
}

/// An optional update is available. The user can dismiss this.
final class UpdateAvailable extends UpdateState {
  final UpdateInfo info;

  const UpdateAvailable(this.info);

  @override
  List<Object?> get props => [info];
}

/// A forced update is required. The user cannot proceed without updating.
final class ForceUpdateRequired extends UpdateState {
  final UpdateInfo info;

  const ForceUpdateRequired(this.info);

  @override
  List<Object?> get props => [info];
}

/// The update check failed with an error.
final class UpdateError extends UpdateState {
  final String message;

  const UpdateError(this.message);

  @override
  List<Object?> get props => [message];
}
