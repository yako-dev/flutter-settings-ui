import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/tiles/tile_semantics.dart';

/// What a [SettingsTile] hands to the tile of its style: its own fields,
/// with [onPressed] already followed by opening the destination and a null
/// `initialValue` read as off. Internal.
@immutable
class SettingsTileData {
  const SettingsTileData({
    required this.tileType,
    required this.leading,
    required this.title,
    required this.titleDescription,
    required this.description,
    required this.onPressed,
    required this.onToggle,
    required this.value,
    required this.initialValue,
    required this.activeSwitchColor,
    required this.enabled,
    required this.trailing,
    required this.compact,
    required this.titlePadding,
    required this.leadingPadding,
    required this.trailingPadding,
    required this.descriptionPadding,
    required this.titleDescriptionPadding,
  });

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget title;
  final Widget? titleDescription;
  final Widget? description;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final Widget? value;
  final bool initialValue;
  final Color? activeSwitchColor;
  final bool enabled;
  final Widget? trailing;
  final bool compact;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? leadingPadding;
  final EdgeInsetsGeometry? trailingPadding;
  final EdgeInsetsGeometry? descriptionPadding;
  final EdgeInsetsGeometry? titleDescriptionPadding;

  bool get isSwitch => tileType == SettingsTileType.switchTile;

  bool get isNavigation => tileType == SettingsTileType.navigationTile;

  /// A row with [onPressed] and a switch has two actions, so the switch is a
  /// semantics node of its own. It gets the title as its label.
  Widget labelSwitchIfSeparate(Widget child) =>
      onPressed == null ? child : labelTileSwitch(title: title, child: child);
}
