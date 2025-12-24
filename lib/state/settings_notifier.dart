import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final ThemeMode themeMode;
  final double textScale;
  final String? fontFamily;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.textScale = 1.0,
    this.fontFamily,
  });

  AppSettings copyWith({ThemeMode? themeMode, double? textScale, String? fontFamily}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void toggleTheme(bool isDark) {
    state = state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void setTextScale(double scale) {
    state = state.copyWith(textScale: scale);
  }

  void setFontFamily(String? font) {
    state = state.copyWith(fontFamily: font);
  }
  
  void signOut() {}
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});