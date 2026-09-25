import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show ThemeData;
import 'package:settings_ui/src/utils/fluent_tokens.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

// WinUI 3 ToggleSwitch (ToggleSwitch_themeresources.xaml). All sizes are in
// effective pixels.
const double _kTrackWidth = 40;
const double _kTrackHeight = 20;

/// The knob sits in a 20x20 cell that moves 20 to the right when on.
const double _kCell = 20;
const double _kTravel = 20;

const double _kKnobRest = 12;
const double _kKnobHover = 14;
const double _kKnobPressedWidth = 17;
const double _kKnobPressedHeight = 14;

/// While pressed, the knob stretches toward the middle from 3 px inside its
/// end of the track.
const double _kKnobPressedInset = 3;

/// The focus visual surrounds the switch area (the track plus 5 above and
/// below) with FocusVisualMargin -7,-3,-7,-3.
const EdgeInsets _kFocusArea = EdgeInsets.symmetric(horizontal: 4, vertical: 5);

/// An on/off switch that looks and moves like the Windows 11 (WinUI 3)
/// `ToggleSwitch`.
///
/// It is a 40x20 track with a round knob:
///
///  * OFF: an outlined track with a dark (light in dark mode) 12px knob.
///  * ON: a track filled with the accent color and a white (black in dark
///    mode) knob.
///  * Hovering grows the knob to 14px; pressing stretches it to 17x14 toward
///    the middle. Hovered and pressed ON tracks show the accent at 90% and
///    80%.
///  * Dragging moves the knob with the pointer. Letting go past the middle
///    sets the value.
///  * Space and Enter toggle it when it has keyboard focus, and keyboard
///    focus draws the Windows focus rectangle around it.
///
/// Everything is painted in Flutter. The widget takes 40x20 of layout space.
/// The keyboard focus rectangle paints outside it (7 px to the sides and
/// 8 px above and below), so do not clip it tightly.
///
/// The switch does not keep its own state. [onChanged] is called with the
/// new value, and the parent rebuilds it with that value. If [onChanged] is
/// null, the switch is disabled and uses the Windows disabled colors (or
/// `SettingsThemeData.inactiveSwitchColor` inside a settings list).
///
/// Light or dark: inside a `SettingsList` it follows the card color;
/// elsewhere it follows the app theme.
class FluentSettingsSwitch extends StatefulWidget {
  /// Creates a Windows 11 style switch.
  const FluentSettingsSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeTrackColor,
    this.inactiveTrackColor,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called with the new value when the user toggles the switch.
  ///
  /// If null, the switch is disabled.
  final ValueChanged<bool>? onChanged;

  /// The fill of the track when the switch is on.
  ///
  /// Defaults to the default Windows 11 accent as Settings shows it:
  /// `#0067C0` in light mode and `#4CC2FF` in dark mode. The knob turns
  /// white or black, whichever contrasts with it.
  final Color? activeTrackColor;

  /// The outline of the track and the color of the knob when the switch is
  /// off.
  ///
  /// Defaults to the Windows strong stroke and secondary text colors.
  final Color? inactiveTrackColor;

  @override
  State<FluentSettingsSwitch> createState() => _FluentSettingsSwitchState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagProperty('value', value: value, ifTrue: 'on', ifFalse: 'off'),
    );
    properties.add(
      ObjectFlagProperty<ValueChanged<bool>>(
        'onChanged',
        onChanged,
        ifNull: 'disabled',
      ),
    );
    properties.add(ColorProperty('activeTrackColor', activeTrackColor));
    properties.add(ColorProperty('inactiveTrackColor', inactiveTrackColor));
  }
}

