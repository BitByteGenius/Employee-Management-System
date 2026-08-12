import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Manages the application's theme, allowing users to switch between light, dark,
/// and system default themes. It persists the user's choice using GetStorage.
class ThemeController extends GetxController {
  static const _themeModeKey = 'theme_mode';
  final _box = GetStorage();

  /// Reactive variable holding the current theme mode.
  /// Widgets listening to this will automatically update on change.
  final themeMode = ThemeMode.system.obs;

  /// Returns `true` if the current theme is dark.
  bool get isDarkMode => Get.isDarkMode;
  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  /// Loads the saved theme from local storage and applies it.
  /// Defaults to [ThemeMode.system] if no theme is saved.
  void _loadTheme() {
    final savedTheme = _box.read<String>(_themeModeKey);
    switch (savedTheme) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;
      default:
        themeMode.value = ThemeMode.system;
        break;
    }
    Get.changeThemeMode(themeMode.value);
  }

  /// Changes the application's theme and persists the new selection.
  void changeTheme(ThemeMode newThemeMode) {
    Get.changeThemeMode(newThemeMode);
    themeMode.value = newThemeMode;
    _box.write(_themeModeKey, newThemeMode.name);
  }
}
