import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'defines.dart';

enum SettingsItemType {
  toggle,
  modal,
  slider,
}

typedef void PressOperationCallback();

const _spacer = Expanded(child: SizedBox.shrink());

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
    this.sliderValue,
    this.sliderOnChanged,
    this.sliderOnChangeStart,
    this.sliderOnChangeEnd,
    this.sliderMin,
    this.sliderMax,
    this.sliderDivisions,
    this.sliderActiveColor,
    this.sliderThumbColor,
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

  /// Values for Slider
  final double? sliderValue;
  final ValueChanged<double>? sliderOnChanged;
  final ValueChanged<double>? sliderOnChangeStart;
  final ValueChanged<double>? sliderOnChangeEnd;
  final double? sliderMin;
  final double? sliderMax;
  final int? sliderDivisions;
  final Color? sliderActiveColor;
  final Color? sliderThumbColor;

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

    final iconThemeData = IconThemeData(
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
    final Widget titleSection;

    if (widget.type != SettingsItemType.slider) {
      if (widget.subtitle == null) {
        titleSection = Text(
          widget.label,
          overflow: TextOverflow.ellipsis,
          style: widget.labelTextStyle ??
              TextStyle(
                fontSize: 16,
                color: widget.enabled ? null : CupertinoColors.inactiveGray,
              ),
        );
      } else {
        titleSection = Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.label,
                overflow: TextOverflow.ellipsis,
                style: widget.labelTextStyle,
              ),
              const SizedBox(height: 2.5),
              Text(
                widget.subtitle!,
                maxLines: widget.subtitleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: widget.subtitleTextStyle ??
                    TextStyle(
                      fontSize: 16,
                      color: widget.enabled ? null : CupertinoColors.inactiveGray,
                    ),
              ),
            ]);
      }
    } else {
      titleSection = CupertinoSlider(
          value: widget.sliderValue!,
          divisions: widget.sliderDivisions,
          activeColor: widget.sliderActiveColor,
          thumbColor: widget.sliderThumbColor!,
          min: widget.sliderMin!,
          max: widget.sliderMax!,
          onChanged: widget.sliderOnChanged,
          onChangeStart: widget.sliderOnChangeStart,
          onChangeEnd: widget.sliderOnChangeEnd);

    }

    rowChildren.add(Expanded(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 15.0,
          end: 15.0,
        ),
        child: titleSection,
      ),
    ));

    switch (widget.type) {
      case SettingsItemType.slider:
        if (widget.trailing != null) {
          Widget trailingIcon = IconTheme.merge(
            data: IconThemeData(
              color: widget.enabled
                  ? _iconColor(theme, tileTheme)
                  : CupertinoColors.inactiveGray,
            ),
            child: widget.trailing!,
          );

          rowChildren.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  top: 0.5, start: 2.25, end: 11.0),
              child: trailingIcon,
            ),
          );
        }
        ;
        break;
      case SettingsItemType.toggle:
        rowChildren
          ..add(
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 11.0),
              child: CupertinoSwitch(
                value: widget.switchValue!,
                activeColor: widget.enabled
                    ? (widget.switchActiveColor ??
                    Theme.of(context).accentColor)
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
        if (widget.value == null) {
          rowChildren.add(_spacer);
        } else {
          rowChildren.add(
            Expanded(
              child: Padding(
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
            ),
          );
        }

        final List<Widget> endRowChildren = [];
        if (widget.trailing != null) {
          endRowChildren.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 0.5,
                start: 2.25,
              ),
              child: widget.trailing,
            ),
          );
        }

        final iosChevron = widget.iosChevron;
        if (widget.trailing == null && iosChevron != null) {
          endRowChildren.add(
            widget.iosChevronPadding == null
                ? iosChevron
                : Padding(
              padding: widget.iosChevronPadding!,
              child: iosChevron,
            ),
          );
        }

        endRowChildren.add(const SizedBox(width: 8.5));

        rowChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: endRowChildren,
          ),
        );
        break;
      case SettingsItemType.slider:
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