import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/android_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/ios_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/web_settings_section.dart';
import 'package:settings_ui/src/tiles/abstract_settings_tile.dart';
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
  Widget build(BuildContext context) =>
      switch (SettingsTheme.of(context).platform) {
        .android || .linux => AndroidSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
          titlePadding: titlePadding,
        ),
        .iOS || .macOS || .windows => IOSSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
          titlePadding: titlePadding,
        ),
        .web => WebSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
          titlePadding: titlePadding,
        ),
        .device => throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: SettingsSection.build',
        ),
      };
}
