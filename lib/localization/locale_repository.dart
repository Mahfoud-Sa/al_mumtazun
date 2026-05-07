import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleRepository {
  static const _prefKey = 'locale';

  final SharedPreferences _prefs;
  LocaleRepository(this._prefs);

  Locale? loadLocale() {
    final code = _prefs.getString(_prefKey);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  Future<void> saveLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(_prefKey);
      return;
    }
    await _prefs.setString(_prefKey, locale.languageCode);
  }
}

