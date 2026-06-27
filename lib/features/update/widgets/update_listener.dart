import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/navigation/app_navigator.dart';
import '../cubit/update_cubit.dart';
import '../cubit/update_state.dart';
import 'force_update_dialog.dart';

/// A coordinator widget that listens to [UpdateCubit] state changes and
/// displays the appropriate dialog using [appNavigatorKey].
///
/// This widget separates UI presentation from the cubit's business logic.
/// The cubit emits states; this listener reacts to them by showing dialogs.
///
/// ## Usage
/// Wrap the content **inside** [MaterialApp] so that [MaterialLocalizations]
/// are available:
///
/// ```dart
/// MaterialApp(
///   home: UpdateListener(
///     child: YourHomeWidget(),
///   ),
/// )
/// ```
class UpdateListener extends StatelessWidget {
  /// The child widget to render beneath this listener.
  final Widget child;

  const UpdateListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateCubit, UpdateState>(
      listener: (context, state) {
        // Use the global navigator key to obtain a context that is guaranteed
        // to be below MaterialApp (and thus has MaterialLocalizations).
        final navigatorContext = appNavigatorKey.currentContext;
        if (navigatorContext == null) return;

        switch (state) {
          case ForceUpdateRequired(:final info):
          case UpdateAvailable(:final info):
            ForceUpdateDialog.show(navigatorContext, info);
          case UpdateInitial():
          case UpdateChecking():
          case UpToDate():
          case UpdateError():
            // No dialog needed for these states.
            break;
        }
      },
      child: child,
    );
  }
}
