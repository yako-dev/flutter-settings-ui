import 'package:flutter/material.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';

class SettingsTheme extends InheritedWidget {
  final SettingsThemeData themeData;
  final DevicePlatform platform;

  const SettingsTheme({
    Key? key,
    required this.themeData,
    required this.platform,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(SettingsTheme oldWidget) => true;

  static SettingsTheme of(BuildContext context) {
    final SettingsTheme? result =
        context.dependOnInheritedWidgetOfExactType<SettingsTheme>();
    return result!;
  }
}

class SettingsThemeData {
  const SettingsThemeData({
    // List attributes
    this.settingsListBackground,

    // Section attributes
    this.settingsSectionBackground,
    this.sectionTitleColor,

    // Tile attributes
    this.tileTrailingTextColor,
    this.tileSubtitleColor,
    this.tileDescriptionColor,
    this.tilesDividerColor,
    this.tileHighlightColor,
    this.titleTextColor,
    this.tileLeadingIconsColor,
    this.tileDescriptionTextColor,
    this.tileTitleTextColor,
    this.tileDisabledContentColor,
    this.inactiveSubtitleColor,
    this.borderRadius,
  });

  // List attributes
  final Color? settingsListBackground;

  // Section attributes
  final Color? settingsSectionBackground;
  final Color? sectionTitleColor;

  /// Tile attributes
  final Color? tileTrailingTextColor;

  // TODO: maybe separate the ios trailing icon color to another parameter?
  // Includes not only leading icons, but also iOS specific arrow trailing icon
  final Color? tileLeadingIconsColor;
  final Color? tilesDividerColor;
  final Color? tileDescriptionTextColor;
  final Color? tileHighlightColor;
  @Deprecated(
      'Broke down to sectionTitleColor, tileSubtitleColor and tileDescriptionColor')
  final Color? titleTextColor;
  final Color? tileSubtitleColor;
  final Color? tileDescriptionColor;
  final Color? tileTitleTextColor;
  final Color? tileDisabledContentColor;
  // TODO: check how it works
  // Only in android and web.
  final Color? inactiveSubtitleColor;
  // TODO: implement
  final int? borderRadius;

  SettingsThemeData merge({
    SettingsThemeData? userDefinedSettingsTheme,
    required bool useSystemTheme,
  }) {
    if (userDefinedSettingsTheme == null) return this;

    return copyWith(
      tileLeadingIconsColor: userDefinedSettingsTheme.tileLeadingIconsColor,
      tileDescriptionTextColor:
          userDefinedSettingsTheme.tileDescriptionTextColor,
      tilesDividerColor: userDefinedSettingsTheme.tilesDividerColor,
      tileTrailingTextColor: userDefinedSettingsTheme.tileTrailingTextColor,
      settingsListBackground: useSystemTheme
          ? settingsListBackground
          : userDefinedSettingsTheme.settingsListBackground,
      settingsSectionBackground:
          userDefinedSettingsTheme.settingsSectionBackground,
      tileTitleTextColor: userDefinedSettingsTheme.tileTitleTextColor,
      tileHighlightColor: userDefinedSettingsTheme.tileHighlightColor,
      titleTextColor: userDefinedSettingsTheme.titleTextColor,
      tileDisabledContentColor:
          userDefinedSettingsTheme.tileDisabledContentColor,
      inactiveSubtitleColor: userDefinedSettingsTheme.inactiveSubtitleColor,
      borderRadius: userDefinedSettingsTheme.borderRadius,
      sectionTitleColor: userDefinedSettingsTheme.sectionTitleColor,
    );
  }

  SettingsThemeData copyWith({
    Color? settingsListBackground,
    Color? tileTrailingTextColor,
    Color? tileLeadingIconsColor,
    Color? settingsSectionBackground,
    Color? tilesDividerColor,
    Color? tileDescriptionTextColor,
    Color? tileHighlightColor,
    Color? titleTextColor,
    Color? tileTitleTextColor,
    Color? tileDisabledContentColor,
    Color? inactiveSubtitleColor,
    int? borderRadius,
    Color? sectionTitleColor,
  }) {
    return SettingsThemeData(
      settingsListBackground:
          settingsListBackground ?? this.settingsListBackground,
      tileTrailingTextColor:
          tileTrailingTextColor ?? this.tileTrailingTextColor,
      tileLeadingIconsColor:
          tileLeadingIconsColor ?? this.tileLeadingIconsColor,
      settingsSectionBackground:
          settingsSectionBackground ?? this.settingsSectionBackground,
      tilesDividerColor: tilesDividerColor ?? this.tilesDividerColor,
      tileDescriptionTextColor:
          tileDescriptionTextColor ?? this.tileDescriptionTextColor,
      tileHighlightColor: tileHighlightColor ?? this.tileHighlightColor,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      tileDisabledContentColor:
          tileDisabledContentColor ?? this.tileDisabledContentColor,
      inactiveSubtitleColor:
          inactiveSubtitleColor ?? this.inactiveSubtitleColor,
      tileTitleTextColor: tileTitleTextColor ?? this.tileTitleTextColor,
      borderRadius: borderRadius ?? this.borderRadius,
      sectionTitleColor: sectionTitleColor ?? this.sectionTitleColor,
    );
  }
}
