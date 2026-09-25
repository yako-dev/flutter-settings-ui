import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';

/// The resolved colors and style of the `SettingsList` above.
///
/// `SettingsList` puts it above its sections; a `CustomSettingsTile` or
/// `CustomSettingsSection` can read it with [SettingsTheme.of].
class SettingsTheme extends InheritedWidget {
  /// The colors and text styles: the style's defaults merged with the list's
  /// `lightTheme` or `darkTheme`.
  final SettingsThemeData themeData;

  /// The resolved style, never [DevicePlatform.device].
  final DevicePlatform platform;

  /// Used by `SettingsList`; apps don't need to create one.
  const SettingsTheme({
    super.key,
    required this.themeData,
    required this.platform,
    required super.child,
  });

  @override
  bool updateShouldNotify(SettingsTheme oldWidget) => true;

  /// The nearest [SettingsTheme]. Call it only below a `SettingsList`: it
  /// throws when there is none.
  static SettingsTheme of(BuildContext context) {
    final SettingsTheme? result = context
        .dependOnInheritedWidgetOfExactType<SettingsTheme>();
    return result!;
  }
}

/// Colors and text styles of a `SettingsList`.
///
/// Pass it as the list's `lightTheme` or `darkTheme`. Fields left null keep
/// the style's defaults.
class SettingsThemeData {
  /// Creates a theme; every field is optional.
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

  /// Background of the whole list.
  final Color? settingsListBackground;

  /// Color of a tile's `value` in the iOS, macOS, Windows and GNOME styles.
  final Color? trailingTextColor;

  /// Leading and trailing icons, and the chevron.
  final Color? leadingIconsColor;

  /// Background of the cards.
  final Color? settingsSectionBackground;

  /// Line between tiles (iOS, macOS, GNOME and web styles), card border
  /// (Windows style).
  final Color? dividerColor;

  /// `description` and `value` text color in the Android and web styles;
  /// `description` and `titleDescription` in the macOS, Windows and GNOME
  /// styles.
  final Color? tileDescriptionTextColor;

  /// Pressed tile. The GNOME style also hovers with 3/8 of its opacity.
  final Color? tileHighlightColor;

  /// Section header text color. In the iOS style also `titleDescription` and
  /// `description`.
  final Color? titleTextColor;

  /// Tile title text color.
  final Color? settingsTileTextColor;

  /// Title and icon color of a disabled tile.
  final Color? inactiveTitleColor;

  /// `description` and `value` color of a disabled tile (Android, Windows,
  /// GNOME and web styles), and its `titleDescription` in the macOS style.
  final Color? inactiveSubtitleColor;

  /// Color applied to the switch thumb/track when the tile is disabled.
  /// Overrides the default [inactiveTitleColor] used for the switch.
  /// Without it, the macOS style draws a paler accent, like System Settings.
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

  /// This theme with the non-null fields of [theme] on top.
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

  /// A copy of this theme with the given fields replaced.
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
