import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/update_service.dart';
import 'update_state.dart';

/// Cubit responsible for orchestrating the app update check flow.
///
/// Delegates all version comparison logic to [UpdateService] and emits
/// typed [UpdateState]s. This cubit has **no knowledge** of how dialogs
/// are displayed — that responsibility belongs to [UpdateListener].
///
/// ## Usage
/// ```dart
/// context.read<UpdateCubit>().checkForUpdates();
/// ```
class UpdateCubit extends Cubit<UpdateState> {
  final UpdateService _updateService;

  /// Guards against duplicate update checks within the same cubit lifetime.
  bool _hasChecked = false;

  UpdateCubit({required UpdateService updateService})
      : _updateService = updateService,
        super(const UpdateInitial());

  /// Performs a one-time update check.
  ///
  /// Subsequent calls are no-ops to prevent duplicate checks.
  /// Emits the following state transitions:
  ///
  /// `UpdateInitial → UpdateChecking → (UpToDate | UpdateAvailable | ForceUpdateRequired | UpdateError)`
  Future<void> checkForUpdates() async {
    if (_hasChecked) return;
    _hasChecked = true;

    emit(const UpdateChecking());

    try {
      final info = await _updateService.checkForUpdate();

      // If the service returned null (network error) or no update is
      // available, treat it as up-to-date so the app proceeds normally.
      if (info == null || !info.hasUpdate) {
        emit(const UpToDate());
        return;
      }

      if (info.isForceUpdate) {
        emit(ForceUpdateRequired(info));
      } else {
        emit(UpdateAvailable(info));
      }
    } catch (e) {
      emit(UpdateError(e.toString()));
    }
  }
}
