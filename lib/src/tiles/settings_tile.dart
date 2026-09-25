import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/split/settings_destination.dart';
import 'package:settings_ui/src/split/settings_destination_page.dart';
import 'package:settings_ui/src/split/split_scopes.dart';
import 'package:settings_ui/src/tiles/abstract_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/adwaita_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/android_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/fluent_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/ios_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/macos_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/web_settings_menu_item.dart';
import 'package:settings_ui/src/tiles/platforms/web_settings_tile.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

enum SettingsTileType { simpleTile, switchTile, navigationTile }

class SettingsTile extends AbstractSettingsTile {
  SettingsTile({
    this.leading,
    this.trailing,
    this.value,
    required this.title,
    this.titleDescription,
    this.description,
    this.onPressed,
    this.enabled = true,
    this.compact = false,
    this.titlePadding,
    this.leadingPadding,
    this.trailingPadding,
    this.descriptionPadding,
    this.titleDescriptionPadding,
    super.key,
  }) : destination = null {
    onToggle = null;
    initialValue = null;
    activeSwitchColor = null;
    tileType = SettingsTileType.simpleTile;
  }

  SettingsTile.navigation({
    this.leading,
    this.trailing,
    this.value,
    required this.title,
    this.titleDescription,
    this.description,
    this.onPressed,
    this.enabled = true,
    this.compact = false,
    this.titlePadding,
    this.leadingPadding,
    this.trailingPadding,
    this.descriptionPadding,
    this.titleDescriptionPadding,
    this.destination,
    super.key,
  }) {
    onToggle = null;
    initialValue = null;
    activeSwitchColor = null;
    tileType = SettingsTileType.navigationTile;
  }

  SettingsTile.switchTile({
    required this.initialValue,
    required this.onToggle,
    this.activeSwitchColor,
    this.leading,
    this.trailing,
    required this.title,
    this.titleDescription,
    this.description,
    this.onPressed,
    this.enabled = true,
    this.compact = false,
    this.titlePadding,
    this.leadingPadding,
    this.trailingPadding,
    this.descriptionPadding,
    this.titleDescriptionPadding,
    super.key,
  }) : destination = null {
    value = null;
    tileType = SettingsTileType.switchTile;
  }

  /// The widget at the beginning of the tile
  final Widget? leading;

  /// The Widget at the end of the tile
  final Widget? trailing;

  /// The widget at the center of the tile
  final Widget title;

  /// The widget at the under of the title
  final Widget? titleDescription;

  /// The widget at the bottom of the [title]
  final Widget? description;

  /// A function that is called by tap on a tile
  final Function(BuildContext context)? onPressed;

  /// When true, reduces the tile's vertical padding by half for a more
  /// compact appearance in dense settings lists.
  final bool compact;

  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? leadingPadding;
  final EdgeInsetsGeometry? trailingPadding;
  final EdgeInsetsGeometry? descriptionPadding;
  final EdgeInsetsGeometry? titleDescriptionPadding;

  /// The page this navigation tile opens (set with
  /// [SettingsTile.navigation]).
  ///
  /// A tap calls [onPressed] first, if set, then opens the page: in a
  /// [SettingsList] it pushes a platform route (Cupertino on the iOS style,
  /// Material otherwise) with the package's page header over the body; in
  /// the list pane of a [SettingsSplitView] it shows the page in the detail
  /// pane, and the tile is drawn selected while its page shows there.
  final SettingsDestination? destination;

  late final Color? activeSwitchColor;
  late final Widget? value;
  late final Function(bool value)? onToggle;
  late final SettingsTileType tileType;
  late final bool? initialValue;
  late final bool enabled;

