import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final _themeBox = Hive.box('settings');
  static const _themeModeKey = 'themeMode';

  void _loadThemeMode() {
    final savedThemeMode = _themeBox.get(_themeModeKey);
    if (savedThemeMode != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _themeBox.put(_themeModeKey, state.toString());
  }

  void setThemeMode(ThemeMode newThemeMode) {
    state = newThemeMode;
    _themeBox.put(_themeModeKey, state.toString());
  }
}
