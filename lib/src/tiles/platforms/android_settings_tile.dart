import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class AndroidSettingsTile extends StatefulWidget {
  const AndroidSettingsTile({
    required this.tileType,
    required this.leading,
    required this.title,
    required this.description,
    required this.onPressed,
    required this.onToggle,
    required this.value,
    required this.initialValue,
    required this.activeSwitchColor,
    required this.enabled,
    required this.trailing,
    required this.expandDuration,
    required this.contractDuration,
    required this.expandCurve,
    required this.contractCurve,
    required this.builder,
    Key? key,
  }) : super(key: key);

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget? title;
  final Widget? description;
  final Function(BuildContext context)? onPressed;
  final Duration expandDuration;
  final Duration contractDuration;
  final Curve expandCurve;
  final Curve contractCurve;
  final Widget Function(VoidCallback close)? builder;
  final Function(bool value)? onToggle;
  final Widget? value;
  final bool initialValue;
  final bool enabled;
  final Color? activeSwitchColor;
  final Widget? trailing;

  @override
  State<AndroidSettingsTile> createState() => _AndroidSettingsTileState();
}

class _AndroidSettingsTileState extends State<AndroidSettingsTile>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  bool get isExpanding =>
      animation.status == AnimationStatus.forward ||
      animation.status == AnimationStatus.completed;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: widget.expandDuration,
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: widget.expandCurve,
    );
  }

  expand() {
    controller.forward();
  }

  contract() {
    controller.animateBack(
      0.0,
      duration: widget.contractDuration,
      curve: widget.contractCurve,
    );
  }

  toggleContainer() {
    if (isExpanding) {
      contract();
    } else {
      expand();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context);
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    final cantShowAnimation = widget.tileType == SettingsTileType.switchTile
        ? widget.onToggle == null && widget.onPressed == null
        : widget.onPressed == null &&
            widget.tileType != SettingsTileType.expandableTile;

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Column(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: cantShowAnimation
                  ? null
                  : () {
                      if (widget.tileType == SettingsTileType.switchTile) {
                        widget.onToggle?.call(!widget.initialValue);
                      } else if (widget.tileType ==
                          SettingsTileType.expandableTile) {
                        toggleContainer();
                      } else {
                        widget.onPressed?.call(context);
                      }
                    },
              highlightColor: theme.themeData.tileHighlightColor,
              child: Container(
                child: Row(
                  children: [
                    if (widget.leading != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 24),
                        child: IconTheme(
                          data: IconTheme.of(context).copyWith(
                            color: widget.enabled
                                ? theme.themeData.leadingIconsColor
                                : theme.themeData.inactiveTitleColor,
                          ),
                          child: widget.leading!,
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 24,
                          end: 24,
                          bottom: 19 * scaleFactor,
                          top: 19 * scaleFactor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DefaultTextStyle(
                              style: TextStyle(
                                color: widget.enabled
                                    ? theme.themeData.settingsTileTextColor
                                    : theme.themeData.inactiveTitleColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                              child: widget.title ?? Container(),
                            ),
                            if (widget.value != null)
                              Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: DefaultTextStyle(
                                  style: TextStyle(
                                    color: widget.enabled
                                        ? theme
                                            .themeData.tileDescriptionTextColor
                                        : theme.themeData.inactiveSubtitleColor,
                                  ),
                                  child: widget.value!,
                                ),
                              )
                            else if (widget.description != null)
                              Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: DefaultTextStyle(
                                  style: TextStyle(
                                    color: widget.enabled
                                        ? theme
                                            .themeData.tileDescriptionTextColor
                                        : theme.themeData.inactiveSubtitleColor,
                                  ),
                                  child: widget.description!,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.trailing != null &&
                        widget.tileType == SettingsTileType.switchTile)
                      Row(
                        children: [
                          widget.trailing!,
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: Switch(
                              value: widget.initialValue,
                              onChanged: widget.onToggle,
                              activeColor: widget.enabled
                                  ? widget.activeSwitchColor
                                  : theme.themeData.inactiveTitleColor,
                            ),
                          ),
                        ],
                      )
                    else if (widget.tileType == SettingsTileType.switchTile)
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.only(start: 16, end: 8),
                        child: Switch(
                          value: widget.initialValue,
                          onChanged: widget.onToggle,
                          activeColor: widget.enabled
                              ? widget.activeSwitchColor
                              : theme.themeData.inactiveTitleColor,
                        ),
                      )
                    else if (widget.trailing != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: widget.trailing!,
                      )
                    else if (widget.tileType == SettingsTileType.expandableTile)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AnimatedRotation(
                          duration: kThemeChangeDuration,
                          turns: isExpanding ? .5 : 0,
                          child: const Icon(Icons.arrow_drop_down),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
          if (widget.tileType == SettingsTileType.expandableTile)
            SizeTransition(
              sizeFactor: animation,
              axis: Axis.vertical,
              child: widget.builder!(contract),
            )
        ],
      ),
    );
  }
}
