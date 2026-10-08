import 'package:flutter/widgets.dart';

/// What a [SidebarButton] is doing, for its builder to draw.
typedef SidebarButtonStates = ({bool hovered, bool pressed, bool focused});

/// A button of the desktop split views' bars (back, forward, pane toggle,
/// breadcrumb): a semantics button that Enter and Space activate, and its
/// hover, pressed and keyboard focus states, which [builder] draws.
/// Internal.
class SidebarButton extends StatefulWidget {
  const SidebarButton({
    super.key,
    this.semanticLabel,
    required this.onPressed,
    this.hasEnabledState = false,
    this.tracksHover = true,
    this.mouseCursor = MouseCursor.defer,
    required this.builder,
  });

  final String? semanticLabel;

  /// Null disables the button.
  final VoidCallback? onPressed;

  /// Whether the semantics say if the button is enabled: for a button that
  /// can be disabled.
  final bool hasEnabledState;

  /// False for a button that draws no hover state (the macOS capsule).
  final bool tracksHover;

  final MouseCursor mouseCursor;

  /// Draws the button in its current states.
  final Widget Function(BuildContext context, SidebarButtonStates states)
  builder;

  @override
  State<SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<SidebarButton> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focusHighlight = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => widget.onPressed?.call(),
    ),
  };

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = widget.onPressed;
    final enabled = onPressed != null;
    Widget button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onTap: onPressed,
      child: widget.builder(context, (
        hovered: _hovered,
        pressed: _pressed,
        focused: _focusHighlight,
      )),
    );
    if (widget.tracksHover) {
      button = MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: button,
      );
    }
    return Semantics(
      container: true,
      button: true,
      enabled: widget.hasEnabledState ? enabled : null,
      label: widget.semanticLabel,
      onTap: onPressed,
      child: FocusableActionDetector(
        enabled: enabled,
        actions: _actions,
        mouseCursor: widget.mouseCursor,
        onShowFocusHighlight: (value) {
          if (value != _focusHighlight) {
            setState(() => _focusHighlight = value);
          }
        },
        child: button,
      ),
    );
  }
}
