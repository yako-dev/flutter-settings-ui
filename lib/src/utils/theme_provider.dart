import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

// iPadOS 27 Settings, measured in the simulator: the sidebar's tint and the
// filled capsule of the selected row.
const _iPadSidebarBackgroundLight = Color(0xFFE2E6F0);
const _iPadSidebarBackgroundDark = Color(0xFF181D20);
const _iPadSelectedTileColorLight = Color(0xFF0080F5);
const _iPadSelectedTileColorDark = Color(0xFF13A4FF);

class ThemeProvider {
  static SettingsThemeData getTheme({
    required BuildContext context,
    required DevicePlatform platform,
    required Brightness brightness,
  }) {
    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
        return _androidTheme(context: context, brightness: brightness);
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        return _iosTheme(context: context, brightness: brightness);
      case DevicePlatform.web:
        return _webTheme(context: context, brightness: brightness);
      case DevicePlatform.device:
        throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: ThemeProvider.getTheme',
        );
    }
  }

  /// Derives Material 3 colors from the active [ColorScheme], like Android
  /// 16+ settings: a tinted page with lighter cards for the tiles.
  static SettingsThemeData _androidTheme({
    required BuildContext context,
    required Brightness brightness,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = brightness == Brightness.light;

    final listBackground = colorScheme.surfaceContainer;
    final sectionBackground = isLight
        ? colorScheme.surfaceBright
        : colorScheme.surfaceContainerHighest;

    final titleTextColor = colorScheme.primary;

    final settingsTileTextColor = colorScheme.onSurface;

    final tileDescriptionTextColor = colorScheme.onSurfaceVariant;

    final leadingIconsColor = colorScheme.onSurfaceVariant;

    final tileHighlightColor = colorScheme.secondaryContainer;

    final inactiveTitleColor = colorScheme.onSurface.withValues(alpha: 0.38);

    final inactiveSubtitleColor = colorScheme.onSurface.withValues(alpha: 0.22);

    return SettingsThemeData(
      tileHighlightColor: tileHighlightColor,
      settingsListBackground: listBackground,
      settingsSectionBackground: sectionBackground,
      titleTextColor: titleTextColor,
      settingsTileTextColor: settingsTileTextColor,
      tileDescriptionTextColor: tileDescriptionTextColor,
      leadingIconsColor: leadingIconsColor,
      inactiveTitleColor: inactiveTitleColor,
      inactiveSubtitleColor: inactiveSubtitleColor,
      // AOSP two-pane Settings: the homepage cards sit on surface dim, and
      // the selected card takes the detail pane's color (the page
      // background), so it looks joined to the page next to it.
      listPaneBackground: colorScheme.surfaceDim,
      selectedTileColor: listBackground,
      selectedTileTextColor: settingsTileTextColor,
      selectedTileIconColor: leadingIconsColor,
    );
  }

  /// Uses Cupertino system colors for iOS/macOS/Windows — these are not
  /// derived from [ColorScheme] because Cupertino doesn't use Material theming.
  static SettingsThemeData _iosTheme({
    required BuildContext context,
    required Brightness brightness,
  }) {
    const lightSettingsListBackground = Color.fromRGBO(242, 242, 247, 1);
    const darkSettingsListBackground = CupertinoColors.black;

    const lightSettingSectionColor = CupertinoColors.white;
    const darkSettingSectionColor = Color.fromARGB(255, 28, 28, 30);

    const lightSettingsTitleColor = Color.fromRGBO(60, 60, 67, 0.6);
    const darkSettingsTitleColor = CupertinoColors.systemGrey;

    const lightDividerColor = Color.fromARGB(255, 238, 238, 238);
    const darkDividerColor = Color.fromARGB(255, 40, 40, 42);

    const lightTrailingTextColor = Color.fromARGB(255, 138, 138, 142);
    const darkTrailingTextColor = Color.fromARGB(255, 152, 152, 159);

    const lightTileHighlightColor = Color.fromARGB(255, 209, 209, 214);
    const darkTileHighlightColor = Color.fromARGB(255, 58, 58, 60);

    const lightSettingsTileTextColor = CupertinoColors.black;
    const darkSettingsTileTextColor = CupertinoColors.white;

    const lightLeadingIconsColor = CupertinoColors.inactiveGray;
    const darkLeadingIconsColor = CupertinoColors.inactiveGray;

    final isLight = brightness == Brightness.light;

    return SettingsThemeData(
      tileHighlightColor: isLight
          ? lightTileHighlightColor
          : darkTileHighlightColor,
      settingsListBackground: isLight
          ? lightSettingsListBackground
          : darkSettingsListBackground,
      settingsSectionBackground: isLight
          ? lightSettingSectionColor
          : darkSettingSectionColor,
      titleTextColor: isLight
          ? lightSettingsTitleColor
          : darkSettingsTitleColor,
      dividerColor: isLight ? lightDividerColor : darkDividerColor,
      trailingTextColor: isLight
          ? lightTrailingTextColor
          : darkTrailingTextColor,
      settingsTileTextColor: isLight
          ? lightSettingsTileTextColor
          : darkSettingsTileTextColor,
      leadingIconsColor: isLight
          ? lightLeadingIconsColor
          : darkLeadingIconsColor,
      inactiveTitleColor: CupertinoColors.inactiveGray,
      inactiveSubtitleColor: CupertinoColors.inactiveGray,
      listPaneBackground: isLight
          ? _iPadSidebarBackgroundLight
          : _iPadSidebarBackgroundDark,
      selectedTileColor: isLight
          ? _iPadSelectedTileColorLight
          : _iPadSelectedTileColorDark,
      selectedTileTextColor: CupertinoColors.white,
      selectedTileIconColor: CupertinoColors.white,
    );
  }

  /// Web theme follows desktop Chrome settings: white page and cards (the
  /// card shadow separates them) and near-black section titles.
  static SettingsThemeData _webTheme({
    required BuildContext context,
    required Brightness brightness,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = brightness == Brightness.light;

    final listBackground = isLight
        ? colorScheme.surfaceContainerLowest
        : colorScheme.surface;
    final sectionBackground = isLight
        ? colorScheme.surfaceContainerLowest
        : colorScheme.surfaceContainerLow;
    final titleTextColor = colorScheme.onSurface;
    final settingsTileTextColor = colorScheme.onSurface;
    final tileDescriptionTextColor = colorScheme.onSurfaceVariant;
    final leadingIconsColor = colorScheme.onSurfaceVariant;
    final tileHighlightColor = colorScheme.secondaryContainer;
    final inactiveTitleColor = colorScheme.onSurface.withValues(alpha: 0.38);
    final inactiveSubtitleColor = colorScheme.onSurface.withValues(alpha: 0.22);

    return SettingsThemeData(
      tileHighlightColor: tileHighlightColor,
      settingsListBackground: listBackground,
      settingsSectionBackground: sectionBackground,
      titleTextColor: titleTextColor,
      settingsTileTextColor: settingsTileTextColor,
      tileDescriptionTextColor: tileDescriptionTextColor,
      leadingIconsColor: leadingIconsColor,
      inactiveTitleColor: inactiveTitleColor,
      inactiveSubtitleColor: inactiveSubtitleColor,
      // Chrome's settings menu: a light tint of the accent with accent text
      // (#E8F0FE / #1967D2), and the light accent with dark text in dark
      // mode (#8AB4F8 / #202124).
      selectedTileColor: isLight
          ? Color.alphaBlend(
              colorScheme.primary.withValues(alpha: 0.1),
              listBackground,
            )
          : colorScheme.primary,
      selectedTileTextColor: isLight
          ? colorScheme.primary
          : colorScheme.onPrimary,
      selectedTileIconColor: isLight
          ? colorScheme.primary
          : colorScheme.onPrimary,
    );
  }
}
