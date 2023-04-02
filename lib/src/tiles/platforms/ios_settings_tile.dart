import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

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

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Column(
        children: [
          buildTile(
            context: context,
            theme: theme,
            additionalInfo: additionalInfo,
          ),
          if (widget.description != null)
            buildDescription(
              context: context,
              theme: theme,
              additionalInfo: additionalInfo,
            ),
        ],
      ),
    );
  }

  Widget buildTile({
    required BuildContext context,
    required SettingsTheme theme,
    required IOSSettingsTileAdditionalInfo additionalInfo,
  }) {
    Widget content = buildTileContent(context, theme, additionalInfo);
    DevicePlatform platform = PlatformUtils.detectPlatform(context);
    if (platform != DevicePlatform.iOS) {
      content = Material(
        color: Colors.transparent,
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: additionalInfo.enableTopBorderRadius
            ? const Radius.circular(12)
            : Radius.zero,
        bottom: additionalInfo.enableBottomBorderRadius
            ? const Radius.circular(12)
            : Radius.zero,
      ),
      child: content,
    );
  }

  Widget buildDescription({
    required BuildContext context,
    required SettingsTheme theme,
    required IOSSettingsTileAdditionalInfo additionalInfo,
  }) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Container(
      width: MediaQuery.of(context).size.width,
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
        style: TextStyle(
          color: theme.themeData.titleTextColor,
          fontSize: 13,
        ),
        child: widget.description!,
      ),
    );
  }

  Widget buildTrailing({
    required BuildContext context,
    required SettingsTheme theme,
  }) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Row(
      children: [
        if (widget.trailing != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconTheme(
              data: IconTheme.of(context).copyWith(
                color: widget.enabled
                    ? theme.themeData.tileLeadingIconsColor
                    : theme.themeData.tileDisabledContentColor,
              ),
              child: widget.trailing!,
            ),
          ),
        if (widget.tileType == SettingsTileType.switchTile)
          CupertinoSwitch(
            value: widget.initialValue ?? true,
            onChanged: widget.onToggle,
            activeColor: widget.enabled
                ? widget.activeSwitchColor
                : theme.themeData.tileDisabledContentColor,
          ),
        if (widget.tileType == SettingsTileType.navigationTile &&
            widget.value != null)
          DefaultTextStyle(
            style: TextStyle(
              color: widget.enabled
                  ? theme.themeData.tileTrailingTextColor
                  : theme.themeData.tileDisabledContentColor,
              fontSize: 17,
            ),
            child: widget.value!,
          ),
        if (widget.tileType == SettingsTileType.navigationTile)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, end: 2),
            child: IconTheme(
              data: IconTheme.of(context)
                  .copyWith(color: theme.themeData.tileLeadingIconsColor),
              child: Icon(
                CupertinoIcons.chevron_forward,
                size: 18 * scaleFactor,
              ),
            ),
          ),
      ],
    );
  }

  void changePressState({bool isPressed = false}) {
    if (mounted) {
      setState(() {
        this.isPressed = isPressed;
      });
    }
  }

  Widget buildTileContent(
    BuildContext context,
    SettingsTheme theme,
    IOSSettingsTileAdditionalInfo additionalInfo,
  ) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onPressed == null
          ? null
          : () {
              changePressState(isPressed: true);

              widget.onPressed!.call(context);

              Future.delayed(
                const Duration(milliseconds: 100),
                () => changePressState(isPressed: false),
              );
            },
      onTapDown: (_) =>
          widget.onPressed == null ? null : changePressState(isPressed: true),
      onTapUp: (_) =>
          widget.onPressed == null ? null : changePressState(isPressed: false),
      onTapCancel: () =>
          widget.onPressed == null ? null : changePressState(isPressed: false),
      child: Container(
        key: const Key('ios_settings_tile_container'),
        color: isPressed
            ? theme.themeData.tileHighlightColor
            : theme.themeData.settingsSectionBackground,
        padding: const EdgeInsetsDirectional.only(start: 18),
        child: Row(
          children: [
            if (widget.leading != null)
              Padding(
                padding: widget.leadingPadding ??
                    const EdgeInsetsDirectional.only(end: 12.0),
                child: IconTheme.merge(
                  data: IconThemeData(
                    color: widget.enabled
                        ? theme.themeData.tileLeadingIconsColor
                        : theme.themeData.tileDisabledContentColor,
                  ),
                  child: widget.leading!,
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
                                padding: widget.titlePadding ??
                                    EdgeInsetsDirectional.only(
                                      top: 12.5 * scaleFactor,
                                      bottom: widget.subtitle == null
                                          ? (12.5 * scaleFactor)
                                          : (3.5 * scaleFactor),
                                    ),
                                child: DefaultTextStyle(
                                  style: TextStyle(
                                    color: widget.enabled
                                        ? theme.themeData.tileTitleTextColor
                                        : theme
                                            .themeData.tileDisabledContentColor,
                                    fontSize: 16,
                                  ),
                                  child: widget.title!,
                                ),
                              ),
                              if (widget.subtitle != null)
                                Padding(
                                  padding: widget.subtitlePadding ??
                                      EdgeInsetsDirectional.only(
                                        bottom: 12.5 * scaleFactor,
                                      ),
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                      color: widget.enabled
                                          ? theme.themeData.titleTextColor
                                          : theme.themeData
                                              .tileDisabledContentColor,
                                      fontSize: 15,
                                    ),
                                    child: widget.subtitle!,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        buildTrailing(context: context, theme: theme),
                      ],
                    ),
                  ),
                  if (widget.description == null &&
                      additionalInfo.needToShowDivider)
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

class IOSSettingsTileAdditionalInfo extends InheritedWidget {
  final bool needToShowDivider;
  final bool enableTopBorderRadius;
  final bool enableBottomBorderRadius;

  const IOSSettingsTileAdditionalInfo({
    Key? key,
    required this.needToShowDivider,
    required this.enableTopBorderRadius,
    required this.enableBottomBorderRadius,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(IOSSettingsTileAdditionalInfo oldWidget) => true;

  static IOSSettingsTileAdditionalInfo of(BuildContext context) {
    final IOSSettingsTileAdditionalInfo? result = context
        .dependOnInheritedWidgetOfExactType<IOSSettingsTileAdditionalInfo>();
    // assert(result != null, 'No IOSSettingsTileAdditionalInfo found in context');
    return result ??
        const IOSSettingsTileAdditionalInfo(
          needToShowDivider: true,
          enableBottomBorderRadius: true,
          enableTopBorderRadius: true,
          child: SizedBox(),
        );
  }
}