class _FluentSettingsSwitchState extends State<FluentSettingsSwitch>
    with TickerProviderStateMixin {
  /// Knob offset: 0 = OFF, 1 = ON.
  late final AnimationController _position = AnimationController(
    vsync: this,
    duration: kFluentNormalDuration,
    value: widget.value ? 1 : 0,
  );

  /// Cross-fade between the OFF look and the ON look.
  late final AnimationController _on = AnimationController(
    vsync: this,
    duration: kFluentFasterDuration,
    value: widget.value ? 1 : 0,
  );

  late final AnimationController _hover = AnimationController(
    vsync: this,
    duration: kFluentFasterDuration,
  );

  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: kFluentFasterDuration,
  );

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _toggle()),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) => _toggle(),
    ),
  };

  bool _reduceMotion = false;
  bool _focusHighlight = false;
  bool _hovering = false;
  bool _dragging = false;

  /// The pointer that pressed the switch, while it is down.
  int? _pressPointer;
  Offset _pressOrigin = Offset.zero;
  double _dragDownX = 0;
  double _dragStartPosition = 0;

  bool get _enabled => widget.onChanged != null;

  /// +1 in left-to-right layouts, -1 in right-to-left ones.
  double get _direction =>
      Directionality.maybeOf(context) == TextDirection.rtl ? -1 : 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  @override
  void didUpdateWidget(FluentSettingsSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animate(_on, widget.value ? 1 : 0);
      // While dragging, the pointer owns the knob. It snaps on release.
      if (!_dragging) _moveKnob(widget.value);
    }
    if (oldWidget.onChanged != null && !_enabled) {
      // Disabled mid-interaction: drop the press and drag.
      _dragging = false;
      _pressPointer = null;
      _press.value = 0;
      _hover.value = 0;
      _moveKnob(widget.value);
    } else if (oldWidget.onChanged == null && _enabled && _hovering) {
      _animate(_hover, 1);
    }
  }

  @override
  void dispose() {
    _position.dispose();
    _on.dispose();
    _hover.dispose();
    _press.dispose();
    super.dispose();
  }

  void _animate(AnimationController controller, double target) {
    if (_reduceMotion) {
      controller.value = target;
    } else {
      controller.animateTo(target);
    }
  }

  void _moveKnob(bool on) {
    final double target = on ? 1 : 0;
    if (_reduceMotion) {
      _position.value = target;
    } else {
      _position.animateTo(target, curve: kFluentFastOutSlowIn);
    }
  }

  void _setPressed(bool pressed) => _animate(_press, pressed ? 1 : 0);

  void _toggle() {
    if (!_enabled) return;
    widget.onChanged!(!widget.value);
  }

  // Pointer: the pressed look follows the pointer like WinUI, from the
  // moment it goes down, not after the tap is recognized.

  void _handlePointerDown(PointerDownEvent event) {
    if (!_enabled || _pressPointer != null) return;
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons != kPrimaryMouseButton) {
      return;
    }
    _pressPointer = event.pointer;
    _pressOrigin = event.position;
    _setPressed(true);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pressPointer || _dragging) return;
    // A scroll that started on the switch is not a press.
    final double slop = computeHitSlop(event.kind, null);
    if ((event.position.dy - _pressOrigin.dy).abs() > slop) {
      _releasePointer(event.pointer);
    }
  }

  void _handlePointerEnd(PointerEvent event) => _releasePointer(event.pointer);

  void _releasePointer(int pointer) {
    if (pointer != _pressPointer) return;
    _pressPointer = null;
    if (!_dragging) _setPressed(false);
  }

  // Dragging.

  void _handleDragDown(DragDownDetails details) {
    _dragDownX = details.localPosition.dx;
  }

  void _handleDragStart(DragStartDetails details) {
    _dragging = true;
    _dragStartPosition = _position.value;
    _position.stop();
    _setPressed(true);
    _followPointer(details.localPosition.dx);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_dragging) _followPointer(details.localPosition.dx);
  }

  /// Moves the knob with the pointer, measured from where it went down, so
  /// the knob does not lag behind by the drag slop.
  void _followPointer(double x) {
    final double delta = _direction * (x - _dragDownX);
    _position.value = (_dragStartPosition + delta / _kTravel).clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) => _finishDrag();

  void _handleDragCancel() => _finishDrag();

  void _finishDrag() {
    if (!_dragging) return;
    _dragging = false;
    if (_pressPointer == null) _setPressed(false);
    final bool value = _position.value >= 0.5;
    if (value != widget.value) {
      widget.onChanged?.call(value);
    }
    _moveKnob(value);
    // If the parent does not take the new value, go back to the old one.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_dragging) _moveKnob(widget.value);
    });
  }

  void _handleHover(bool hovering) {
    if (hovering == _hovering) return;
    _hovering = hovering;
    _animate(_hover, hovering && _enabled ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final FluentTokens tokens = FluentTokens.of(
      FluentTokens.brightnessOf(context),
    );
    final Color? themeDisabled = context
        .dependOnInheritedWidgetOfExactType<SettingsTheme>()
        ?.themeData
        .inactiveSwitchColor;
    final Color accent = widget.activeTrackColor ?? tokens.accent;

    final _SwitchColors colors = _enabled
        ? _SwitchColors(
            offFill: tokens.switchOffFill,
            offFillHover: tokens.switchOffFillHover,
            offFillPressed: tokens.switchOffFillPressed,
            offStroke: widget.inactiveTrackColor ?? tokens.switchOffStroke,
            offKnob: widget.inactiveTrackColor ?? tokens.switchOffKnob,
            onFill: accent,
            onKnob:
                ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF000000),
          )
        : _SwitchColors(
            offFill: const Color(0x00000000),
            offFillHover: const Color(0x00000000),
            offFillPressed: const Color(0x00000000),
            offStroke: themeDisabled ?? tokens.switchOffStrokeDisabled,
            offKnob: themeDisabled ?? tokens.switchOffKnobDisabled,
            onFill: themeDisabled ?? tokens.switchOnDisabled,
            onKnob: tokens.switchOnKnobDisabled,
          );

    return Semantics(
      container: true,
      toggled: widget.value,
      enabled: _enabled,
      onTap: _enabled ? _toggle : null,
      child: FocusableActionDetector(
        enabled: _enabled,
        actions: _actions,
        onShowFocusHighlight: (bool value) {
          if (value != _focusHighlight) {
            setState(() => _focusHighlight = value);
          }
        },
        mouseCursor: _enabled && kIsWeb
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        child: MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: Listener(
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerEnd,
            onPointerCancel: _handlePointerEnd,
            child: GestureDetector(
              excludeFromSemantics: true,
              behavior: HitTestBehavior.opaque,
              onTap: _enabled ? _toggle : null,
              onHorizontalDragDown: _enabled ? _handleDragDown : null,
              onHorizontalDragStart: _enabled ? _handleDragStart : null,
              onHorizontalDragUpdate: _enabled ? _handleDragUpdate : null,
              onHorizontalDragEnd: _enabled ? _handleDragEnd : null,
              onHorizontalDragCancel: _enabled ? _handleDragCancel : null,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: const Size(_kTrackWidth, _kTrackHeight),
                  painter: _FluentSwitchPainter(
                    position: _position,
                    on: _on,
                    hover: _hover,
                    press: _press,
                    enabled: _enabled,
                    colors: colors,
                    textDirection:
                        Directionality.maybeOf(context) ?? TextDirection.ltr,
                    focusTokens: _focusHighlight && _enabled ? tokens : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _SwitchColors {
  const _SwitchColors({
    required this.offFill,
    required this.offFillHover,
    required this.offFillPressed,
    required this.offStroke,
    required this.offKnob,
    required this.onFill,
    required this.onKnob,
  });

  final Color offFill;
  final Color offFillHover;
  final Color offFillPressed;
  final Color offStroke;
  final Color offKnob;
  final Color onFill;
  final Color onKnob;

  @override
  bool operator ==(Object other) =>
      other is _SwitchColors &&
      other.offFill == offFill &&
      other.offFillHover == offFillHover &&
      other.offFillPressed == offFillPressed &&
      other.offStroke == offStroke &&
      other.offKnob == offKnob &&
      other.onFill == onFill &&
      other.onKnob == onKnob;

  @override
  int get hashCode => Object.hash(
    offFill,
    offFillHover,
    offFillPressed,
    offStroke,
    offKnob,
    onFill,
    onKnob,
  );
}

class _FluentSwitchPainter extends CustomPainter {
  _FluentSwitchPainter({
    required this.position,
    required this.on,
    required this.hover,
    required this.press,
    required this.enabled,
    required this.colors,
    required this.textDirection,
    required this.focusTokens,
  }) : super(repaint: Listenable.merge([position, on, hover, press]));

  final Animation<double> position;
  final Animation<double> on;
  final Animation<double> hover;
  final Animation<double> press;
  final bool enabled;
  final _SwitchColors colors;
  final TextDirection textDirection;
  final FluentTokens? focusTokens;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect track = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: _kTrackWidth,
      height: _kTrackHeight,
    );

    canvas.save();
    // Right-to-left layouts mirror the switch, like FlowDirection does.
    if (textDirection == TextDirection.rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    final double hoverT = enabled ? hover.value : 0;
    final double pressT = enabled ? press.value : 0;
    final double onT = on.value.clamp(0.0, 1.0);
    final RRect trackShape = RRect.fromRectAndRadius(
      track,
      const Radius.circular(_kTrackHeight / 2),
    );

    // OFF look: a faint fill with a 1 px outline inside the track. It stays
    // under the ON fill, as in the WinUI template.
    final Color offFill = Color.lerp(
      Color.lerp(colors.offFill, colors.offFillHover, hoverT),
      colors.offFillPressed,
      pressT,
    )!;
    canvas.drawRRect(trackShape, Paint()..color = offFill);
    canvas.drawRRect(
      trackShape.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = colors.offStroke,
    );

    // ON look: the accent, at 90% while hovered and 80% while pressed.
    if (onT > 0) {
      final double opacity = enabled
          ? lerpDouble(lerpDouble(1, 0.9, hoverT), 0.8, pressT)!
          : 1;
      canvas.drawRRect(
        trackShape,
        Paint()..color = _fade(colors.onFill, opacity * onT),
      );
    }

    // The knob grows with the (curved) hover and press states.
    final double hoverSize = kFluentFastOutSlowIn.transform(hoverT);
    final double pressSize = kFluentFastOutSlowIn.transform(pressT);
    final double rest = lerpDouble(_kKnobRest, _kKnobHover, hoverSize)!;
    final double width = lerpDouble(rest, _kKnobPressedWidth, pressSize)!;
    final double height = lerpDouble(rest, _kKnobPressedHeight, pressSize)!;
    final double pressedCenter = lerpDouble(
      _kKnobPressedInset + width / 2,
      _kCell - _kKnobPressedInset - width / 2,
      onT,
    )!;
    final double cellCenter = lerpDouble(_kCell / 2, pressedCenter, pressSize)!;
    final Rect knob = Rect.fromCenter(
      center: Offset(
        track.left + cellCenter + position.value * _kTravel,
        track.center.dy,
      ),
      width: width,
      height: height,
    );
    final RRect knobShape = RRect.fromRectAndRadius(
      knob,
      Radius.circular(height / 2),
    );
    if (onT < 1) {
      canvas.drawRRect(
        knobShape,
        Paint()..color = _fade(colors.offKnob, 1 - onT),
      );
    }
    if (onT > 0) {
      canvas.drawRRect(knobShape, Paint()..color = _fade(colors.onKnob, onT));
    }

    if (focusTokens != null) {
      paintFluentFocusRing(
        canvas,
        _kFocusArea.inflateRect(track),
        4,
        focusTokens!,
      );
    }
    canvas.restore();
  }

  static Color _fade(Color color, double opacity) =>
      color.withValues(alpha: color.a * opacity);

  @override
  bool shouldRepaint(_FluentSwitchPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.on != on ||
        oldDelegate.hover != hover ||
        oldDelegate.press != press ||
        oldDelegate.enabled != enabled ||
        oldDelegate.colors != colors ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.focusTokens != focusTokens;
  }
}
