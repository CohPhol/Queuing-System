import 'package:flutter/material.dart';

import '../../application/services/local_storage_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _initialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Loads the previously saved theme.
  Future<void> initialize() async {
    if (_initialized) return;

    final savedTheme = await LocalStorageService.loadTheme();

    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _initialized = true;

    notifyListeners();
  }

  /// Switches between light and dark mode.
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    notifyListeners();

    if (_initialized) {
      LocalStorageService.saveTheme(
        _themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    }
  }
}
