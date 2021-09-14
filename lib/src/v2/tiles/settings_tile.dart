import 'package:flutter/material.dart';
import 'package:settings_ui/src/v2/tiles/abstract_settings_tile.dart';
import 'package:settings_ui/src/v2/tiles/platforms/android_settings_tile.dart';
import 'package:settings_ui/src/v2/tiles/platforms/ios_settings_tile.dart';
import 'package:settings_ui/src/v2/tiles/platforms/web_settings_tile.dart';
import 'package:settings_ui/src/v2/utils/platform_utils.dart';
import 'package:settings_ui/src/v2/utils/settings_theme.dart';

enum SettingsTileType { simpleTile, switchTile, navigationTile }

class SettingsTile extends AbstractSettingsTile {
  SettingsTile({
    this.leading,
    this.value,
    required this.title,
    this.description,
    this.onPressed,
    Key? key,
  }) : super(key: key) {
    onToggle = null;
    initialValue = null;
    tileType = SettingsTileType.simpleTile;
  }

  SettingsTile.navigation({
    this.leading,
    this.value,
    required this.title,
    this.description,
    this.onPressed,
    Key? key,
  }) : super(key: key) {
    onToggle = null;
    initialValue = null;
    tileType = SettingsTileType.navigationTile;
  }

  SettingsTile.switchTile({
    required this.initialValue,
    required this.onToggle,
    this.leading,
    required this.title,
    this.description,
    this.onPressed,
    Key? key,
  }) : super(key: key) {
    value = null;
    tileType = SettingsTileType.switchTile;
  }

  final Widget? leading;
  final Widget title;
  final Widget? description;
  final Function(BuildContext context)? onPressed;

  late final Widget? value;
  late final Function(bool value)? onToggle;
  late final SettingsTileType tileType;
  late final bool? initialValue;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context);

    switch (theme.platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
        return AndroidSettingsTile(
          description: description,
          onPressed: onPressed,
          onToggle: onToggle,
          tileType: tileType,
          value: value,
          leading: leading,
          title: title,
          initialValue: initialValue ?? false,
        );
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        return IOSSettingsTile(
          description: description,
          onPressed: onPressed,
          onToggle: onToggle,
          tileType: tileType,
          value: value,
          leading: leading,
          title: title,
          initialValue: initialValue,
        );
      case DevicePlatform.web:
        return WebSettingsTile(
          leading: leading,
          title: title,
        );
    }
  }
}
