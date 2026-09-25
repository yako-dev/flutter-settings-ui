import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';

class SettingsTheme extends InheritedWidget {
  final SettingsThemeData themeData;
  final DevicePlatform platform;

  const SettingsTheme({
    super.key,
    required this.themeData,
    required this.platform,
    required super.child,
  });

  @override
  bool updateShouldNotify(SettingsTheme oldWidget) => true;

  static SettingsTheme of(BuildContext context) {
    final SettingsTheme? result = context
        .dependOnInheritedWidgetOfExactType<SettingsTheme>();
    return result!;
  }
}

class SettingsThemeData {
  const SettingsThemeData({
    this.trailingTextColor,
    this.settingsListBackground,
    this.settingsSectionBackground,
    this.dividerColor,
    this.tileHighlightColor,
    this.titleTextColor,
    this.leadingIconsColor,
    this.tileDescriptionTextColor,
    this.settingsTileTextColor,
    this.inactiveTitleColor,
    this.inactiveSubtitleColor,
    this.inactiveSwitchColor,
    this.titleTextStyle,
    this.tileTextStyle,
    this.tileDescriptionTextStyle,
    this.selectedTileColor,
    this.selectedTileTextColor,
    this.selectedTileIconColor,
    this.listPaneBackground,
  });

  final Color? settingsListBackground;
  final Color? trailingTextColor;
  final Color? leadingIconsColor;
  final Color? settingsSectionBackground;
  final Color? dividerColor;
  final Color? tileDescriptionTextColor;
  final Color? tileHighlightColor;
  final Color? titleTextColor;
  final Color? settingsTileTextColor;
  final Color? inactiveTitleColor;
  final Color? inactiveSubtitleColor;

  /// Color applied to the switch thumb/track when the tile is disabled.
  /// Overrides the default [inactiveTitleColor] used for the switch.
  final Color? inactiveSwitchColor;

  /// Override the text style for section titles. When set, [titleTextColor]
  /// is still applied if [titleTextStyle] does not specify a color.
  final TextStyle? titleTextStyle;

  /// Override the text style for tile titles.
  final TextStyle? tileTextStyle;

  /// Override the text style for tile descriptions/values.
  final TextStyle? tileDescriptionTextStyle;

  /// Fill of the selected tile in the list pane of a [SettingsSplitView]:
  /// the tile whose page shows in the detail pane.
  final Color? selectedTileColor;

  /// Title and value color of the selected tile in a [SettingsSplitView].
  final Color? selectedTileTextColor;

  /// Leading icon and chevron color of the selected tile in a
  /// [SettingsSplitView].
  final Color? selectedTileIconColor;

  /// Background of a [SettingsSplitView]'s list pane when it shows two panes:
  /// the tinted iPad sidebar, the surface-dim Android homepage. Defaults to
  /// [settingsListBackground] on the web.
  final Color? listPaneBackground;

  SettingsThemeData merge({SettingsThemeData? theme}) {
    if (theme == null) return this;

    return copyWith(
      leadingIconsColor: theme.leadingIconsColor,
      tileDescriptionTextColor: theme.tileDescriptionTextColor,
      dividerColor: theme.dividerColor,
      trailingTextColor: theme.trailingTextColor,
      settingsListBackground: theme.settingsListBackground,
      settingsSectionBackground: theme.settingsSectionBackground,
      settingsTileTextColor: theme.settingsTileTextColor,
      tileHighlightColor: theme.tileHighlightColor,
      titleTextColor: theme.titleTextColor,
      inactiveTitleColor: theme.inactiveTitleColor,
      inactiveSubtitleColor: theme.inactiveSubtitleColor,
      inactiveSwitchColor: theme.inactiveSwitchColor,
      titleTextStyle: theme.titleTextStyle,
      tileTextStyle: theme.tileTextStyle,
      tileDescriptionTextStyle: theme.tileDescriptionTextStyle,
      selectedTileColor: theme.selectedTileColor,
      selectedTileTextColor: theme.selectedTileTextColor,
      selectedTileIconColor: theme.selectedTileIconColor,
      listPaneBackground: theme.listPaneBackground,
    );
  }

  SettingsThemeData copyWith({
    Color? settingsListBackground,
    Color? trailingTextColor,
    Color? leadingIconsColor,
    Color? settingsSectionBackground,
    Color? dividerColor,
    Color? tileDescriptionTextColor,
    Color? tileHighlightColor,
    Color? titleTextColor,
    Color? settingsTileTextColor,
    Color? inactiveTitleColor,
    Color? inactiveSubtitleColor,
    Color? inactiveSwitchColor,
    TextStyle? titleTextStyle,
    TextStyle? tileTextStyle,
    TextStyle? tileDescriptionTextStyle,
    Color? selectedTileColor,
    Color? selectedTileTextColor,
    Color? selectedTileIconColor,
    Color? listPaneBackground,
  }) {
    return SettingsThemeData(
      settingsListBackground:
          settingsListBackground ?? this.settingsListBackground,
      trailingTextColor: trailingTextColor ?? this.trailingTextColor,
      leadingIconsColor: leadingIconsColor ?? this.leadingIconsColor,
      settingsSectionBackground:
          settingsSectionBackground ?? this.settingsSectionBackground,
      dividerColor: dividerColor ?? this.dividerColor,
      tileDescriptionTextColor:
          tileDescriptionTextColor ?? this.tileDescriptionTextColor,
      tileHighlightColor: tileHighlightColor ?? this.tileHighlightColor,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      inactiveTitleColor: inactiveTitleColor ?? this.inactiveTitleColor,
      inactiveSubtitleColor:
          inactiveSubtitleColor ?? this.inactiveSubtitleColor,
      settingsTileTextColor:
          settingsTileTextColor ?? this.settingsTileTextColor,
      inactiveSwitchColor: inactiveSwitchColor ?? this.inactiveSwitchColor,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      tileTextStyle: tileTextStyle ?? this.tileTextStyle,
      tileDescriptionTextStyle:
          tileDescriptionTextStyle ?? this.tileDescriptionTextStyle,
      selectedTileColor: selectedTileColor ?? this.selectedTileColor,
      selectedTileTextColor:
          selectedTileTextColor ?? this.selectedTileTextColor,
      selectedTileIconColor:
          selectedTileIconColor ?? this.selectedTileIconColor,
      listPaneBackground: listPaneBackground ?? this.listPaneBackground,
    );
  }
}
