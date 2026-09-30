import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

abstract class ThemeProvider {
  static SettingsThemeData getTheme({
    required BuildContext context,
    required DevicePlatform platform,
    required Brightness brightness,
  }) => switch (platform) {
    DevicePlatform.android || DevicePlatform.linux => _androidTheme(
      context: context,
      brightness: brightness,
    ),
    DevicePlatform.iOS || DevicePlatform.macOS || DevicePlatform.windows =>
      _iosTheme(context: context, brightness: brightness),
    DevicePlatform.web => _webTheme(context: context, brightness: brightness),
    DevicePlatform.device => throw Exception(
      'You can\'t use the DevicePlatform.device in this context. '
      'Incorrect platform: ThemeProvider.getTheme',
    ),
  };

  /// Derives Material 3 colors from the active [ColorScheme].
  /// Falls back to hardcoded values when a color is not available in the
  /// scheme, ensuring backwards compatibility with Material 2 apps.
  static SettingsThemeData _androidTheme({
    required BuildContext context,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme.of(context);

    return SettingsThemeData(
      tileHighlightColor: colorScheme.secondaryContainer,
      settingsListBackground: colorScheme.surface,
      titleTextColor: colorScheme.primary,
      settingsTileTextColor: colorScheme.onSurface,
      tileDescriptionTextColor: colorScheme.onSurfaceVariant,
      leadingIconsColor: colorScheme.onSurfaceVariant,
      inactiveTitleColor: colorScheme.onSurface.withValues(alpha: 0.38),
      inactiveSubtitleColor: colorScheme.onSurface.withValues(alpha: 0.22),
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

    const lightSettingsTitleColor = Color.fromRGBO(109, 109, 114, 1);
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

    final isLight = brightness == .light;

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

  /// Web theme mirrors the Android Material 3 derivation but also sets
  /// [settingsSectionBackground] for the card background.
  static SettingsThemeData _webTheme({
    required BuildContext context,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme.of(context);

    return SettingsThemeData(
      tileHighlightColor: colorScheme.secondaryContainer,
      settingsListBackground: colorScheme.surfaceContainerLow,
      settingsSectionBackground: colorScheme.surface,
      titleTextColor: colorScheme.primary,
      settingsTileTextColor: colorScheme.onSurface,
      tileDescriptionTextColor: colorScheme.onSurfaceVariant,
      leadingIconsColor: colorScheme.onSurfaceVariant,
      inactiveTitleColor: colorScheme.onSurface.withValues(alpha: 0.38),
      inactiveSubtitleColor: colorScheme.onSurface.withValues(alpha: 0.22),
    );
  }
}
