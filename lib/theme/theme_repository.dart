import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const _prefKey = 'isDarkMode';

  final SharedPreferences _prefs;
  ThemeRepository(this._prefs);

  bool loadIsDarkMode() {
    return _prefs.getBool(_prefKey) ?? false;
  }

  Future<void> saveIsDarkMode(bool isDarkMode) {
    return _prefs.setBool(_prefKey, isDarkMode);
  }
}
