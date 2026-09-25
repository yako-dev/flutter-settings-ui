import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/utils/fluent_tokens.dart';
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
        return _androidTheme(context: context, brightness: brightness);
      case DevicePlatform.linux:
        return _adwaitaTheme(brightness: brightness);
      case DevicePlatform.macOS:
        return _macosTheme(brightness: brightness);
      case DevicePlatform.iOS:
        return _iosTheme(context: context, brightness: brightness);
      case DevicePlatform.windows:
        return _fluentTheme(brightness: brightness);
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

  /// Uses Cupertino system colors for iOS — these are not
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

  /// Windows 11 Settings colors (WinUI 3 theme resources): the Mica
  /// fallback page, near-white (#2B2B2B dark) cards with a hairline border,
  /// and the Windows text colors. Like the iOS style, it does not read the
  /// app's [ColorScheme].
  static SettingsThemeData _fluentTheme({required Brightness brightness}) {
    final tokens = FluentTokens.of(brightness);
    return SettingsThemeData(
      settingsListBackground: tokens.page,
      settingsSectionBackground: tokens.card,
      dividerColor: tokens.cardStroke,
      tileHighlightColor: tokens.cardPressed,
      titleTextColor: tokens.textPrimary,
      settingsTileTextColor: tokens.textPrimary,
      tileDescriptionTextColor: tokens.textSecondary,
      trailingTextColor: tokens.textSecondary,
      leadingIconsColor: tokens.textPrimary,
      inactiveTitleColor: tokens.textDisabled,
      inactiveSubtitleColor: tokens.textDisabled,
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
