import 'package:flutter/cupertino.dart';
import 'package:settings_ui/settings_ui.dart';

class CupertinoThemeProvider {
  static SettingsThemeData iosTheme({
    required BuildContext context,
    required Brightness brightness,
    required bool useSystemTheme,
  }) {
    return SettingsThemeData(
      settingsListBackground: _getSettingsListBackgroundColor(
        context,
        brightness,
        useSystemTheme: useSystemTheme,
      ),
      tileHighlightColor: _tileHighlightColors[brightness],
      settingsSectionBackground: sectionBackgroundColors[brightness],
      titleTextColor: _titleColors[brightness],
      tilesDividerColor: _tilesDividerColors[brightness],
      tileTrailingTextColor: _tileTrailingTextColors[brightness],
      tileTitleTextColor: _tileTextColors[brightness],
      tileLeadingIconsColor: _leadingIconsColors[brightness],
      tileDisabledContentColor: CupertinoColors.inactiveGray,
      inactiveSubtitleColor: CupertinoColors.inactiveGray,
      sectionTitleColor: _titleColors[brightness],
    );
  }

  static Color _getSettingsListBackgroundColor(
    BuildContext context,
    Brightness brightness, {
    required bool useSystemTheme,
  }) {
    final scaffoldBackgroundColor =
        CupertinoTheme.of(context).scaffoldBackgroundColor;
    if (useSystemTheme) {
      return scaffoldBackgroundColor;
    } else {
      return backgroundColors[brightness] ?? scaffoldBackgroundColor;
    }
  }

  @visibleForTesting
  static final backgroundColors = {
    Brightness.light: const Color.fromRGBO(242, 242, 247, 1),
    Brightness.dark: CupertinoColors.black,
  };

  @visibleForTesting
  static final sectionBackgroundColors = {
    Brightness.light: CupertinoColors.secondarySystemGroupedBackground.color,
    Brightness.dark: CupertinoColors.secondarySystemGroupedBackground.darkColor,
  };

  static final _titleColors = {
    Brightness.light: const Color.fromRGBO(109, 109, 114, 1),
    Brightness.dark: CupertinoColors.systemGrey,
  };

  static final _tilesDividerColors = {
    Brightness.light: const Color.fromARGB(255, 238, 238, 238),
    Brightness.dark: const Color.fromARGB(255, 40, 40, 42),
  };

  static final _tileTrailingTextColors = {
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
