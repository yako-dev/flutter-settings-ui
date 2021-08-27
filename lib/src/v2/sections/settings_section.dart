import 'package:flutter/material.dart';
import 'package:settings_ui/src/v2/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/v2/sections/platforms/android_settings_section.dart';
import 'package:settings_ui/src/v2/sections/platforms/ios_settings_section.dart';
import 'package:settings_ui/src/v2/sections/platforms/web_settings_section.dart';
import 'package:settings_ui/src/v2/tiles/abstract_settings_tile.dart';
import 'package:settings_ui/src/v2/utils/platform_utils.dart';

class SettingsSection extends AbstractSettingsSection {
  const SettingsSection({
    required this.tiles,
    this.margin,
    this.title,
    Key? key,
  }) : super(key: key);

  final List<AbstractSettingsTile> tiles;
  final EdgeInsetsDirectional? margin;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final platform = PlatformUtils.detectPlatform(context);

    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
        return AndroidSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
        );
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        return IOSSettingsSection(
          title: title,
          tiles: tiles,
          margin: margin,
        );
      case DevicePlatform.web:
        return WebSettingsSection(
          title: title,
          tiles: tiles,
        );
    }
  }
}
