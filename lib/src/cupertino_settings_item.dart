import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'defines.dart';

enum SettingsItemType {
  toggle,
  modal,
}

typedef void PressOperationCallback();

class CupertinoSettingsItem extends StatefulWidget {
  const CupertinoSettingsItem({
    required this.type,
    required this.label,
    this.labelMaxLines,
    this.subtitle,
    this.subtitleMaxLines,
    this.leading,
    this.trailing,
    this.iosChevron = defaultCupertinoForwardIcon,
    this.iosChevronPadding = defaultCupertinoForwardPadding,
    this.value,
    this.hasDetails = false,
    this.enabled = true,
    this.onPress,
    this.switchValue = false,
    this.onToggle,
    this.labelTextStyle,
    this.subtitleTextStyle,
    this.valueTextStyle,
    this.switchActiveColor,
  })  : assert(labelMaxLines == null || labelMaxLines > 0),
        assert(subtitleMaxLines == null || subtitleMaxLines > 0);

  final String label;
  final int? labelMaxLines;
  final String? subtitle;
  final int? subtitleMaxLines;
  final Widget? leading;
  final Widget? trailing;
  final Icon? iosChevron;
  final EdgeInsetsGeometry? iosChevronPadding;
  final SettingsItemType type;
  final String? value;
  final bool hasDetails;
  final bool enabled;
  final PressOperationCallback? onPress;
  final bool? switchValue;
  final Function(bool value)? onToggle;
  final TextStyle? labelTextStyle;
  final TextStyle? subtitleTextStyle;
  final TextStyle? valueTextStyle;
  final Color? switchActiveColor;

  @override
  State<StatefulWidget> createState() => new CupertinoSettingsItemState();
}

class CupertinoSettingsItemState extends State<CupertinoSettingsItem> {
  bool pressed = false;
  bool? _checked;

  @override
  Widget build(BuildContext context) {
    _checked = widget.switchValue;

    /// The width of iPad. This is used to make circular borders on iPad and web
    final isLargeScreen = MediaQuery.of(context).size.width >= 768;

    final ThemeData theme = Theme.of(context);
    final ListTileTheme tileTheme = ListTileTheme.of(context);
    late IconThemeData iconThemeData;
    if (widget.leading != null)
      iconThemeData = IconThemeData(
        color: widget.enabled
            ? _iconColor(theme, tileTheme)
            : CupertinoColors.inactiveGray,
      );

    Widget? leadingIcon;
    if (widget.leading != null) {
      leadingIcon = IconTheme.merge(
        data: iconThemeData,
        child: widget.leading!,
      );
    }

    List<Widget> rowChildren = [];
    if (leadingIcon != null) {
      rowChildren.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 15.0,
          ),
          child: leadingIcon,
        ),
      );
    }

    Widget titleSection;
    if (widget.subtitle == null) {
      titleSection = Padding(
        padding: EdgeInsets.only(top: 1.5),
        child: Text(
          widget.label,
          overflow: TextOverflow.ellipsis,
          style: widget.labelTextStyle ??
              TextStyle(
                fontSize: 16,
                color: widget.enabled ? null : CupertinoColors.inactiveGray,
              ),
        ),
      );
    } else {
      titleSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(top: 8.5)),
          Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: widget.labelTextStyle,
          ),
          const Padding(padding: EdgeInsets.only(top: 4.0)),
          Text(
            widget.subtitle!,
            maxLines: widget.subtitleMaxLines,
            overflow: TextOverflow.ellipsis,
            style: widget.subtitleTextStyle ??
                TextStyle(
                  fontSize: 12.0,
                  letterSpacing: -0.2,
                ),
          )
        ],
      );
    }

    rowChildren.add(
      Expanded(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 15.0,
            end: 15.0,
          ),
          child: titleSection,
        ),
      ),
    );

    switch (widget.type) {
      case SettingsItemType.toggle:
        rowChildren.add(
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 11.0),
            child: CupertinoSwitch(
              value: widget.switchValue!,
              activeColor: widget.enabled
                  ? (widget.switchActiveColor ?? Theme.of(context).accentColor)
                  : CupertinoColors.inactiveGray,
              onChanged: !widget.enabled
                  ? null
                  : (bool value) {
                      widget.onToggle!(value);
                    },
            ),
          ),
        );
        break;
      case SettingsItemType.modal:
        final List<Widget> rightRowChildren = [];
        if (widget.value != null) {
          rightRowChildren.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 1.5,
                end: 2.25,
              ),
              child: Text(
                widget.value!,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: widget.valueTextStyle ??
                    TextStyle(
                      color: CupertinoColors.inactiveGray,
                      fontSize: 16,
                    ),
              ),
            ),
          );
        }

        if (widget.trailing != null) {
          rightRowChildren.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 0.5,
                start: 2.25,
              ),
              child: widget.trailing,
            ),
          );
        }

        if (widget.trailing == null && widget.iosChevron != null) {
          rightRowChildren.add(
            widget.iosChevronPadding == null
                ? widget.iosChevron!
                : Padding(
                    padding: widget.iosChevronPadding!,
                    child: widget.iosChevron,
                  ),
          );
        }

        rightRowChildren.add(const SizedBox(width: 8.5));

        rowChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: rightRowChildren,
          ),
        );

        break;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if ((widget.onPress != null || widget.onToggle != null) &&
            widget.enabled) {
          if (mounted) {
            setState(() {
              pressed = true;
            });
          }

          if (widget.onPress != null) {
            widget.onPress!();
          }

          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                pressed = false;
              });
            }
          });
        }

        if (widget.type == SettingsItemType.toggle && widget.enabled) {
          if (mounted) {
            setState(() {
              _checked = !_checked!;
              widget.onToggle!(_checked!);
            });
          }
        }
      },
      onTapUp: (_) {
        if (widget.enabled && mounted) {
          setState(() {
            pressed = false;
          });
        }
      },
      onTapDown: (_) {
        if (widget.enabled && mounted) {
          setState(() {
            pressed = true;
          });
        }
      },
      onTapCancel: () {
        if (widget.enabled && mounted) {
          setState(() {
            pressed = false;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              isLargeScreen ? BorderRadius.all(Radius.circular(20)) : null,
          color: calculateBackgroundColor(context),
        ),
        height: widget.subtitle == null ? 44.0 : 57.0,
        child: Row(
          children: rowChildren,
        ),
      ),
    );
  }

  Color calculateBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? pressed
              ? iosPressedTileColorLight
              : Colors.white
          : pressed
              ? iosPressedTileColorDark
              : iosTileDarkColor;

  Color? _iconColor(ThemeData theme, ListTileTheme tileTheme) {
    if (tileTheme.selectedColor != null) {
      return tileTheme.selectedColor;
    }

    if (tileTheme.iconColor != null) {
      return tileTheme.iconColor;
    }

    switch (theme.brightness) {
      case Brightness.light:
        return Colors.black45;
      case Brightness.dark:
        return null; // null - use current icon theme color
    }
  }
}
