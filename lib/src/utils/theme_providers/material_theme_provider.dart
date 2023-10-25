import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class MaterialThemeProvider {
  static SettingsThemeData androidTheme({
    required BuildContext context,
    required Brightness brightness,
    required bool useSystemTheme,
  }) {
    return SettingsThemeData(
      settingsListBackground: _getBackgroundColor(
        context,
        brightness,
        useSystemTheme: useSystemTheme,
      ),
      tileHighlightColor: _tileHighlightColors[brightness],
      titleTextColor: _titleTextColors[brightness],
      tileTitleTextColor: _tileTextColors[brightness],
      tileDescriptionTextColor: _tileDescriptionTextColors[brightness],
      tileLeadingIconsColor: _leadingIconsColors[brightness],
      tileDisabledContentColor: _inactiveTitleColors[brightness],
      inactiveSubtitleColor: _inactiveSubtitleColors[brightness],
    );
  }
}

Color _getBackgroundColor(
  BuildContext context,
  Brightness brightness, {
  required bool useSystemTheme,
}) {
  final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
  if (useSystemTheme) {
    return scaffoldBackgroundColor;
  } else {
    return _backgroundColors[brightness] ?? scaffoldBackgroundColor;
  }
}

const _backgroundColors = {
  Brightness.light: Color.fromRGBO(240, 240, 240, 1),
  Brightness.dark: Color.fromRGBO(27, 27, 27, 1),
};

const _leadingIconsColors = {
  Brightness.light: Color.fromARGB(255, 70, 70, 70),
  Brightness.dark: Color.fromARGB(255, 197, 197, 197),
};

const _titleTextColors = {
  Brightness.light: Color.fromRGBO(11, 87, 208, 1),
  Brightness.dark: Color.fromRGBO(211, 227, 253, 1),
};

const _tileHighlightColors = {
  Brightness.light: Color.fromARGB(255, 220, 220, 220),
  Brightness.dark: Color.fromARGB(255, 46, 46, 46),
};

const _tileTextColors = {
  Brightness.light: Color.fromARGB(255, 27, 27, 27),
  Brightness.dark: Color.fromARGB(255, 240, 240, 240),
};

const _inactiveTitleColors = {
  Brightness.light: Color.fromARGB(255, 146, 144, 148),
  Brightness.dark: Color.fromARGB(255, 118, 117, 122),
};

const _inactiveSubtitleColors = {
  Brightness.light: Color.fromARGB(255, 197, 196, 201),
  Brightness.dark: Color.fromARGB(255, 71, 70, 74),
};

const _tileDescriptionTextColors = {
  Brightness.light: Color.fromARGB(255, 70, 70, 70),
  Brightness.dark: Color.fromARGB(255, 198, 198, 198),
};
