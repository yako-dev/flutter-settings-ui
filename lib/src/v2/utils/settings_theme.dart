import 'package:flutter/material.dart';

class SettingsTheme extends InheritedWidget {
  final SettingsThemeData themeData;

  SettingsTheme({
    required this.themeData,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(SettingsTheme old) => true;

  static SettingsTheme of(BuildContext context) {
    final SettingsTheme? result =
        context.dependOnInheritedWidgetOfExactType<SettingsTheme>();
    assert(result != null, 'No SettingsTheme found in context');
    return result!;
  }
}

class SettingsThemeData {
  const SettingsThemeData({
    this.trailingTextColor,
    this.settingsListBackground,
    this.settingsSectionBackground,
    this.dividerColor,
    this.splashTileColor,
    this.titleTextColor,
    this.settingsTileTextColor,
  });

  final Color? settingsListBackground;
  final Color? trailingTextColor;
  final Color? settingsSectionBackground;
  final Color? dividerColor;
  final Color? splashTileColor;
  final Color? titleTextColor;
  final Color? settingsTileTextColor;
}