  /// [onPressed], followed by opening [destination].
  Function(BuildContext context)? get _effectiveOnPressed {
    final destination = this.destination;
    if (destination == null) return onPressed;
    return (BuildContext context) {
      onPressed?.call(context);
      if (!context.mounted) return;
      openSettingsDestination(
        context,
        destination: destination,
        tileTitle: title,
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final listPane = SettingsSplitListScope.maybeOf(context);
    final tile = _buildTile(context, listPane);
    if (listPane != null && listPane.isSplit && destination != null) {
      return Semantics(selected: listPane.isSelected(destination), child: tile);
    }
    return tile;
  }

  Widget _buildTile(BuildContext context, SettingsSplitListScope? listPane) {
    final theme = SettingsTheme.of(context);
    final inSplitListPane = listPane != null && listPane.isSplit;
    final selected = listPane?.isSelected(destination) ?? false;
    final onPressed = _effectiveOnPressed;

    switch (theme.platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
        return AndroidSettingsTile(
          description: description,
          onPressed: onPressed,
          onToggle: onToggle,
          tileType: tileType,
          value: value,
          leading: inSplitListPane && listPane.hideLeading ? null : leading,
          title: title,
          enabled: enabled,
          compact: compact,
          activeSwitchColor: activeSwitchColor,
          initialValue: initialValue ?? false,
          trailing: trailing,
          titlePadding: titlePadding,
          leadingPadding: leadingPadding,
          trailingPadding: trailingPadding,
          descriptionPadding: descriptionPadding,
          selected: selected,
        );
      case DevicePlatform.linux:
        return AdwaitaSettingsTile(
          description: description,
          onPressed: onPressed,
          onToggle: onToggle,
          tileType: tileType,
          value: value,
          leading: leading,
          title: title,
          titleDescription: titleDescription,
          trailing: trailing,
          enabled: enabled,
          compact: compact,
          activeSwitchColor: activeSwitchColor,
          initialValue: initialValue ?? false,
          titlePadding: titlePadding,
          leadingPadding: leadingPadding,
          trailingPadding: trailingPadding,
          descriptionPadding: descriptionPadding,
          titleDescriptionPadding: titleDescriptionPadding,
        );
      case DevicePlatform.macOS:
        return MacosSettingsTile(
          description: description,
          onPressed: onPressed,
          onToggle: onToggle,
          tileType: tileType,
          value: value,
          leading: leading,
          title: title,
          titleDescription: titleDescription,
          trailing: trailing,
          enabled: enabled,
          compact: compact,
          activeSwitchColor: activeSwitchColor,
          initialValue: initialValue ?? false,
          titlePadding: titlePadding,
          leadingPadding: leadingPadding,
          trailingPadding: trailingPadding,
          descriptionPadding: descriptionPadding,
          titleDescriptionPadding: titleDescriptionPadding,
        );
      case DevicePlatform.iOS:
        return IOSSettingsTile(
          description: description,
          onPressed: onPressed,
          onToggle: onToggle,
          tileType: tileType,
          value: value,
          leading: leading,
          title: title,
          titleDescription: titleDescription,
          trailing: trailing,
          enabled: enabled,
          compact: compact,
          activeSwitchColor: activeSwitchColor,
          initialValue: initialValue ?? false,
          titlePadding: titlePadding,
          leadingPadding: leadingPadding,
          trailingPadding: trailingPadding,
          descriptionPadding: descriptionPadding,
          titleDescriptionPadding: titleDescriptionPadding,
          selected: selected,
          sidebar: inSplitListPane,
        );
      case DevicePlatform.windows:
        return FluentSettingsTile(
          description: description,
          onPressed: onPressed,
          onToggle: onToggle,
          tileType: tileType,
          value: value,
          leading: leading,
          title: title,
          titleDescription: titleDescription,
          trailing: trailing,
          enabled: enabled,
          compact: compact,
          activeSwitchColor: activeSwitchColor,
          initialValue: initialValue ?? false,
          titlePadding: titlePadding,
          leadingPadding: leadingPadding,
          trailingPadding: trailingPadding,
          descriptionPadding: descriptionPadding,
          titleDescriptionPadding: titleDescriptionPadding,
        );
      case DevicePlatform.web:
        if (inSplitListPane) {
          return WebSettingsMenuItem(
            onPressed: onPressed,
            onToggle: onToggle,
            tileType: tileType,
            leading: leading,
            title: title,
            enabled: enabled,
            initialValue: initialValue ?? false,
            activeSwitchColor: activeSwitchColor,
            selected: selected,
            trailing: trailing,
          );
        }
        return WebSettingsTile(
          description: description,
          onPressed: onPressed,
          onToggle: onToggle,
          tileType: tileType,
          value: value,
          leading: leading,
          title: title,
          enabled: enabled,
          compact: compact,
          trailing: trailing,
          activeSwitchColor: activeSwitchColor,
          initialValue: initialValue ?? false,
          titlePadding: titlePadding,
          leadingPadding: leadingPadding,
          trailingPadding: trailingPadding,
          descriptionPadding: descriptionPadding,
        );
      case DevicePlatform.device:
        throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: SettingsTile.build',
        );
    }
  }
}
