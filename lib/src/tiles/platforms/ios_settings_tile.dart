import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/tiles/platforms/ios_settings_tile_additional_info.dart';

class IOSSettingsTile extends StatefulWidget {
  const IOSSettingsTile({
    required this.tileType,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onPressed,
    required this.onToggle,
    required this.value,
    required this.initialValue,
    required this.activeSwitchColor,
    required this.enabled,
    required this.trailing,
    this.titlePadding,
    this.leadingPadding,
    this.subtitlePadding,
    Key? key,
  }) : super(key: key);

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? description;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final Widget? value;
  final bool? initialValue;
  final bool enabled;
  final Color? activeSwitchColor;
  final Widget? trailing;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? leadingPadding;
  final EdgeInsetsGeometry? subtitlePadding;

  @override
  IOSSettingsTileState createState() => IOSSettingsTileState();
}

class IOSSettingsTileState extends State<IOSSettingsTile> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final additionalInfo = IOSSettingsTileAdditionalInfo.of(context);
    final theme = SettingsTheme.of(context);
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    Widget content = _IosTileContent(
      theme: theme,
      additionalInfo: additionalInfo,
      tileType: widget.tileType,
      leading: widget.leading,
      title: widget.title,
      subtitle: widget.subtitle,
      description: widget.description,
      onPressed: widget.onPressed,
      onToggle: widget.onToggle,
      value: widget.value,
      initialValue: widget.initialValue,
      enabled: widget.enabled,
      activeSwitchColor: widget.activeSwitchColor,
      trailing: widget.trailing,
      titlePadding: widget.titlePadding,
      leadingPadding: widget.leadingPadding,
      subtitlePadding: widget.subtitlePadding,
      isPressed: isPressed,
      executeAction: _executeAction,
      changePressState: _changePressState,
    );

    final platform = PlatformUtils.detectPlatform(context);
    if (platform != DevicePlatform.iOS) {
      content = Material(
        color: Colors.transparent,
        child: content,
      );
    }

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Column(
        children: [
          ClipRRect(
            // TODO: move literals to file with theme constants
            borderRadius: BorderRadius.vertical(
              top: additionalInfo.enableTopBorderRadius
                  ? const Radius.circular(12)
                  : Radius.zero,
              bottom: additionalInfo.enableBottomBorderRadius
                  ? const Radius.circular(12)
                  : Radius.zero,
            ),
            child: content,
          ),
          if (widget.description != null)
            Container(
              width: MediaQuery.of(context).size.width,
              // TODO: move literals to file with theme constants
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 8 * scaleFactor,
                bottom: additionalInfo.needToShowDivider ? 24 : 8 * scaleFactor,
              ),
              decoration: BoxDecoration(
                // TODO: check if this is correct
                color: theme.themeData.settingsListBackground,
              ),
              child: DefaultTextStyle(
                // TODO: move literals to file with theme constants
                style: TextStyle(
                  color: theme.themeData.titleTextColor,
                  fontSize: 13,
                ),
                child: widget.description!,
              ),
            ),
        ],
      ),
    );
  }

  void _changePressState({bool isPressed = false}) {
    if (mounted) {
      setState(() {
        this.isPressed = isPressed;
      });
    }
  }

  void _executeAction(BuildContext context) {
    _changePressState(isPressed: true);

    widget.onPressed!.call(context);
    Future.delayed(
      // TODO: move literals to file with theme constants
      const Duration(milliseconds: 100),
      () => _changePressState(isPressed: false),
    );
  }
}

class _IosTileContent extends StatelessWidget {
  final SettingsTheme theme;
  final SettingsTileType tileType;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? description;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final Widget? value;
  final bool? initialValue;
  final bool enabled;
  final Color? activeSwitchColor;
  final Widget? trailing;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? leadingPadding;
  final EdgeInsetsGeometry? subtitlePadding;
  final IOSSettingsTileAdditionalInfo additionalInfo;
  final bool isPressed;
  final Function(BuildContext context) executeAction;
  final Function({bool isPressed}) changePressState;

