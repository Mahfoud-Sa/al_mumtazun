import 'package:engineering_ops_dashboard/core/config/windows_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/navigation/app_navigator.dart';
import 'di/service_locator.dart';
import 'features/auth/auth_cubit.dart';
import 'features/auth/login_screen.dart';
import 'features/home/app_shell.dart';
import 'features/update/cubit/update_cubit.dart';
import 'features/update/widgets/update_listener.dart';
import 'l10n/app_localizations.dart';
import 'localization/locale_cubit.dart';
import 'theme/app_theme.dart';
import 'theme/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  // Configure the native Windows window (does nothing on Android/iOS).
  await WindowsConfig.initialize();
  runApp(const EngineeringOpsApp());
}

class EngineeringOpsApp extends StatelessWidget {
  const EngineeringOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LocaleCubit>()),
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
        BlocProvider(create: (_) => getIt<AuthCubit>()..loadCurrent()),
        BlocProvider(create: (_) => getIt<UpdateCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, localeState) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp(
                title: 'محل المتميزون',
                navigatorKey: appNavigatorKey,
                onGenerateTitle: (context) =>
                    AppLocalizations.of(context)!.appTitle,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: themeState.themeMode,
                home: UpdateListener(
                  child: BlocListener<AuthCubit, AuthState>(
                    listenWhen: (previous, current) =>
                        !previous.isInitialized && current.isInitialized,
                    listener: (context, state) {
                      // Trigger the update check exactly once after auth
                      // initialization completes. At this point MaterialApp
                      // is fully built, so dialogs can be shown safely.
                      context.read<UpdateCubit>().checkForUpdates();
                    },
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (!state.isInitialized) {
                          return const Scaffold(
                            body: Center(child: CircularProgressIndicator()),
                          );
                        }

                        return state.isLoggedIn
                            ? const AppShell()
                            : const LoginScreen();
                      },
                    ),
                  ),
                ),
                locale: localeState.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              );
            },
          );
        },
      ),
    );
  }
}
