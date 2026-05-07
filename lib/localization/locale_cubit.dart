import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'locale_repository.dart';

class LocaleState {
  final Locale? locale;
  const LocaleState({required this.locale});
}

class LocaleCubit extends Cubit<LocaleState> {
  final LocaleRepository _repo;

  LocaleCubit(this._repo) : super(const LocaleState(locale: null)) {
    emit(LocaleState(locale: _repo.loadLocale()));
  }

  Future<void> setLocale(Locale locale) async {
    emit(LocaleState(locale: locale));
    await _repo.saveLocale(locale);
  }

  Future<void> toggleEnglishArabic() async {
    final current = state.locale?.languageCode;
    final next = (current ?? 'en') == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(next);
  }
}

