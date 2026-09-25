import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/adwaita_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/android_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/fluent_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/ios_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/macos_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/web_settings_section.dart';
import 'package:settings_ui/src/split/adwaita_split.dart';
import 'package:settings_ui/src/split/fluent_split.dart';
import 'package:settings_ui/src/split/macos_split.dart';
import 'package:settings_ui/src/split/split_scopes.dart';
import 'package:settings_ui/src/tiles/abstract_settings_tile.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

class SettingsSection extends AbstractSettingsSection {
  const SettingsSection({
    required this.tiles,
    this.margin,
    this.title,
    this.titlePadding,
    super.key,
  });

  final List<AbstractSettingsTile> tiles;
  final EdgeInsetsDirectional? margin;
  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;

  @override
  Widget build(BuildContext context) {
    // A section with no tiles (e.g. all of them are conditional) shows
    // nothing, not a header over an empty card.
    if (tiles.isEmpty) return const SizedBox.shrink();

    final theme = SettingsTheme.of(context);

    if (SettingsSplitListScope.drawsSidebarOf(context)) {
      // The sidebar of a macOS, Windows or GNOME style split view.
      final Widget? sidebarSection;
      switch (theme.platform) {
        case DevicePlatform.macOS:
          sidebarSection = MacosSidebarSection(
            title: title,
            titlePadding: titlePadding,
            tiles: tiles,
          );
        case DevicePlatform.windows:
          sidebarSection = FluentNavigationSection(
            title: title,
            titlePadding: titlePadding,
            tiles: tiles,
          );
        case DevicePlatform.linux:
          sidebarSection = AdwaitaSidebarSection(
            title: title,
            titlePadding: titlePadding,
            tiles: tiles,
          );
        case DevicePlatform.iOS:
        case DevicePlatform.android:
        case DevicePlatform.fuchsia:
        case DevicePlatform.web:
        case DevicePlatform.device:
          sidebarSection = null;
      }
      if (sidebarSection != null) {
        final margin = this.margin;
        return margin == null
            ? sidebarSection
            : Padding(padding: margin, child: sidebarSection);
      }
    }

    switch (theme.platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
        return AndroidSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
          titlePadding: titlePadding,
        );
      case DevicePlatform.linux:
        return AdwaitaSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
          titlePadding: titlePadding,
        );
      case DevicePlatform.macOS:
        return MacosSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
          titlePadding: titlePadding,
        );
      case DevicePlatform.iOS:
        return IOSSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
          titlePadding: titlePadding,
        );
      case DevicePlatform.windows:
        return FluentSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
          titlePadding: titlePadding,
        );
      case DevicePlatform.web:
        return WebSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
          titlePadding: titlePadding,
        );
      case DevicePlatform.device:
        throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: SettingsSection.build',
        );
    }
  }
}
