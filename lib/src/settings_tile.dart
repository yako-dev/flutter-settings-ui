import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/src/cupertino_settings_item.dart';
import 'package:settings_ui/src/item_type/settings_slider.dart';

import 'defines.dart';

enum _SettingsTileType { simple, switchTile, sliderTile }

class SettingsTile extends StatelessWidget {
  final String title;
  final int? titleMaxLines;
  final String? subtitle;
  final int? subtitleMaxLines;
  final Widget? leading;
  final Widget? trailing;
  final Icon? iosChevron;
  final EdgeInsetsGeometry? iosChevronPadding;
  final VoidCallback? onTap;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final bool? switchValue;
  final bool enabled;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final Color? switchActiveColor;
  final _SettingsTileType _tileType;
  final SettingsSlider? settingsSlider;

  const SettingsTile({
    Key? key,
    required this.title,
    this.titleMaxLines,
    this.subtitle,
    this.subtitleMaxLines,
    this.leading,
    this.trailing,
    this.iosChevron = defaultCupertinoForwardIcon,
    this.iosChevronPadding = defaultCupertinoForwardPadding,
    @Deprecated('Use onPressed instead') this.onTap,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.enabled = true,
    this.onPressed,
    this.switchActiveColor,
    this.settingsSlider,
  })  : _tileType = _SettingsTileType.simple,
        onToggle = null,
        switchValue = null,
        assert(titleMaxLines == null || titleMaxLines > 0),
        assert(subtitleMaxLines == null || subtitleMaxLines > 0),
        super(key: key);

  const SettingsTile.switchTile(
      {Key? key,
      required this.title,
      this.titleMaxLines,
      this.subtitle,
      this.subtitleMaxLines,
      this.leading,
      this.enabled = true,
      this.trailing,
      required this.onToggle,
      required this.switchValue,
      this.titleTextStyle,
      this.subtitleTextStyle,
      this.switchActiveColor,
      this.settingsSlider})
      : _tileType = _SettingsTileType.switchTile,
        onTap = null,
        onPressed = null,
        iosChevron = null,
        iosChevronPadding = null,
        assert(titleMaxLines == null || titleMaxLines > 0),
        assert(subtitleMaxLines == null || subtitleMaxLines > 0),
        super(key: key);

  SettingsTile.sliderTile({
    Key? key,
    this.titleMaxLines,
    this.leading,
    this.enabled = true,
    this.trailing,
    required this.settingsSlider,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.switchActiveColor,
    required this.title,
    this.subtitle,
    this.subtitleMaxLines,
    this.onToggle,
    this.switchValue,
  })  : _tileType = _SettingsTileType.sliderTile,
        onTap = null,
        onPressed = null,
        iosChevron = null,
        iosChevronPadding = null,
        assert(titleMaxLines == null || titleMaxLines > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return iosTile(context);

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return androidTile(context);

      default:
        return iosTile(context);
    }
  }

  Widget iosTile(BuildContext context) {
    if (_tileType == _SettingsTileType.sliderTile) {
      return CupertinoSettingsItem(
        enabled: enabled,
        type: SettingsItemType.slider,
        label: title,
        labelMaxLines: titleMaxLines,
        leading: leading,
        subtitle: subtitle,
        subtitleMaxLines: subtitleMaxLines,
        switchValue: switchValue,
        onToggle: onToggle,
        labelTextStyle: titleTextStyle,
        switchActiveColor: switchActiveColor,
        subtitleTextStyle: subtitleTextStyle,
        valueTextStyle: subtitleTextStyle,
        trailing: trailing,
      );
    } else if (_tileType == _SettingsTileType.switchTile) {
      return CupertinoSettingsItem(
        enabled: enabled,
        type: SettingsItemType.toggle,
        label: title,
        labelMaxLines: titleMaxLines,
        leading: leading,
        subtitle: subtitle,
        subtitleMaxLines: subtitleMaxLines,
        switchValue: switchValue,
        onToggle: onToggle,
        labelTextStyle: titleTextStyle,
        switchActiveColor: switchActiveColor,
        subtitleTextStyle: subtitleTextStyle,
        valueTextStyle: subtitleTextStyle,
        trailing: trailing,
      );
    } else {
      return CupertinoSettingsItem(
        enabled: enabled,
        type: SettingsItemType.modal,
        label: title,
        labelMaxLines: titleMaxLines,
        value: subtitle,
        trailing: trailing,
        iosChevron: iosChevron,
        iosChevronPadding: iosChevronPadding,
        hasDetails: false,
        leading: leading,
        onPress: onTapFunction(context),
        labelTextStyle: titleTextStyle,
        subtitleTextStyle: subtitleTextStyle,
        valueTextStyle: subtitleTextStyle,
      );
    }
  }

  Widget androidTile(BuildContext context) {
    if (_tileType == _SettingsTileType.switchTile) {
      return SwitchListTile(
        secondary: leading,
        value: switchValue!,
        activeColor: switchActiveColor,
        onChanged: enabled ? onToggle : null,
        title: Text(
          title,
          style: titleTextStyle,
          maxLines: titleMaxLines,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: subtitleTextStyle,
                maxLines: subtitleMaxLines,
                overflow: TextOverflow.ellipsis,
              )
            : null,
      );
    } else if (_tileType == _SettingsTileType.sliderTile) {
      return ListTile(
        title: Slider(
          value: settingsSlider!.value,
          min: settingsSlider!.min,
          max: settingsSlider!.max,
          onChangeStart: settingsSlider!.onChangeStart,
          onChangeEnd: settingsSlider!.onChangeEnd,
          onChanged: settingsSlider!.onChanged,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: subtitleTextStyle,
                maxLines: subtitleMaxLines,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        leading: leading,
        enabled: enabled,
        trailing: trailing,
        onTap: onTapFunction(context),
      );
    } else {
      return ListTile(
        title: Text(title, style: titleTextStyle),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: subtitleTextStyle,
                maxLines: subtitleMaxLines,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        leading: leading,
        enabled: enabled,
        trailing: trailing,
        onTap: onTapFunction(context),
      );
    }
  }

  VoidCallback? onTapFunction(BuildContext context) =>
      onTap != null || onPressed != null
          ? () {
              if (onPressed != null) {
                onPressed!.call(context);
              } else {
                onTap!.call();
              }
            }
          : null;
}
