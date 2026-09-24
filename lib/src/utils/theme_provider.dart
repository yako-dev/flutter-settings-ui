import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

class ThemeProvider {
  static SettingsThemeData getTheme({
    required BuildContext context,
    required DevicePlatform platform,
    required Brightness brightness,
  }) {
    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
        return _androidTheme(context: context, brightness: brightness);
      case DevicePlatform.linux:
        return _adwaitaTheme(brightness: brightness);
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
    );
  }

  /// GNOME (libadwaita 1.10) colors, like GNOME Settings 51. As in the
  /// libadwaita stylesheet, most colors are the foreground color at some
  /// strength: `rgba(0, 0, 6, 0.8)` in light mode and white in dark mode.
  /// Like the iOS style, this ignores the [ColorScheme].
  static SettingsThemeData _adwaitaTheme({required Brightness brightness}) {
    final isLight = brightness == Brightness.light;
    final foreground = isLight
        ? const Color.fromRGBO(0, 0, 6, 0.8)
        : const Color(0xFFFFFFFF);
    Color dim(double opacity) =>
        foreground.withValues(alpha: foreground.a * opacity);

    return SettingsThemeData(
      // --window-bg-color
      settingsListBackground: isLight
          ? const Color(0xFFFAFAFB)
          : const Color(0xFF222226),
      // --card-bg-color
      settingsSectionBackground: isLight
          ? const Color(0xFFFFFFFF)
          : const Color.fromRGBO(255, 255, 255, 0.08),
      // --card-shade-color, between rows
      dividerColor: isLight
          ? const Color.fromRGBO(0, 0, 6, 0.07)
          : const Color.fromRGBO(0, 0, 6, 0.36),
      titleTextColor: foreground,
      settingsTileTextColor: foreground,
      leadingIconsColor: foreground,
      // .dim-label (opacity 0.55) for subtitles and values
      tileDescriptionTextColor: dim(0.55),
      trailingTextColor: dim(0.55),
      // Pressed rows; hovered rows use 3/8 of it (3%).
      tileHighlightColor: dim(0.08),
      // Disabled rows are drawn at opacity 0.5.
      inactiveTitleColor: dim(0.5),
      inactiveSubtitleColor: dim(0.55 * 0.5),
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
    );
  }
}
