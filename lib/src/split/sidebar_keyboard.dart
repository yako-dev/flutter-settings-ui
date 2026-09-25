import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Moves the keyboard focus to the sidebar row above or below. Internal.
class SidebarMoveFocusIntent extends Intent {
  const SidebarMoveFocusIntent(this.direction);

  final TraversalDirection direction;
}

/// Selects the focused sidebar row, if it opens a page. Sidebar rows
/// handle it; [SettingsSidebarKeyboard] sends it after an arrow key when
/// the selection follows the focus. Internal.
class SidebarSelectIntent extends Intent {
  const SidebarSelectIntent();
}

/// Keyboard navigation in a sidebar of the macOS, Windows or GNOME style.
/// Internal.
///
/// Tab and Shift+Tab move through the rows (each row takes the focus), and
/// Enter or Space selects the focused one, as everywhere. Up and down move
/// the focus to the row above or below; on the web, where the arrow keys
/// scroll by default, too. With [selectionFollowsFocus] (the macOS sidebar,
/// an `NSTableView`) they also select that row, like the arrow keys in
/// System Settings.
class SettingsSidebarKeyboard extends StatelessWidget {
  const SettingsSidebarKeyboard({
    super.key,
    this.enabled = true,
    this.selectionFollowsFocus = false,
    required this.child,
  });

  /// False keeps the widget (so the tree below keeps its shape) without
  /// the arrow keys.
  final bool enabled;
  final bool selectionFollowsFocus;
  final Widget child;

  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp): SidebarMoveFocusIntent(
          TraversalDirection.up,
        ),
        SingleActivator(LogicalKeyboardKey.arrowDown): SidebarMoveFocusIntent(
          TraversalDirection.down,
        ),
      };

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: enabled ? _shortcuts : const <ShortcutActivator, Intent>{},
      child: Actions(
        actions: <Type, Action<Intent>>{
          SidebarMoveFocusIntent: _MoveFocusAction(selectionFollowsFocus),
        },
        child: FocusTraversalGroup(child: child),
      ),
    );
  }
}

class _MoveFocusAction extends Action<SidebarMoveFocusIntent> {
  _MoveFocusAction(this.selectionFollowsFocus);

  final bool selectionFollowsFocus;

  @override
  Object? invoke(SidebarMoveFocusIntent intent) {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null) return null;
    final moved = focus.focusInDirection(intent.direction);
    if (moved && selectionFollowsFocus) {
      // The focus moves in a microtask; select once it has.
      scheduleMicrotask(() {
        final context = FocusManager.instance.primaryFocus?.context;
        if (context != null && context.mounted) {
          Actions.maybeInvoke(context, const SidebarSelectIntent());
        }
      });
    }
    return null;
  }
}
