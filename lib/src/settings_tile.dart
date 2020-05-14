import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/cupertino_settings_item.dart';

enum _SettingsTileType { simple, switchTile }

class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget leading;
  final Widget trailing;
  final VoidCallback onTap;
  final Function(bool value) onToggle;
  final bool switchValue;
  final _SettingsTileType _tileType;

  const SettingsTile({
    Key key,
    @required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  })  : _tileType = _SettingsTileType.simple,
        onToggle = null,
        switchValue = null,
        super(key: key);

  const SettingsTile.switchTile({
    Key key,
    @required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    @required this.onToggle,
    @required this.switchValue,
  })  : _tileType = _SettingsTileType.switchTile,
        onTap = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isIOS) {
      return iosTile();
    } else {
      return androidTile();
    }
  }

  Widget iosTile() {
    if (_tileType == _SettingsTileType.switchTile) {
      return CupertinoSettingsItem(
        type: SettingsItemType.toggle,
        label: title,
        leading: leading,
        switchValue: switchValue,
        onToggle: onToggle,
      );
    } else {
      return CupertinoSettingsItem(
        type: SettingsItemType.modal,
        label: title,
        value: subtitle,
        trailing: trailing,
        hasDetails: false,
        leading: leading,
        onPress: onTap,
      );
    }
  }

  Widget androidTile() {
    if (_tileType == _SettingsTileType.switchTile) {
      return SwitchListTile(
        secondary: leading,
        value: switchValue,
        onChanged: onToggle,
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
      );
    } else {
      return ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
      );
    }
  }
}
