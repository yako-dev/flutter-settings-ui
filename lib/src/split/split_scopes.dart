import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/split/settings_destination.dart';
import 'package:settings_ui/src/split/settings_split_view.dart';

/// Opens a destination from a tile of a split view's list pane.
typedef SettingsDestinationOpener =
    void Function(SettingsDestination destination, Widget tileTitle);

/// Put around the list pane of a `SettingsSplitView`. Internal.
///
/// Tiles with a destination read it to select their page instead of pushing
/// it, and to draw themselves selected. Sections and tiles read [isSplit]
/// (iPad sidebar, Chrome menu, Android list pane) or [sidebar] (macOS,
/// Windows and GNOME) to switch to the list-pane look.
class SettingsSplitListScope extends InheritedWidget {
  const SettingsSplitListScope({
    super.key,
    required this.isSplit,
    required this.selectedId,
    required this.onOpen,
    this.onTileBuilt,
    this.hideLeading = false,
    bool? sidebar,
    required super.child,
  }) : sidebar = sidebar ?? isSplit;

  /// Whether the list is the list pane of two panes (not the root page of
  /// one pane).
  final bool isSplit;

  /// Whether the macOS, Windows and GNOME styles draw their sidebar rows
  /// (instead of their cards). True with two panes, and for GNOME also with
  /// one pane, where GNOME Settings shows its sidebar as the first page.
  final bool sidebar;

  /// The destination shown in the detail pane.
  final String? selectedId;

  final SettingsDestinationOpener onOpen;

  /// Called by each tile with a destination as it builds, so the split view
  /// knows the destinations of tiles in custom sections and follows their
  /// rebuilds. It must not rebuild anything synchronously.
  final SettingsDestinationOpener? onTileBuilt;

  /// Android's split list pane drops the leading icons when it's narrower
  /// than 380dp, like AOSP Settings.
  final bool hideLeading;

  static SettingsSplitListScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsSplitListScope>();

  /// Whether sections and tiles at [context] draw the sidebar rows of the
  /// macOS, Windows or GNOME style.
  static bool drawsSidebarOf(BuildContext context) =>
      maybeOf(context)?.sidebar ?? false;

  /// Whether a tile opening [destination] is drawn selected.
  bool isSelected(SettingsDestination? destination) =>
      isSplit && destination != null && destination.id == selectedId;

  @override
  bool updateShouldNotify(SettingsSplitListScope oldWidget) =>
      isSplit != oldWidget.isSplit ||
      sidebar != oldWidget.sidebar ||
      selectedId != oldWidget.selectedId ||
      hideLeading != oldWidget.hideLeading;
}

/// Put around everything a `SettingsSplitView` shows. Internal.
///
/// Destination pages read it to decide on a back button, and
/// `SettingsSplitView.maybeOf` reads the controller.
class SettingsSplitScope extends InheritedWidget {
  const SettingsSplitScope({
    super.key,
    required this.controller,
    required this.isSplit,
    required this.shownId,
    required this.hostGeneration,
    required this.goBack,
    required super.child,
  });

  final SettingsSplitController controller;
  final bool isSplit;
  final String? shownId;

  /// Counts the pages pushed over the list in one pane, so a page that is
  /// still animating out gives the detail navigator to the new one.
  final int hostGeneration;

  /// Goes back like the system back button: pops a page pushed inside the
  /// detail pane (or lets the page veto it), otherwise closes the page shown
  /// over the list in one pane.
  final VoidCallback goBack;

  static SettingsSplitScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsSplitScope>();

  @override
  bool updateShouldNotify(SettingsSplitScope oldWidget) =>
      controller != oldWidget.controller ||
      isSplit != oldWidget.isSplit ||
      shownId != oldWidget.shownId ||
      hostGeneration != oldWidget.hostGeneration;
}
