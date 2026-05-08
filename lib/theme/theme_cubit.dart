import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme_repository.dart';

class ThemeState {
  final bool isDarkMode;

  const ThemeState({required this.isDarkMode});

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;
}

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeRepository _repo;

  ThemeCubit(this._repo)
    : super(ThemeState(isDarkMode: _repo.loadIsDarkMode()));

  Future<void> setDarkMode(bool isDarkMode) async {
    emit(ThemeState(isDarkMode: isDarkMode));
    await _repo.saveIsDarkMode(isDarkMode);
  }

  Future<void> toggle() => setDarkMode(!state.isDarkMode);
}
