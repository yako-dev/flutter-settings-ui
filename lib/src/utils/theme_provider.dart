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
      case DevicePlatform.linux:
        return _androidTheme(context: context, brightness: brightness);
      case DevicePlatform.macOS:
        return _macosTheme(brightness: brightness);
      case DevicePlatform.iOS:
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

  /// macOS 26/27 System Settings (a SwiftUI grouped `Form`): a white or
  /// #1E1E1E window background with #F7F7F7 or #252525 cards, and the
  /// translucent `NSColor` label colors, which blend with whatever is behind
  /// them like AppKit's do. Like the iOS style, it ignores [ColorScheme].
  static SettingsThemeData _macosTheme({required Brightness brightness}) {
    final isLight = brightness == Brightness.light;

    // labelColor, secondaryLabelColor and tertiaryLabelColor.
    const lightLabel = Color(0xD8000000);
    const darkLabel = Color(0xD8FFFFFF);
    const lightSecondaryLabel = Color(0x7F000000);
    const darkSecondaryLabel = Color(0x8CFFFFFF);
    const lightTertiaryLabel = Color(0x42000000);
    const darkTertiaryLabel = Color(0x3FFFFFFF);

    final label = isLight ? lightLabel : darkLabel;
    final secondaryLabel = isLight ? lightSecondaryLabel : darkSecondaryLabel;
    final tertiaryLabel = isLight ? lightTertiaryLabel : darkTertiaryLabel;

    return SettingsThemeData(
      // windowBackgroundColor, without the wallpaper tint of macOS 26+.
      settingsListBackground: isLight
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF1E1E1E),
      settingsSectionBackground: isLight
          ? const Color(0xFFF7F7F7)
          : const Color(0xFF252525),
      // 1pt separators: black 5% or white 4.7% over the card.
      dividerColor: isLight ? const Color(0xFFEBEBEB) : const Color(0xFF2F2F2F),
      // A pressed row: a light fill over the card.
      tileHighlightColor: isLight
          ? const Color(0x0F000000)
          : const Color(0x14FFFFFF),
      titleTextColor: label,
      settingsTileTextColor: label,
      trailingTextColor: secondaryLabel,
      tileDescriptionTextColor: secondaryLabel,
      leadingIconsColor: secondaryLabel,
      inactiveTitleColor: tertiaryLabel,
      inactiveSubtitleColor: tertiaryLabel,
    );
  }

  /// Uses Cupertino system colors for iOS/Windows — these are not
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
