
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';

final colorPaletteProvider = StateNotifierProvider<ColorPaletteNotifier, AppColorPalette>((ref) {
  return ColorPaletteNotifier();
});

class ColorPaletteNotifier extends StateNotifier<AppColorPalette> {
  ColorPaletteNotifier() : super(AppColorPalette.palettes.first) {
    _loadColorPalette();
  }

  final _settingsBox = Hive.box('settings');
  static const _colorPaletteKey = 'colorPalette';

  void _loadColorPalette() {
    final savedPaletteName = _settingsBox.get(_colorPaletteKey);
    if (savedPaletteName != null) {
      state = AppColorPalette.palettes.firstWhere(
        (palette) => palette.name == savedPaletteName,
        orElse: () => AppColorPalette.palettes.first,
      );
    }
  }

  void setColorPalette(AppColorPalette palette) {
    state = palette;
    _settingsBox.put(_colorPaletteKey, palette.name);
  }
}
