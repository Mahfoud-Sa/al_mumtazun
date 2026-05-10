import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'di/service_locator.dart';
import 'features/home/home_shell.dart';
import 'features/auth/auth_cubit.dart';
import 'features/auth/login_screen.dart';
import 'localization/locale_cubit.dart';
import 'theme/app_theme.dart';
import 'theme/theme_cubit.dart';
import 'l10n/app_localizations.dart';

class EngineeringOpsApp extends StatelessWidget {
  const EngineeringOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LocaleCubit>()),
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
      ],
      child: BlocProvider(
        create: (_) => AuthCubit(),
        // Show login first based on AuthCubit state.
        child: BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, localeState) {
            return BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return MaterialApp(
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context)!.appTitle,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light(),
                  darkTheme: AppTheme.dark(),
                  themeMode: themeState.themeMode,
                  home: BlocBuilder<AuthCubit, bool>(
                    builder: (context, authenticated) {
                      return authenticated
                          ? const HomeShell()
                          : const LoginScreen();
                    },
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
      ),
    );
  }
}
