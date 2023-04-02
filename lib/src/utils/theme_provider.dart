import 'package:flutter/cupertino.dart';
import 'package:settings_ui/src/utils/cupertino_theme_provider.dart';
import 'package:settings_ui/src/utils/material_theme_provider.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

class ThemeProvider {
  static SettingsThemeData getTheme({
    required BuildContext context,
    required DevicePlatform platform,
    required Brightness brightness,
    required bool useSystemTheme,
  }) {
    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
        return MaterialThemeProvider.androidTheme(
            context: context,
            brightness: brightness,
            useSystemTheme: useSystemTheme);
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        return CupertinoThemeProvider.iosTheme(
          context: context,
          brightness: brightness,
          useSystemTheme: useSystemTheme,
        );
      case DevicePlatform.web:
        return _webTheme(
            context: context,
            brightness: brightness,
            useSystemTheme: useSystemTheme);
      case DevicePlatform.device:
        throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: ThemeProvider.getTheme',
        );
    }
  }

  static SettingsThemeData _webTheme({
    required BuildContext context,
    required Brightness brightness,
    required bool useSystemTheme,
  }) {
    const lightLeadingIconsColor = Color.fromARGB(255, 70, 70, 70);
    const darkLeadingIconsColor = Color.fromARGB(255, 197, 197, 197);

    const lightSettingsListBackground = Color.fromRGBO(240, 240, 240, 1);
    //done
    const darkSettingsListBackground = Color.fromRGBO(32, 33, 36, 1);

    const lightSettingSectionColor = CupertinoColors.white;
    //done
    const darkSettingSectionColor = Color(0xFF292a2d);

    const lightSettingsTitleColor = Color.fromRGBO(11, 87, 208, 1);
    //done
    const darkSettingsTitleColor = Color.fromRGBO(232, 234, 237, 1);

    const lightTileHighlightColor = Color.fromARGB(255, 220, 220, 220);
    const darkTileHighlightColor = Color.fromARGB(255, 46, 46, 46);

    const lightSettingsTileTextColor = Color.fromARGB(255, 27, 27, 27);
    const darkSettingsTileTextColor = Color.fromARGB(232, 234, 237, 240);

    const lightTileDescriptionTextColor = Color.fromARGB(255, 70, 70, 70);
    const darkTileDescriptionTextColor = Color.fromARGB(154, 160, 166, 198);

    const lightInactiveTitleColor = Color.fromARGB(255, 146, 144, 148);
    const darkInactiveTitleColor = Color.fromARGB(255, 118, 117, 122);

    const lightInactiveSubtitleColor = Color.fromARGB(255, 197, 196, 201);
    const darkInactiveSubtitleColor = Color.fromARGB(255, 71, 70, 74);

    final isLight = brightness == Brightness.light;

    final listBackground =
        isLight ? lightSettingsListBackground : darkSettingsListBackground;

    final titleTextColor =
        isLight ? lightSettingsTitleColor : darkSettingsTitleColor;

    final settingsTileTextColor =
        isLight ? lightSettingsTileTextColor : darkSettingsTileTextColor;

    final tileHighlightColor =
        isLight ? lightTileHighlightColor : darkTileHighlightColor;

    final tileDescriptionTextColor =
        isLight ? lightTileDescriptionTextColor : darkTileDescriptionTextColor;

    final leadingIconsColor =
        isLight ? lightLeadingIconsColor : darkLeadingIconsColor;

    final sectionBackground =
        isLight ? lightSettingSectionColor : darkSettingSectionColor;

    final inactiveTitleColor =
        isLight ? lightInactiveTitleColor : darkInactiveTitleColor;

    final inactiveSubtitleColor =
        isLight ? lightInactiveSubtitleColor : darkInactiveSubtitleColor;

    return SettingsThemeData(
      tileHighlightColor: tileHighlightColor,
      settingsListBackground: listBackground,
      titleTextColor: titleTextColor,
      settingsSectionBackground: sectionBackground,
      tileTitleTextColor: settingsTileTextColor,
      tileDescriptionTextColor: tileDescriptionTextColor,
      tileLeadingIconsColor: leadingIconsColor,
      tileDisabledContentColor: inactiveTitleColor,
      inactiveSubtitleColor: inactiveSubtitleColor,
    );
  }
}
