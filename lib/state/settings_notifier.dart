import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeStr = prefs.getString('theme_mode') ?? 'system';
      final textScale = prefs.getDouble('text_scale') ?? 1.0;
      final fontFamily = prefs.getString('font_family');

      ThemeMode themeMode;
      switch (themeStr) {
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        case 'light':
          themeMode = ThemeMode.light;
          break;
        default:
          themeMode = ThemeMode.system;
      }

      state = state.copyWith(
        themeMode: themeMode,
        textScale: textScale,
        fontFamily: fontFamily,
      );
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  void toggleTheme(bool isDark) {
    state = state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
    _saveSettings();
  }

  void setTextScale(double scale) {
    state = state.copyWith(textScale: scale);
    _saveSettings();
  }

  void setFontFamily(String? family) {
    state = state.copyWith(fontFamily: family);
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', state.themeMode == ThemeMode.dark ? 'dark' : 'light');
      await prefs.setDouble('text_scale', state.textScale);
      if (state.fontFamily != null) {
        await prefs.setString('font_family', state.fontFamily!);
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }
  
  void signOut() {}
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});