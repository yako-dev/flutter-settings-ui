import 'package:flutter/cupertino.dart';
import 'package:settings_ui/src/v2/utils/platform_utils.dart';
import 'package:settings_ui/src/v2/utils/settings_theme.dart';

class ThemeProvider {
  static SettingsThemeData getTheme(BuildContext context) {
    final platform = PlatformUtils.detectPlatform(context);

    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
        return _iosTheme(context);
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        return _iosTheme(context);
      case DevicePlatform.web:
        return _iosTheme(context);
    }
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

    final lightSplashTileColor = Color.fromARGB(255, 209, 209, 214);
    final darkSplashTileColor = Color.fromARGB(255, 58, 58, 60);

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

    final splashTileColor =
        isLight ? lightSplashTileColor : darkSplashTileColor;

    return SettingsThemeData(
      splashTileColor: splashTileColor,
      settingsListBackground: listBackground,
      settingsSectionBackground: sectionBackground,
      titleTextColor: titleTextColor,
      dividerColor: dividerColor,
      trailingTextColor: trailingTextColor,
      settingsTileTextColor: settingsTileTextColor,
    );
  }
}
