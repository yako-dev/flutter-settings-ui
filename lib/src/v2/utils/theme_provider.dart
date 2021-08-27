import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/src/v2/utils/platform_utils.dart';
import 'package:settings_ui/src/v2/utils/settings_theme.dart';

class ThemeProvider {
  static SettingsThemeData getTheme(BuildContext context) {
    final platform = PlatformUtils.detectPlatform(context);

    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
        return _androidTheme(context);
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        return _iosTheme(context);
      case DevicePlatform.web:
        return _iosTheme(context);
    }
  }

  static SettingsThemeData _androidTheme(BuildContext context) {
    //done
    final lightSettingsListBackground = Color.fromRGBO(240, 240, 240, 1);
    //done
    final darkSettingsListBackground = Color.fromRGBO(27, 27, 27, 1);

    //done
    final lightSettingSectionColor = Colors.transparent;
    //done
    final darkSettingSectionColor = Colors.transparent;

    //done
    final lightSettingsTitleColor = Color.fromRGBO(11, 87, 208, 1);
    //done
    final darkSettingsTitleColor = Color.fromRGBO(211, 227, 253, 1);

    //done
    final lightDividerColor = Colors.transparent;
    //done
    final darkDividerColor = Colors.transparent;

    //dont use
    final lightTrailingTextColor = Colors.transparent;
    //dont use
    final darkTrailingTextColor = Colors.transparent;

    //done
    final lightTileHighlightColor = Color.fromARGB(255, 220, 220, 220);
    // done
    final darkTileHighlightColor = Color.fromARGB(255, 46, 46, 46);

    //done
    final lightSettingsTileTextColor = Color.fromARGB(255, 27, 27, 27);
    //done
    final darkSettingsTileTextColor = Color.fromARGB(255, 240, 240, 240);

    final lightTileDescriptionTextColor = Color.fromARGB(255, 70, 70, 70);
    final darkTileDescriptionTextColor = Color.fromARGB(255, 198, 198, 198);

    final isLight =
        MediaQuery.of(context).platformBrightness == Brightness.light;

    final listBackground =
        isLight ? lightSettingsListBackground : darkSettingsListBackground;

    final sectionBackground =
        isLight ? lightSettingSectionColor : darkSettingSectionColor;

    final titleTextColor =
        isLight ? lightSettingsTitleColor : darkSettingsTitleColor;

    final settingsTileTextColor =
        isLight ? lightSettingsTileTextColor : darkSettingsTileTextColor;

    final dividerColor = isLight ? lightDividerColor : darkDividerColor;

    final trailingTextColor =
        isLight ? lightTrailingTextColor : darkTrailingTextColor;

    final tileHighlightColor =
        isLight ? lightTileHighlightColor : darkTileHighlightColor;

    final tileDescriptionTextColor =
        isLight ? lightTileDescriptionTextColor : darkTileDescriptionTextColor;

    return SettingsThemeData(
      tileHighlightColor: tileHighlightColor,
      settingsListBackground: listBackground,
      settingsSectionBackground: sectionBackground,
      titleTextColor: titleTextColor,
      dividerColor: dividerColor,
      trailingTextColor: trailingTextColor,
      settingsTileTextColor: settingsTileTextColor,
      tileDescriptionTextColor: tileDescriptionTextColor,
    );
  }

  static SettingsThemeData _iosTheme(BuildContext context) {
    final lightSettingsListBackground = Color.fromRGBO(242, 242, 247, 1);
    final darkSettingsListBackground = CupertinoColors.black;

    final lightSettingSectionColor = CupertinoColors.white;
    final darkSettingSectionColor = Color.fromARGB(255, 28, 28, 30);

    final lightSettingsTitleColor = Color.fromRGBO(109, 109, 114, 1);
    final darkSettingsTitleColor = CupertinoColors.systemGrey;

    final lightDividerColor = Color.fromARGB(255, 238, 238, 238);
    final darkDividerColor = Color.fromARGB(255, 40, 40, 42);

    final lightTrailingTextColor = Color.fromARGB(255, 138, 138, 142);
    final darkTrailingTextColor = Color.fromARGB(255, 152, 152, 159);

    final lightTileHighlightColor = Color.fromARGB(255, 209, 209, 214);
    final darkTileHighlightColor = Color.fromARGB(255, 58, 58, 60);

    final lightSettingsTileTextColor = CupertinoColors.black;
    final darkSettingsTileTextColor = CupertinoColors.white;

    final isLight =
        MediaQuery.of(context).platformBrightness == Brightness.light;

    final listBackground =
        isLight ? lightSettingsListBackground : darkSettingsListBackground;

    final sectionBackground =
        isLight ? lightSettingSectionColor : darkSettingSectionColor;

    final titleTextColor =
        isLight ? lightSettingsTitleColor : darkSettingsTitleColor;

    final settingsTileTextColor =
        isLight ? lightSettingsTileTextColor : darkSettingsTileTextColor;

    final dividerColor = isLight ? lightDividerColor : darkDividerColor;

    final trailingTextColor =
        isLight ? lightTrailingTextColor : darkTrailingTextColor;

    final tileHighlightColor =
        isLight ? lightTileHighlightColor : darkTileHighlightColor;

    return SettingsThemeData(
      tileHighlightColor: tileHighlightColor,
      settingsListBackground: listBackground,
      settingsSectionBackground: sectionBackground,
      titleTextColor: titleTextColor,
      dividerColor: dividerColor,
      trailingTextColor: trailingTextColor,
      settingsTileTextColor: settingsTileTextColor,
    );
  }
}
