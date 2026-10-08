import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/split/sidebar_keyboard.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/tiles/tile_press.dart';

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

/// What the States of the sidebar rows share: the keyboard focus, the
/// activation and the row's line. Internal.
mixin SidebarRowState<T extends SidebarRow> on State<T> {
  bool _focusHighlight = false;

  late final SidebarRowFocus focus = SidebarRowFocus(
    debugLabel: debugLabel,
    onChanged: rebuild,
  );

  /// Enter and Space activate the row. For the row's
  /// `FocusableActionDetector`, with [focus]'s node.
  late final Map<Type, Action<Intent>> actions = tileActivateActions(
    activateRow,
  );

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
  /// of a switch row), each in [endPadding].
  Row buildLine({
    required Widget? leading,
    required TextStyle titleStyle,
    EdgeInsetsGeometry? titlePadding,
    required TextStyle trailingStyle,
    required Color? trailingIconColor,
    required EdgeInsetsGeometry endPadding,
    required Widget? toggle,
  }) {
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