  const _IosTileContent({
    required this.theme,
    required this.additionalInfo,
    required this.tileType,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.onPressed,
    required this.onToggle,
    required this.value,
    required this.initialValue,
    required this.enabled,
    required this.activeSwitchColor,
    required this.trailing,
    required this.titlePadding,
    required this.leadingPadding,
    required this.subtitlePadding,
    required this.isPressed,
    required this.executeAction,
    required this.changePressState,
  });

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onPressed == null ? null : () => executeAction(context),
      onTapDown: (_) =>
          onPressed == null ? null : changePressState(isPressed: true),
      onTapUp: (_) =>
          onPressed == null ? null : changePressState(isPressed: false),
      onTapCancel: () =>
          onPressed == null ? null : changePressState(isPressed: false),
      child: Container(
        key: const Key('ios_settings_tile_container'),
        color: isPressed
            ? theme.themeData.tileHighlightColor
            : theme.themeData.settingsSectionBackground,
        // TODO: move literals to file with theme constants
        padding: const EdgeInsetsDirectional.only(start: 18),
        child: Row(
          children: [
            if (leading != null)
              Padding(
                padding: leadingPadding ??
                    // TODO: move literals to file with theme constants
                    const EdgeInsetsDirectional.only(end: 12.0),
                child: IconTheme.merge(
                  data: IconThemeData(
                    color: enabled
                        ? theme.themeData.tileLeadingIconsColor
                        : theme.themeData.tileDisabledContentColor,
                  ),
                  child: leading!,
                ),
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: titlePadding ??
                                    // TODO: move literals to file with theme constants
                                    EdgeInsetsDirectional.only(
                                      top: 12.5 * scaleFactor,
                                      bottom: subtitle == null
                                          ? (12.5 * scaleFactor)
                                          : (3.5 * scaleFactor),
                                    ),
                                child: DefaultTextStyle(
                                  // TODO: move literals to file with theme constants
                                  style: TextStyle(
                                    color: enabled
                                        ? theme.themeData.tileTitleTextColor
                                        : theme
                                            .themeData.tileDisabledContentColor,
                                    fontSize: 16,
                                  ),
                                  child: title!,
                                ),
                              ),
                              if (subtitle != null)
                                Padding(
                                  padding: subtitlePadding ??
                                      EdgeInsetsDirectional.only(
                                        // TODO: move literals to file with theme constants
                                        bottom: 12.5 * scaleFactor,
                                      ),
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                      color: enabled
                                          ? theme.themeData.titleTextColor
                                          : theme.themeData
                                              .tileDisabledContentColor,
                                      fontSize: 15,
                                    ),
                                    child: subtitle!,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _IosTileTrailing(
                          context: context,
                          theme: theme,
                          tileType: tileType,
                          value: value,
                          initialValue: initialValue,
                          enabled: enabled,
                          activeSwitchColor: activeSwitchColor,
                          onToggle: onToggle,
                          trailing: trailing,
                        ),
                      ],
                    ),
                  ),
                  if (description == null && additionalInfo.needToShowDivider)
                    // TODO: move literals to file with theme constants
                    Divider(
                      height: 0,
                      thickness: 0.7,
                      color: theme.themeData.tilesDividerColor,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IosTileTrailing extends StatelessWidget {
  final Widget? trailing;
  final SettingsTileType tileType;
  final Widget? value;
  final bool? initialValue;
  final bool enabled;
  final Color? activeSwitchColor;
  final Function(bool value)? onToggle;

  final BuildContext context;
  final SettingsTheme theme;

  const _IosTileTrailing({
    required this.trailing,
    required this.tileType,
    required this.value,
    required this.initialValue,
    required this.enabled,
    required this.activeSwitchColor,
    required this.onToggle,
    required this.context,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Row(
      children: [
        if (trailing != null)
          Padding(
            // TODO: move literals to file with theme constants
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconTheme(
              data: IconTheme.of(context).copyWith(
                color: enabled
                    ? theme.themeData.tileLeadingIconsColor
                    : theme.themeData.tileDisabledContentColor,
              ),
              child: trailing!,
            ),
          ),
        if (tileType == SettingsTileType.switchTile)
          CupertinoSwitch(
            value: initialValue ?? true,
            onChanged: onToggle,
            activeColor: enabled
                ? activeSwitchColor
                : theme.themeData.tileDisabledContentColor,
          ),
        if (tileType == SettingsTileType.navigationTile && value != null)
          DefaultTextStyle(
            // TODO: move literals to file with theme constants
            style: TextStyle(
              color: enabled
                  ? theme.themeData.tileTrailingTextColor
                  : theme.themeData.tileDisabledContentColor,
              fontSize: 17,
            ),
            child: value!,
          ),
        if (tileType == SettingsTileType.navigationTile)
          Padding(
            // TODO: move literals to file with theme constants
            padding: const EdgeInsetsDirectional.only(start: 6, end: 2),
            child: IconTheme(
              data: IconTheme.of(context)
                  .copyWith(color: theme.themeData.tileLeadingIconsColor),
              child: Icon(
                CupertinoIcons.chevron_forward,
                // TODO: move literals to file with theme constants
                size: 18 * scaleFactor,
              ),
            ),
          ),
      ],
    );
  }
}
