import 'package:flutter/cupertino.dart';
import 'package:settings_ui/settings_ui.dart';

class CupertinoThemeProvider {
  static SettingsThemeData iosTheme({
    required BuildContext context,
    required Brightness brightness,
    required bool useSystemTheme,
  }) {
    return SettingsThemeData(
      tileHighlightColor: _tileHighlightColors[brightness],
      settingsListBackground:
          getBackgroundColor(context, useSystemTheme, brightness),
      settingsSectionBackground: _sectionBackgroundColors[brightness],
      titleTextColor: _titleColors[brightness],
      dividerColor: _dividerColors[brightness],
      trailingTextColor: _trailingTextColors[brightness],
      settingsTileTextColor: _tileTextColors[brightness],
      leadingIconsColor: _leadingIconsColors[brightness],
      inactiveTitleColor: CupertinoColors.inactiveGray,
      inactiveSubtitleColor: CupertinoColors.inactiveGray,
    );
  }

  static Color getBackgroundColor(
      BuildContext context, bool useSystemTheme, Brightness brightness) {
    if (useSystemTheme) {
      return CupertinoTheme.of(context).scaffoldBackgroundColor;
    } else {
      return backgroundColors[brightness] ??
          CupertinoTheme.of(context).scaffoldBackgroundColor;
    }
  }

  @visibleForTesting
  static final backgroundColors = {
    Brightness.light: const Color.fromRGBO(242, 242, 247, 1),
    Brightness.dark: CupertinoColors.black,
  };

  static final _sectionBackgroundColors = {
    Brightness.light: CupertinoColors.white,
    Brightness.dark: const Color.fromARGB(255, 28, 28, 30),
  };

  static final _titleColors = {
    Brightness.light: const Color.fromRGBO(109, 109, 114, 1),
    Brightness.dark: CupertinoColors.systemGrey,
  };

  static final _dividerColors = {
    Brightness.light: const Color.fromARGB(255, 238, 238, 238),
    Brightness.dark: const Color.fromARGB(255, 40, 40, 42),
  };

  static final _trailingTextColors = {
    Brightness.light: const Color.fromARGB(255, 138, 138, 142),
    Brightness.dark: const Color.fromARGB(255, 152, 152, 159),
  };

  static final _tileHighlightColors = {
    Brightness.light: const Color.fromARGB(255, 209, 209, 214),
    Brightness.dark: const Color.fromARGB(255, 58, 58, 60),
  };

  static final _tileTextColors = {
    Brightness.light: CupertinoColors.black,
    Brightness.dark: CupertinoColors.white,
  };

  static final _leadingIconsColors = {
    Brightness.light: CupertinoColors.inactiveGray,
    Brightness.dark: CupertinoColors.inactiveGray,
  };
}
