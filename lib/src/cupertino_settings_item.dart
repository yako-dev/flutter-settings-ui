import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

enum SettingsItemType {
  toggle,
  modal,
}

typedef Future<void> PressOperationCallback();

class CupertinoSettingsItem extends StatefulWidget {
  const CupertinoSettingsItem({
    @required this.type,
    @required this.label,
    this.subtitle,
    this.leading,
    this.value,
    this.hasDetails = false,
    this.onPress,
    this.switchValue = false,
    this.onToggle,
  })  : assert(label != null),
        assert(type != null);

  final String label;
  final String subtitle;
  final Widget leading;
  final SettingsItemType type;
  final String value;
  final bool hasDetails;
  final PressOperationCallback onPress;
  final bool switchValue;
  final Function(bool value) onToggle;

  @override
  State<StatefulWidget> createState() => new CupertinoSettingsItemState();
}

class CupertinoSettingsItemState extends State<CupertinoSettingsItem> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ListTileTheme tileTheme = ListTileTheme.of(context);
    IconThemeData iconThemeData;
    if (widget.leading != null)
      iconThemeData = IconThemeData(color: _iconColor(theme, tileTheme));

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
        child: Text(widget.label, style: TextStyle(fontSize: 16)),
      );
    } else {
      titleSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(top: 8.5)),
          Text(widget.label),
          const Padding(padding: EdgeInsets.only(top: 4.0)),
          Text(
            widget.subtitle,
            style: TextStyle(
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
              activeColor: Theme.of(context).accentColor,
              onChanged: (bool value) {
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
                style: TextStyle(
                    color: CupertinoColors.inactiveGray, fontSize: 16),
              ),
            ),
          );
        }

        if (widget.hasDetails) {
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
        if (widget.onPress != null) {
          widget.onPress();
        }
      },
      onTapUp: (_) {
        setState(() {
          pressed = false;
        });
      },
      onTapDown: (_) {
        setState(() {
          pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          pressed = false;
        });
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
