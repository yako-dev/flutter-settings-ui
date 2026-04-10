import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class IOSSettingsTile extends StatefulWidget {
  const IOSSettingsTile({
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
    this.compact = false,
    this.titlePadding,
    this.leadingPadding,
    this.titleDescriptionPadding,
    super.key,
  });

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget? title;
  final Widget? titleDescription;
  final Widget? description;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final Widget? value;
  final bool? initialValue;
  final bool enabled;
  final bool compact;
  final Color? activeSwitchColor;
  final Widget? trailing;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? leadingPadding;
  final EdgeInsetsGeometry? titleDescriptionPadding;

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
          buildTitle(
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

  Widget buildTitle({
    required BuildContext context,
    required SettingsTheme theme,
    required IOSSettingsTileAdditionalInfo additionalInfo,
  }) {
    Widget content = buildTileContent(context, theme, additionalInfo);
    // Use the platform from SettingsTheme (respects user's explicit choice)
    // rather than re-detecting from the system, which ignored platform overrides.
    if (theme.platform != DevicePlatform.iOS) {
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
    final textScaler = MediaQuery.textScalerOf(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: textScaler.scale(8),
        bottom: additionalInfo.needToShowDivider ? 24 : textScaler.scale(8),
      ),
      decoration: BoxDecoration(
        color: theme.themeData.settingsListBackground,
      ),
      child: DefaultTextStyle(
        style: (theme.themeData.tileDescriptionTextStyle ??
                const TextStyle(fontSize: 13))
            .copyWith(color: theme.themeData.titleTextColor),
        child: widget.description!,
      ),
    );
  }

  /// Returns the non-value trailing controls (switch, trailing icon, chevron).
  /// The value widget is placed directly in the inner Row of [buildTileContent]
  /// as a [Flexible] so it can shrink without pushing the title.
  Widget buildTrailing({
    required BuildContext context,
    required SettingsTheme theme,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.trailing != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconTheme(
              data: IconTheme.of(context).copyWith(
                color: widget.enabled
                    ? theme.themeData.leadingIconsColor
                    : theme.themeData.inactiveTitleColor,
              ),
              child: widget.trailing!,
            ),
          ),
        if (widget.tileType == SettingsTileType.switchTile)
          CupertinoSwitch(
            value: widget.initialValue ?? true,
            onChanged: widget.onToggle,
            activeTrackColor: widget.enabled
                ? widget.activeSwitchColor
                : (theme.themeData.inactiveSwitchColor ??
                    theme.themeData.inactiveTitleColor),
          ),
        if (widget.tileType == SettingsTileType.navigationTile)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, end: 2),
            child: IconTheme(
              data: IconTheme.of(context)
                  .copyWith(color: theme.themeData.leadingIconsColor),
              child: Icon(
                isRTL
                    ? CupertinoIcons.chevron_back
                    : CupertinoIcons.chevron_forward,
                size: textScaler.scale(18),
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
    final textScaler = MediaQuery.textScalerOf(context);

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
                        ? theme.themeData.leadingIconsColor
                        : theme.themeData.inactiveTitleColor,
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
                                      top: textScaler
                                          .scale(widget.compact ? 6.0 : 12.5),
                                      bottom: widget.titleDescription == null
                                          ? textScaler.scale(
                                              widget.compact ? 6.0 : 12.5)
                                          : textScaler.scale(
                                              widget.compact ? 2.0 : 3.5),
                                    ),
                                child: DefaultTextStyle(
                                  style: (theme.themeData.tileTextStyle ??
                                          const TextStyle(fontSize: 16))
                                      .copyWith(
                                    color: widget.enabled
                                        ? theme.themeData.settingsTileTextColor
                                        : theme.themeData.inactiveTitleColor,
                                  ),
                                  child: widget.title!,
                                ),
                              ),
                              if (widget.titleDescription != null)
                                Padding(
                                  padding: widget.titleDescriptionPadding ??
                                      EdgeInsetsDirectional.only(
                                        bottom: textScaler.scale(12.5),
                                      ),
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                      color: widget.enabled
                                          ? theme.themeData.titleTextColor
                                          : theme.themeData.inactiveTitleColor,
                                      fontSize: 15,
                                    ),
                                    child: widget.titleDescription!,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Value is Flexible here so it can shrink without
                        // pushing the title when the text is long. (Issue #186)
                        if (widget.tileType ==
                                SettingsTileType.navigationTile &&
                            widget.value != null)
                          Flexible(
                            child: DefaultTextStyle(
                              style: TextStyle(
                                color: widget.enabled
                                    ? theme.themeData.trailingTextColor
                                    : theme.themeData.inactiveTitleColor,
                                fontSize: 17,
                              ),
                              overflow: TextOverflow.ellipsis,
                              child: widget.value!,
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
                      color: theme.themeData.dividerColor,
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
    super.key,
    required this.needToShowDivider,
    required this.enableTopBorderRadius,
    required this.enableBottomBorderRadius,
    required super.child,
  });

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
