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
    this.settingsListBackground,
    this.settingsSectionBarckground,
    this.titleTextColor,
    this.settingsTileTextColor,
  });

  final Color? settingsListBackground;
  final Color? settingsSectionBarckground;
  final Color? titleTextColor;
  final Color? settingsTileTextColor;
}
