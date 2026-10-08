import 'package:flutter/gestures.dart' show PointerDeviceKind, computeHitSlop;
import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/split/sidebar_keyboard.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';

/// A row of a desktop sidebar: a tile in the list pane of a macOS, Windows
/// or GNOME style split view. Each style draws its own. Internal.
abstract class SidebarRow extends StatefulWidget {
  const SidebarRow({
    super.key,
    required this.tileType,
    required this.leading,
    required this.title,
    required this.trailing,
    required this.onPressed,
    required this.onToggle,
    required this.initialValue,
    required this.activeSwitchColor,
    required this.enabled,
    required this.selected,
    this.semanticsSelected,
  });

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget title;
  final Widget? trailing;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final bool initialValue;
  final Color? activeSwitchColor;
  final bool enabled;
  final bool selected;

  /// Whether assistive technologies hear the row as selected: null for rows
  /// that don't open a page, and in GNOME's one-pane sidebar.
  final bool? semanticsSelected;
}

/// The keyboard focus and the activation of a [SidebarRow], for its State.
/// Internal.
mixin SidebarRowState<T extends SidebarRow> on State<T> {
  bool _focusHighlight = false;

  late final SidebarRowFocus focus = SidebarRowFocus(
    debugLabel: debugLabel,
    onChanged: rebuild,
  );

  /// Enter and Space activate the row. For the row's
  /// `FocusableActionDetector`, with [focus]'s node.
  late final Map<Type, Action<Intent>> actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => activateRow(),
    ),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) => activateRow(),
    ),
  };

  /// Names the row's focus node.
  String get debugLabel;

  /// Does what a click on the row does, if it does anything now.
  void activateRow();

  bool get isSwitch => widget.tileType == SettingsTileType.switchTile;

  /// Whether the row shows its focus ring (see [SidebarRowFocus]).
  bool get showsFocusRing => focus.showsRing(_focusHighlight);

  void rebuild() {
    if (mounted) setState(() {});
  }

  /// A click or a tap: the row takes the focus and activates.
  void handleTap() {
    focus.focusFromPointer();
    activateRow();
  }

  /// For the `onShowFocusHighlight` of the row's `FocusableActionDetector`.
  void handleFocusHighlight(bool value) {
    if (value != _focusHighlight) setState(() => _focusHighlight = value);
  }

  /// The row's line: [leading] (the icon, where the style puts it), the
  /// title on one line, then the trailing widget and [toggle] (the switch
  /// of a switch row), each in [endPadding]. With [leadingOnly], nothing
  /// after [leading].
  Widget buildLine({
    required Widget? leading,
    required TextStyle titleStyle,
    EdgeInsetsGeometry? titlePadding,
    required TextStyle trailingStyle,
    required Color? trailingIconColor,
    required EdgeInsetsGeometry endPadding,
    required Widget? toggle,
    bool leadingOnly = false,
  }) {
    if (leadingOnly) return Row(children: [?leading]);
    final trailing = widget.trailing;
    final title = DefaultTextStyle(
      style: titleStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: widget.title,
    );
    return Row(
      children: [
        ?leading,
        Expanded(
          child: titlePadding == null
              ? title
              : Padding(padding: titlePadding, child: title),
        ),
        if (trailing != null)
          Padding(
            padding: endPadding,
            child: IconTheme.merge(
              data: IconThemeData(color: trailingIconColor, size: 16),
              child: DefaultTextStyle(style: trailingStyle, child: trailing),
            ),
          ),
        if (toggle != null) Padding(padding: endPadding, child: toggle),
      ],
    );
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }
}

/// The pressed state of a sidebar row, from raw pointer events: it starts as
/// soon as a pointer goes down, and ends when the pointer goes up, leaves
/// the row or starts to scroll the sidebar. Internal.
///
/// The row decides which pointers press it and calls [start]; a `Listener`
/// around the row sends the pointer's later events here.
class SidebarRowPress {
  SidebarRowPress(this._row, {required this.onChanged});

  final State _row;

  /// Rebuilds the row.
  final VoidCallback onChanged;

  bool get pressed => _pressed;
  bool _pressed = false;

  /// The pointer that pressed the row, while it is down.
  int? _pointer;
  Offset _origin = Offset.zero;

  /// Whether a pointer is pressing the row.
  bool get hasPointer => _pointer != null;

  /// [event] presses the row.
  void start(PointerDownEvent event) {
    _pointer = event.pointer;
    _origin = event.position;
    _setPressed(true);
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer) return;
    final box = _row.context.findRenderObject()! as RenderBox;
    final inside = box.size.contains(box.globalToLocal(event.position));
    // A finger that moves past the slop is scrolling the sidebar, which
    // takes the gesture (GTK drops `:active` then too). A mouse stays
    // pressed until it leaves the row.
    final scrolling =
        event.kind != PointerDeviceKind.mouse &&
        (event.position - _origin).distance > computeHitSlop(event.kind, null);
    if (!inside || scrolling) release();
  }

  void handlePointerEnd(PointerEvent event) {
    if (event.pointer == _pointer) release();
  }

  void release() {
    _pointer = null;
    _setPressed(false);
  }

  /// Forgets the press without [onChanged], for a row that is rebuilding.
  void reset() {
    _pointer = null;
    _pressed = false;
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    _pressed = value;
    onChanged();
  }
}
