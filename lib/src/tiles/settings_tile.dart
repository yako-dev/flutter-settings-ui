import 'package:flutter/material.dart';
import 'package:settings_ui/src/tiles/abstract_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/android_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/ios_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/web_settings_tile.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

enum SettingsTileType { simpleTile, switchTile, navigationTile, expandableTile }

typedef BuilderFunction = Widget Function(VoidCallback close);

class SettingsTile extends AbstractSettingsTile {
  SettingsTile({
    this.leading,
    this.trailing,
    this.value,
    required this.title,
    this.description,
    this.onPressed,
    this.enabled = true,
    Key? key,
  })  : builder = null,
        onToggle = null,
        initialValue = null,
        activeSwitchColor = null,
        tileType = SettingsTileType.simpleTile,
        super(key: key);

  SettingsTile.navigation({
    this.leading,
    this.trailing,
    this.value,
    required this.title,
    this.description,
    this.onPressed,
    this.enabled = true,
    Key? key,
  })  : builder = null,
        onToggle = null,
        initialValue = null,
        activeSwitchColor = null,
        tileType = SettingsTileType.navigationTile,
        super(key: key);

  SettingsTile.switchTile({
    required this.initialValue,
    required this.onToggle,
    this.activeSwitchColor,
    this.leading,
    this.trailing,
    required this.title,
    this.description,
    this.onPressed,
    this.enabled = true,
    Key? key,
  })  : builder = null,
        value = null,
        tileType = SettingsTileType.switchTile,
        super(key: key);

  SettingsTile.expandableTile({
    required this.title,
    required this.builder,
    this.enabled = true,
    this.leading,
    this.trailing,
    this.description,
    Key? key,
  })  : initialValue = null,
        activeSwitchColor = null,
        onPressed = null,
        onToggle = null,
        value = null,
        tileType = SettingsTileType.expandableTile,
        super(key: key);

  /// The widget at the beginning of the tile
  final Widget? leading;

  /// The Widget at the end of the tile
  final Widget? trailing;

  /// The widget at the center of the tile
  final Widget title;

  /// The widget at the bottom of the [title]
  final Widget? description;

  /// A function that is called by tap on a tile
  final Function(BuildContext context)? onPressed;

  /// Expand duration for the expandable tile
  final Duration expandDuration = Duration(seconds: 1);

  /// Contract duration for the expandable tile
  final Duration contractDuration = Duration(milliseconds: 300);

  /// Expand curve for the expandable tile
  final Curve expandCurve = Curves.fastLinearToSlowEaseIn;

  /// Contract curve for the expandable tile
  final Curve contractCurve = Curves.fastOutSlowIn;

  /// Builder for the expandable tile
  /// Only argument is [close], which is a function to close the tile
  final BuilderFunction? builder;

  final Color? activeSwitchColor;
  final Widget? value;
  final Function(bool value)? onToggle;
  final SettingsTileType tileType;
  final bool? initialValue;
  final bool enabled;

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
          enabled: enabled,
          activeSwitchColor: activeSwitchColor,
          initialValue: initialValue ?? false,
          trailing: trailing,
          builder: builder,
          expandDuration: expandDuration,
          contractDuration: contractDuration,
          expandCurve: expandCurve,
          contractCurve: contractCurve,
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
          trailing: trailing,
          enabled: enabled,
          activeSwitchColor: activeSwitchColor,
          initialValue: initialValue ?? false,
        );
      case DevicePlatform.web:
        return WebSettingsTile(
          description: description,
          onPressed: onPressed,
          onToggle: onToggle,
          tileType: tileType,
          value: value,
          leading: leading,
          title: title,
          enabled: enabled,
          trailing: trailing,
          activeSwitchColor: activeSwitchColor,
          initialValue: initialValue ?? false,
        );
      case DevicePlatform.device:
        throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: SettingsTile.build',
        );
    }
  }
}
