import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/split/settings_destination.dart';
import 'package:settings_ui/src/split/settings_split_view.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';

/// Opens a destination from a tile of a split view's list pane.
typedef SettingsDestinationOpener =
    void Function(SettingsDestination destination, Widget tileTitle);

/// Put around the list pane of a `SettingsSplitView`. Internal.
///
/// Tiles with a destination read it to select their page instead of pushing
/// it, and to draw themselves selected. Sections and tiles read [isSplit] to
/// switch to the list-pane look (iPad sidebar, Chrome menu).
class SettingsSplitListScope extends InheritedWidget {
  const SettingsSplitListScope({
    super.key,
    required this.isSplit,
    required this.selectedId,
    required this.onOpen,
    this.hideLeading = false,
    required super.child,
  });

  /// Whether the list is the list pane of two panes (not the root page of
  /// one pane).
  final bool isSplit;

  /// The destination shown in the detail pane.
  final String? selectedId;

  final SettingsDestinationOpener onOpen;

  /// Android's split list pane drops the leading icons when it's narrower
  /// than 380dp, like AOSP Settings.
  final bool hideLeading;

  static SettingsSplitListScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsSplitListScope>();

  /// The style that sections and tiles at [context] draw in, for a list in
  /// the [platform] style.
  ///
  /// The macOS, Windows and GNOME styles have no sidebar look of their own
  /// yet. In the list pane of two panes, macOS and Windows draw iPad sidebar
  /// rows (no cards, a filled selected row) and GNOME the Android homepage
  /// cards (which keep the tiles' descriptions), in the style's own colors.
  /// Everywhere else this is [platform].
  static DevicePlatform tilePlatformOf(
    BuildContext context,
    DevicePlatform platform,
  ) {
    switch (platform) {
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        final isSplit = maybeOf(context)?.isSplit ?? false;
        return isSplit ? DevicePlatform.iOS : platform;
      case DevicePlatform.linux:
        final isSplit = maybeOf(context)?.isSplit ?? false;
        return isSplit ? DevicePlatform.android : platform;
      case DevicePlatform.iOS:
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.web:
      case DevicePlatform.device:
        return platform;
    }
  }

  /// Whether a tile opening [destination] is drawn selected.
  bool isSelected(SettingsDestination? destination) =>
      isSplit && destination != null && destination.id == selectedId;

  @override
  bool updateShouldNotify(SettingsSplitListScope oldWidget) =>
      isSplit != oldWidget.isSplit ||
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
