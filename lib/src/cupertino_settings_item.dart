import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

enum SettingsItemType {
  toggle,
  modal,
}

typedef void PressOperationCallback();

class CupertinoSettingsItem extends StatefulWidget {
  const CupertinoSettingsItem({
    @required this.type,
    @required this.label,
    this.labelMaxLines,
    this.subtitle,
    this.subtitleMaxLines,
    this.leading,
    this.trailing,
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
  })  : assert(label != null),
        assert(type != null),
        assert(labelMaxLines == null || labelMaxLines > 0),
        assert(subtitleMaxLines == null || subtitleMaxLines > 0);

  final String label;
  final int labelMaxLines;
  final String subtitle;
  final int subtitleMaxLines;
  final Widget leading;
  final Widget trailing;
  final SettingsItemType type;
  final String value;
  final bool hasDetails;
  final bool enabled;
  final PressOperationCallback onPress;
  final bool switchValue;
  final Function(bool value) onToggle;
  final TextStyle labelTextStyle;
  final TextStyle subtitleTextStyle;
  final TextStyle valueTextStyle;
  final Color switchActiveColor;

  @override
  State<StatefulWidget> createState() => new CupertinoSettingsItemState();
}

class CupertinoSettingsItemState extends State<CupertinoSettingsItem> {
  bool pressed = false;
  bool _checked;

  @override
  Widget build(BuildContext context) {
    _checked = widget.switchValue;

    final ThemeData theme = Theme.of(context);
    final ListTileTheme tileTheme = ListTileTheme.of(context);
    IconThemeData iconThemeData;
    if (widget.leading != null)
      iconThemeData = IconThemeData(
        color: widget.enabled
            ? _iconColor(theme, tileTheme)
            : CupertinoColors.inactiveGray,
      );

    Widget leadingIcon;
    if (widget.leading != null) {
      leadingIcon = IconTheme.merge(
        data: iconThemeData,
        child: widget.leading,
      );
    }

    List<Widget> rowChildren = [];
    if (leadingIcon != null) {
      rowChildren.add(
        Padding(
          padding: const EdgeInsets.only(
            left: 15.0,
            bottom: 2.0,
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
          maxLines: widget.labelMaxLines,
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
            maxLines: widget.labelMaxLines,
            overflow: TextOverflow.ellipsis,
            style: widget.labelTextStyle,
          ),
          const Padding(padding: EdgeInsets.only(top: 4.0)),
          Text(
            widget.subtitle,
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
          padding: const EdgeInsets.only(
            left: 15.0,
          ),
          child: titleSection,
        ),
      ),
    );

    switch (widget.type) {
      case SettingsItemType.toggle:
        rowChildren.add(
          Padding(
            padding: const EdgeInsets.only(right: 11.0),
            child: CupertinoSwitch(
              value: widget.switchValue,
              activeColor: widget.enabled
                  ? (widget.switchActiveColor ?? Theme.of(context).accentColor)
                  : CupertinoColors.inactiveGray,
              onChanged: !widget.enabled
                  ? null
                  : (bool value) {
                      widget.onToggle(value);
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
              padding: const EdgeInsets.only(
                top: 1.5,
                right: 2.25,
              ),
              child: Text(
                widget.value,
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
              padding: const EdgeInsets.only(
                top: 0.5,
                left: 2.25,
              ),
              child: widget.trailing,
            ),
          );
        } else {
          rightRowChildren.add(
            Padding(
              padding: const EdgeInsets.only(
                top: 0.5,
                left: 2.25,
              ),
              child: Icon(
                CupertinoIcons.forward,
                color: mediumGrayColor,
                size: 21.0,
              ),
            ),
          );
        }

        rightRowChildren.add(Padding(
          padding: const EdgeInsets.only(right: 8.5),
        ));

        rowChildren.add(
          Row(
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
            widget.onPress();
          }

          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                pressed = false;
              });
            }
          });
        }
        if (widget.type == SettingsItemType.toggle && mounted) {
          setState(() {
            _checked = !_checked;
            widget.onToggle(_checked);
          });
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
        color: calculateBackgroundColor(context),
        height: widget.subtitle == null ? 44.0 : 57.0,
        child: Row(
          children: rowChildren,
        ),
      ),
    );
  }

  Color calculateBackgroundColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      if (pressed) {
        return iosPressedTileColorLight;
      } else {
        return Colors.white;
      }
    } else {
      if (pressed) {
        return iosPressedTileColorDark;
      } else {
        return iosTileDarkColor;
      }
    }
  }

  Color _iconColor(ThemeData theme, ListTileTheme tileTheme) {
    if (tileTheme?.selectedColor != null) return tileTheme.selectedColor;

    if (tileTheme?.iconColor != null) return tileTheme.iconColor;

    switch (theme.brightness) {
      case Brightness.light:
        return Colors.black45;
      case Brightness.dark:
        return null; // null - use current icon theme color
    }
    assert(theme.brightness != null);
    return null;
  }
}
