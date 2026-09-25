part of 'settings_split_view.dart';

/// How a [SettingsSplitView] arranges its list and pages.
enum SettingsSplitLayout {
  /// Two panes when the window is wide enough for the style, one otherwise.
  /// See [SettingsSplitView.breakpoint].
  auto,

  /// Always one pane: the list, with pages pushed over it.
  single,

  /// Always two panes, the list pane taking at most half the width.
  split,
}

/// Reads and changes the page a [SettingsSplitView] shows.
///
/// Pass it to [SettingsSplitView.controller], or get the view's controller
/// from inside it with [SettingsSplitView.of]. It notifies its listeners
/// after [selectedId] or [isSplit] change.
///
/// ```dart
/// final controller = SettingsSplitController();
///
/// // A deep link, before or after the view is built:
/// controller.select('display');
/// ```
class SettingsSplitController extends ChangeNotifier {
  _SettingsSplitViewState? _view;
  String? _pendingId;

  /// The id of the destination shown: in the detail pane with two panes, or
  /// over the list with one pane. Null when one pane shows the list, or two
  /// panes show an empty detail pane.
  String? get selectedId => _view != null ? _view!._shownId : _pendingId;

  /// Whether the view shows two panes.
  bool get isSplit => _view?._isSplit ?? false;

  /// Shows the destination with [id], like a tap on its tile: in the detail
  /// pane with two panes, pushed over the list with one.
  ///
  /// [id] must belong to a tile in the view's sections (or to a tile in a
  /// [CustomSettingsSection] that was already tapped). Called before the view
  /// is built, it picks the first page shown, also in one pane, which suits
  /// deep links. Selecting the page already shown pops the pages pushed
  /// inside the detail pane.
  void select(String id) {
    final view = _view;
    if (view == null) {
      _pendingId = id;
      return;
    }
    view._select(id);
  }

  /// Drops the page the user picked: two panes go back to
  /// [SettingsSplitView.initialDestinationId] (or the empty detail pane), one
  /// pane back to the list.
  void clearSelection() {
    final view = _view;
    if (view == null) {
      _pendingId = null;
      return;
    }
    view._clearSelection();
  }

  void _attach(_SettingsSplitViewState view) {
    assert(
      _view == null || _view == view,
      'A SettingsSplitController can only be used by one SettingsSplitView '
      'at a time.',
    );
    _view = view;
  }

  void _detach(_SettingsSplitViewState view) {
    if (_view == view) _view = null;
  }

  String? _takePendingId() {
    final id = _pendingId;
    _pendingId = null;
    return id;
  }

  void _notify() => notifyListeners();
}
