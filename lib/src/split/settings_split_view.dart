import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/list/settings_list.dart';
import 'package:settings_ui/src/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/sections/custom_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/fluent_settings_section.dart';
import 'package:settings_ui/src/sections/settings_section.dart';
import 'package:settings_ui/src/split/adwaita_split.dart';
import 'package:settings_ui/src/split/fluent_split.dart';
import 'package:settings_ui/src/split/macos_split.dart';
import 'package:settings_ui/src/split/settings_destination.dart';
import 'package:settings_ui/src/split/settings_destination_page.dart';
import 'package:settings_ui/src/split/settings_page_header.dart';
import 'package:settings_ui/src/split/sidebar_keyboard.dart';
import 'package:settings_ui/src/split/split_geometry.dart';
import 'package:settings_ui/src/split/split_scopes.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/utils/content_column.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_style.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

part 'settings_split_controller.dart';

/// A settings screen that shows the list and the selected page side by side
/// when there is room (iPad, tablets, unfolded foldables, desktop and web),
/// and the list with pages pushed over it otherwise.
///
/// Give tiles a [SettingsDestination] (`SettingsTile.navigation(destination:
/// ...)`); tapping one shows its page. With two panes the tile stays
/// highlighted and pages opened from inside the page push inside the detail
/// pane, like iPad Settings.
///
/// The per-style defaults follow the platform apps:
///
/// | Style | Two panes when | List pane |
/// |---|---|---|
/// | iOS | width >= 600 and shortest side >= 600 (any shortest side on desktop) | 320pt sidebar |
/// | Android, Fuchsia | width >= 720 and shortest side >= 600, like AOSP Settings | 36.36% of the width |
/// | Web | width > 980, like Chrome | 266px menu |
/// | macOS | width >= 560 | 232pt System Settings sidebar |
/// | Windows | width >= 641 | 300px navigation pane from 1008, a 48px icon rail below |
/// | GNOME | width > 550 (scaled by the text size) | a quarter of the width, 180–280 |
///
/// The desktop styles draw their list pane like their platforms' settings
/// apps:
///
/// - macOS: a full-height sidebar with 32pt rows, a rounded selection in the
///   accent color (grey while the window is inactive) and small bold section
///   headers. The detail pane has a 52pt toolbar with the page title and,
///   when there is a page to go back to, the back and forward buttons.
/// - Windows: a `NavigationView` pane with a sliding accent pill on the
///   selected item. Between 641 and 1007 the pane is an icon rail with
///   tooltips; its menu button opens the full pane over the page. The page
///   title is large, and pages opened from a page show a breadcrumb.
/// - GNOME: an `AdwNavigationSplitView` sidebar with rounded rows and its
///   own header bar. The detail pane has a flat header bar with a centered
///   title, and a back button when collapsed or on a nested page. With one
///   pane no row stays selected.
///
/// In the three desktop styles the arrow keys move between the sidebar's
/// rows, Enter or Space opens one (macOS opens the row as the focus moves,
/// like its sidebars), and Tab moves between the panes.
///
/// A separating hinge (a hinge, or a fold in the book posture) always gets a
/// pane on each side of it. The panes follow the text direction.
///
/// Use it as a whole screen: it draws the headers of both panes, so don't
/// put it under an app bar.
///
/// ```dart
/// SettingsSplitView(
///   title: const Text('Settings'),
///   sections: [
///     SettingsSection(tiles: [
///       SettingsTile.navigation(
///         leading: const Icon(Icons.wifi),
///         title: const Text('Network & internet'),
///         destination: SettingsDestination(
///           id: 'network',
///           builder: (context) => SettingsList(sections: [...]),
///         ),
///       ),
///     ]),
///   ],
/// )
/// ```
class SettingsSplitView extends StatefulWidget {
  const SettingsSplitView({
    super.key,
    required this.sections,
    this.title,
    this.initialDestinationId,
    this.emptyDetailBuilder,
    this.controller,
    this.onDestinationChanged,
    this.layout = SettingsSplitLayout.auto,
    this.breakpoint,
    this.listPaneWidth,
    this.restorationId,
    this.platform,
    this.lightTheme,
    this.darkTheme,
    this.brightness,
    this.applicationType = ApplicationType.material,
  });

  /// The sections of the list pane, as in [SettingsList.sections].
  final List<AbstractSettingsSection> sections;

  /// The list pane's title, e.g. `Text('Settings')`.
  final Widget? title;

  /// The destination shown in the detail pane until the user picks one.
  ///
  /// Defaults to the first destination in [sections], so the detail pane is
  /// never empty (iPad, Android and Chrome all open on a page), unless
  /// [emptyDetailBuilder] is set. The page only fills an empty detail pane:
  /// when the window narrows to one pane, the list shows, not this page.
  final String? initialDestinationId;

  /// Builds the detail pane when no destination is shown there.
  final WidgetBuilder? emptyDetailBuilder;

  /// Reads and changes the shown page. See [SettingsSplitView.of].
  final SettingsSplitController? controller;

  /// Called after the shown destination changes, with its id, or null when
  /// none is shown. Changing the layout can change it too: one pane shows the
  /// list instead of the [initialDestinationId] page. Use it to keep a URL in
  /// sync; the package doesn't touch the app's router.
  final ValueChanged<String?>? onDestinationChanged;

  /// One pane, two panes, or decide by the width.
  final SettingsSplitLayout layout;

  /// With [SettingsSplitLayout.auto], the width from which two panes show,
  /// replacing the style's rule (which also checks the screen's shortest
  /// side on phones and tablets).
  final double? breakpoint;

  /// Width of the list pane with two panes. Defaults to the style's (see the
  /// table above). The detail pane always gets at least half the width.
  ///
  /// In the Windows style it sets the open pane only: the icon rail below
  /// 1008 stays 48 wide, and its menu button opens a pane this wide (320 by
  /// default, WinUI's) over the page.
  final double? listPaneWidth;

  /// Restores the shown page, and the state of the pages that support
  /// restoration, after the app is killed. Pages pushed inside a page are
  /// not restored.
  final String? restorationId;

  /// As in [SettingsList.platform].
  final DevicePlatform? platform;

  /// As in [SettingsList.lightTheme].
  final SettingsThemeData? lightTheme;

  /// As in [SettingsList.darkTheme].
  final SettingsThemeData? darkTheme;

  /// As in [SettingsList.brightness].
  final Brightness? brightness;

  /// As in [SettingsList.applicationType].
  final ApplicationType applicationType;

  /// The controller of the [SettingsSplitView] around [context], if any.
  ///
  /// Code in a page uses it to jump to another page:
  /// `SettingsSplitView.maybeOf(context)?.select('display')`.
  static SettingsSplitController? maybeOf(BuildContext context) =>
      SettingsSplitScope.maybeOf(context)?.controller;

  /// Like [maybeOf], for code that is always inside a [SettingsSplitView].
  static SettingsSplitController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'No SettingsSplitView found in the context.');
    return controller!;
  }

  @override
  State<SettingsSplitView> createState() => _SettingsSplitViewState();
}

/// A destination found among the list pane's tiles.
class _Entry {
  const _Entry(this.destination, this.title);

  final SettingsDestination destination;

  /// The header title: the destination's, or the tile's.
  final Widget title;
}

class _SettingsSplitViewState extends State<SettingsSplitView>
    with RestorationMixin {
  /// The destination the user picked (a tap or [SettingsSplitController]).
  /// Null means none: two panes show the initial destination, one pane shows
  /// the list.
  final RestorableStringN _picked = RestorableStringN(null);

  SettingsSplitController? _ownController;
  SettingsSplitController get _controller =>
      widget.controller ?? (_ownController ??= SettingsSplitController());

  final GlobalKey _listKey = GlobalKey(debugLabel: 'SettingsSplitView list');
  final GlobalKey<NavigatorState> _detailKey = GlobalKey<NavigatorState>(
    debugLabel: 'SettingsSplitView detail',
  );
  final GlobalKey<NavigatorState> _stackKey = GlobalKey<NavigatorState>(
    debugLabel: 'SettingsSplitView stack',
  );
  late final _DetailObserver _detailObserver = _DetailObserver(
    _handleDetailPush,
  );
  late final _StackObserver _stackObserver = _StackObserver(_syncStack);

  /// Top-level destinations from [SettingsSplitView.sections], in order.
  Map<String, _Entry> _destinations = const {};

  /// Destinations tapped in custom sections, which can't be read ahead.
  final Map<String, _Entry> _tapped = {};

  // What the last layout showed.
  bool _isSplit = false;
  String? _shownId;

  /// The page at the root of the detail navigator. One pane keeps the last
  /// page there while its route animates out.
  String? _detailRootId;

  /// Bumped when one pane pushes a page over the list; see [_DetailHost].
  int _hostGeneration = 0;

  bool _detailCanPop = false;
  bool _leaving = false;

  /// One pane: the top route of the stack navigator was pushed from the
  /// list pane (a tile's own `Navigator.push`, a menu, a sheet), so back
  /// pops it first.
  bool _stackPagelessTop = false;

  /// One pane: routes pushed from the list pane are open (or animating
  /// out). The view keeps one pane until they are gone, so they don't
  /// vanish when the window widens.
  bool _holdOnePane = false;

  /// Whether the Windows style's compact rail is open over the detail pane.
  bool _fluentPaneOpen = false;
  Offset _measuredOrigin = Offset.zero;
  bool _originCheckScheduled = false;

  bool _notifyScheduled = false;
  bool _notifiedOnce = false;
  String? _notifiedId;
  bool _notifiedSplit = false;

  /// Whether the iOS large title has scrolled under the bar.
  final ValueNotifier<bool> _largeTitleHidden = ValueNotifier<bool>(false);

  /// Around the list pane, to hand it the keyboard focus.
  final FocusNode _listFocusNode = FocusNode(
    debugLabel: 'SettingsSplitView list',
    skipTraversal: true,
    canRequestFocus: false,
  );

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_picked, 'selected');
    if (initialRestore && _picked.value == null) {
      // A controller.select() before the view existed (a deep link).
      final pending = _controller._takePendingId();
      if (pending != null) _picked.value = pending;
    } else {
      _controller._takePendingId();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller._attach(this);
  }

  @override
  void didUpdateWidget(SettingsSplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?._detach(this);
      _controller._attach(this);
      final pending = _controller._takePendingId();
      if (pending != null) _picked.value = pending;
    }
  }

  @override
  void dispose() {
    _controller._detach(this);
    _ownController?.dispose();
    _picked.dispose();
    _largeTitleHidden.dispose();
    _listFocusNode.dispose();
    super.dispose();
  }

  // Destinations -----------------------------------------------------------

  Map<String, _Entry> _collectDestinations() {
    final result = <String, _Entry>{};
    for (final section in widget.sections) {
      if (section is! SettingsSection) continue;
      for (final tile in section.tiles) {
        if (tile is! SettingsTile) continue;
        final destination = tile.destination;
        if (destination == null) continue;
        assert(
          !result.containsKey(destination.id),
          'SettingsSplitView: two tiles open a destination with the id '
          '"${destination.id}". Destination ids must be unique.',
        );
        result.putIfAbsent(
          destination.id,
          () => _Entry(destination, destination.title ?? tile.title),
        );
      }
    }
    return result;
  }

  _Entry? _lookup(String? id) =>
      id == null ? null : (_destinations[id] ?? _tapped[id]);

  /// The page two panes show when the user hasn't picked one.
  String? get _autoId {
    final initial = widget.initialDestinationId;
    if (initial != null) {
      assert(
        _lookup(initial) != null,
        'SettingsSplitView: initialDestinationId "$initial" matches no '
        'destination in the sections.',
      );
      return _lookup(initial) == null ? null : initial;
    }
    if (widget.emptyDetailBuilder != null) return null;
    return _destinations.keys.firstOrNull;
  }

  /// [_picked], if it still names a destination.
  String? get _pickedId =>
      _lookup(_picked.value) == null ? null : _picked.value;

  // Selection ----------------------------------------------------------------

  void _openFromTile(SettingsDestination destination, Widget tileTitle) {
    if (!_destinations.containsKey(destination.id)) {
      _tapped[destination.id] = _Entry(
        destination,
        destination.title ?? tileTitle,
      );
    }
    _select(destination.id);
  }

  void _select(String id) {
    assert(
      _lookup(id) != null,
      'SettingsSplitView: no destination with the id "$id". select() takes '
      'the id of a SettingsDestination given to a tile in the sections.',
    );
    if (_lookup(id) == null) return;
    final alreadyShown = _shownId == id;
    setState(() {
      if (_pickedId == null) _hostGeneration++;
      _picked.value = id;
      // Picking a page closes the Windows pane opened over it.
      _fluentPaneOpen = false;
    });
    if (alreadyShown) {
      // Tapping the open page again goes back to its first screen.
      _detailKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  void _clearSelection() {
    if (_picked.value == null) return;
    setState(() => _picked.value = null);
  }

  /// A page pushed inside the detail pane makes the initial page the user's
  /// pick, so folding the device keeps it open.
  void _handleDetailPush() {
    if (_picked.value == null && _shownId != null) {
      _picked.value = _shownId;
    }
  }

  // Back ---------------------------------------------------------------------

  bool get _detailVisible => _isSplit || _pickedId != null;

  bool get _canHandleBack =>
      !_leaving &&
      ((!_isSplit && _stackPagelessTop) ||
          (_detailCanPop && _detailVisible) ||
          (!_isSplit && _pickedId != null));

  Future<void> _handleBack() async {
    final stack = _stackKey.currentState;
    if (!_isSplit && stack != null && _stackObserver.topIsPageless) {
      // A route pushed from the list pane: pops it, or lets it veto.
      await stack.maybePop();
      return;
    }
    final detail = _detailKey.currentState;
    if (detail != null && _detailVisible) {
      // Pops a page pushed inside the detail pane, or lets the page veto.
      if (await detail.maybePop()) return;
    }
    if (!mounted) return;
    if (!_isSplit && _pickedId != null) {
      _closeDetail();
    }
  }

  /// Closes the page shown over the list in one pane.
  void _closeDetail() {
    final stack = _stackKey.currentState;
    if (stack != null && stack.canPop()) {
      stack.pop();
    } else {
      _clearSelection();
    }
  }

  void _handleStackPageRemoved(Page<Object?> page) {
    if (page.key == _hostPageKey) _clearSelection();
  }

  /// Reads the routes pushed from the list pane in one pane.
  void _syncStack() {
    final pagelessTop = _stackObserver.topIsPageless;
    final hold = _stackObserver.hasPageless;
    if (!mounted ||
        (pagelessTop == _stackPagelessTop && hold == _holdOnePane)) {
      return;
    }
    setState(() {
      _stackPagelessTop = pagelessTop;
      _holdOnePane = hold;
    });
  }

  bool _handleStackNavigation(NavigationNotification notification) {
    _syncStack();
    // The split view's PopScope speaks for its navigators.
    return true;
  }

  // Named routes pushed from the list pane in one pane come from the app's
  // navigator, as they do with two panes (where the list pane isn't inside
  // the view's own navigator).
  Route<dynamic>? _generateStackRoute(RouteSettings settings) =>
      Navigator.maybeOf(context)?.widget.onGenerateRoute?.call(settings);

  Route<dynamic>? _unknownStackRoute(RouteSettings settings) =>
      Navigator.maybeOf(context)?.widget.onUnknownRoute?.call(settings);

  bool _handleDetailNavigation(NavigationNotification notification) {
    // Read the state from the navigator instead of the notification: routes
    // inside it can report "can't pop" while the navigator can, and on
    // Flutter 3.44 both reach this listener, alternately.
    final navigator = _detailKey.currentState;
    final top = _detailObserver.top;
    final canPop =
        navigator != null &&
        (navigator.canPop() ||
            top?.popDisposition == RoutePopDisposition.doNotPop);
    if (canPop != _detailCanPop && mounted) {
      setState(() => _detailCanPop = canPop);
    }
    // The split view's PopScope speaks for its navigators.
    return true;
  }

  /// The list pane's back button leaves the settings screen, even when the
  /// detail pane could go back.
  void _leave() {
    setState(() => _leaving = true);
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Navigator.maybePop(context);
      if (mounted) setState(() => _leaving = false);
    });
  }

  // Notifications ------------------------------------------------------------

  void _scheduleNotify() {
    if (_notifyScheduled) return;
    if (_notifiedOnce &&
        _shownId == _notifiedId &&
        _isSplit == _notifiedSplit) {
      return;
    }
    _notifyScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      if (!mounted) return;
      final idChanged = _notifiedOnce && _shownId != _notifiedId;
      _notifiedOnce = true;
      _notifiedId = _shownId;
      _notifiedSplit = _isSplit;
      if (idChanged) widget.onDestinationChanged?.call(_shownId);
      _controller._notify();
    }, debugLabel: 'SettingsSplitView.notify');
  }

  // Build --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final style = SettingsStyleConfig(
      platform: widget.platform,
      brightness: widget.brightness,
      lightTheme: widget.lightTheme,
      darkTheme: widget.darkTheme,
      applicationType: widget.applicationType,
    ).resolve(context);
    _destinations = _collectDestinations();
    final route = ModalRoute.of(context);
    final canLeave = route?.impliesAppBarDismissal ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        final window = MediaQuery.sizeOf(context);
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : window.width;
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : window.height;
        final textDirection = Directionality.of(context);

        final features = MediaQuery.displayFeaturesOf(context);
        SeparatingHinge? hinge;
        if (features.isNotEmpty) {
          // Display features are in window coordinates. A full-width view
          // starts at the window's left edge; otherwise measure where it is.
          final fullWidth = (width - window.width).abs() < 0.5;
          if (!fullWidth) _scheduleOriginCheck();
          hinge = findSeparatingHinge(
            features: features,
            origin: fullWidth ? Offset.zero : _measuredOrigin,
            size: Size(width, height),
          );
        }

        var geometry = computeSplitGeometry(
          family: settingsStyleFamily(style.platform),
          forceSingle: widget.layout == SettingsSplitLayout.single,
          forceSplit: widget.layout == SettingsSplitLayout.split,
          width: width,
          shortestSide: window.shortestSide,
          desktop: isDesktopPlatform(Theme.of(context).platform),
          textDirection: textDirection,
          textScaler: MediaQuery.textScalerOf(context),
          breakpoint: widget.breakpoint,
          listPaneWidth: widget.listPaneWidth,
          hinge: hinge,
        );
        // A route pushed from the list pane lives in the one-pane navigator:
        // keep it (and one pane) until it closes. It covers the view either
        // way, as it does with two panes.
        if (_holdOnePane) geometry = const SplitGeometry.single();
        return _buildLayout(context, style, geometry, canLeave);
      },
    );
  }

  void _scheduleOriginCheck() {
    if (_originCheckScheduled) return;
    _originCheckScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _originCheckScheduled = false;
      if (!mounted) return;
      final box = context.findRenderObject();
      if (box is! RenderBox || !box.hasSize || !box.attached) return;
      final origin = box.localToGlobal(Offset.zero);
      if ((origin - _measuredOrigin).distance > 0.5) {
        setState(() => _measuredOrigin = origin);
      }
    }, debugLabel: 'SettingsSplitView.origin');
  }

  Widget _buildLayout(
    BuildContext context,
    ResolvedSettingsStyle style,
    SplitGeometry geometry,
    bool canLeave,
  ) {
    final isSplit = geometry.isSplit;
    final picked = _pickedId;
    final shownId = isSplit ? (picked ?? _autoId) : picked;
    _isSplit = isSplit;
    if (!geometry.compactPane) _fluentPaneOpen = false;
    _shownId = shownId;
    if (isSplit || shownId != null) _detailRootId = shownId;
    _scheduleNotify();

    final Widget panes;
    if (isSplit) {
      panes = _buildTwoPanes(style, geometry, canLeave);
    } else {
      panes = _buildOnePane(style, canLeave);
    }

    return SettingsSplitScope(
      controller: _controller,
      isSplit: isSplit,
      shownId: shownId,
      hostGeneration: _hostGeneration,
      goBack: _handleBack,
      child: Actions(
        actions: <Type, Action<Intent>>{
          NextFocusIntent: _PaneFocusAction<NextFocusIntent>(this, true),
          PreviousFocusIntent: _PaneFocusAction<PreviousFocusIntent>(
            this,
            false,
          ),
        },
        child: PopScope<Object?>(
          canPop: !_canHandleBack,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _handleBack();
          },
          child: UnmanagedRestorationScope(
            bucket: bucket,
            child: SettingsTheme(
              themeData: style.themeData,
              platform: style.platform,
              child: panes,
            ),
          ),
        ),
      ),
    );
  }

  /// Whether [node] is the focus node of one of the view's navigators,
  /// which holds the focus until something in a pane takes it.
  bool _isNavigatorFocus(FocusNode node) =>
      node == _detailKey.currentState?.focusNode ||
      node == _stackKey.currentState?.focusNode;

  /// Gives the keyboard focus to the first (or last) control of the list
  /// pane. Returns whether there was one.
  bool _focusListPane({required bool first}) {
    final nodes =
        _listFocusNode.traversalDescendants
            .where((node) => node.context != null && node.canRequestFocus)
            .toList()
          ..sort((a, b) {
            final byTop = a.rect.top.compareTo(b.rect.top);
            return byTop != 0 ? byTop : a.rect.left.compareTo(b.rect.left);
          });
    if (nodes.isEmpty) return false;
    (first ? nodes.first : nodes.last).requestFocus();
    return true;
  }

  Widget _buildTwoPanes(
    ResolvedSettingsStyle style,
    SplitGeometry geometry,
    bool canLeave,
  ) {
    final theme = style.themeData;
    final family = settingsStyleFamily(style.platform);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Web: Chrome's 680px column, nearer the menu. iPad and Android: pages
    // fill the detail pane. The desktop styles keep their own columns.
    final detail = SettingsContentColumnHint(
      paneWidth: geometry.detailWidth,
      endReserve: family == SettingsStyleFamily.web
          ? webDetailEndReserve(geometry.detailWidth)
          : 0,
      fillWidth: family != SettingsStyleFamily.web,
      child: _buildDetailNavigator(style),
    );

    // Its own semantics container: the routes of the detail navigator block
    // the semantics of what was painted before them in their container,
    // which would hide the list pane.
    final Widget detailPane = Semantics(
      container: true,
      explicitChildNodes: true,
      child: ClipRect(
        child: MediaQuery.removePadding(
          context: context,
          removeLeft: !isRtl,
          removeRight: isRtl,
          child: detail,
        ),
      ),
    );

    Widget listPane = Semantics(
      container: true,
      explicitChildNodes: true,
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: isRtl,
        removeRight: !isRtl,
        child: _buildListPane(
          style,
          isSplit: true,
          width: geometry.listWidth,
          canLeave: canLeave,
          compactPane: geometry.compactPane,
        ),
      ),
    );

    // The line between the panes: a hairline on the macOS sidebar, GNOME's
    // 1px sidebar border. Windows Settings has none (one Mica surface).
    final Color? edge = switch (family) {
      SettingsStyleFamily.macos => macosSidebarEdgeColor(theme),
      SettingsStyleFamily.adwaita => adwaitaSidebarBorderColor(theme),
      _ => null,
    };
    if (edge != null) {
      listPane = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: BorderDirectional(
            end: BorderSide(
              color: edge,
              width: family == SettingsStyleFamily.macos ? 0.5 : 1,
            ),
          ),
        ),
        child: listPane,
      );
    }

    // Tab visits the list pane, then the page, whatever the reading order
    // of their contents says: the page's first control can sit above the
    // first row, under a taller pane header.
    listPane = FocusTraversalOrder(
      order: const NumericFocusOrder(0),
      child: listPane,
    );
    final orderedDetailPane = FocusTraversalOrder(
      order: const NumericFocusOrder(1),
      child: detailPane,
    );

    final background =
        theme.listPaneBackground ??
        theme.settingsListBackground ??
        const Color(0x00000000);

    if (geometry.compactPane) {
      final openWidth = math.min(
        widget.listPaneWidth ?? kFluentOverlayPaneWidth,
        geometry.listWidth + geometry.detailWidth,
      );
      return _orderedPanes(
        ColoredBox(
          color: background,
          child: FluentCompactPaneLayout(
            open: _fluentPaneOpen,
            railWidth: geometry.listWidth,
            openWidth: openWidth,
            onDismiss: _closeFluentPane,
            pane: listPane,
            detail: orderedDetailPane,
          ),
        ),
      );
    }

    return _orderedPanes(
      ColoredBox(
        color: background,
        child: Row(
          children: [
            SizedBox(width: geometry.listWidth, child: listPane),
            if (geometry.gap > 0) SizedBox(width: geometry.gap),
            Expanded(child: orderedDetailPane),
          ],
        ),
      ),
    );
  }

  static Widget _orderedPanes(Widget child) =>
      FocusTraversalGroup(policy: OrderedTraversalPolicy(), child: child);

  void _toggleFluentPane() =>
      setState(() => _fluentPaneOpen = !_fluentPaneOpen);

  void _closeFluentPane() {
    if (_fluentPaneOpen) setState(() => _fluentPaneOpen = false);
  }

  static const _listPageKey = ValueKey<String>('settings_split_list');
  ValueKey<String> get _hostPageKey =>
      ValueKey<String>('settings_split_detail_$_hostGeneration');

  Widget _buildOnePane(ResolvedSettingsStyle style, bool canLeave) {
    final picked = _pickedId;
    final pages = <Page<void>>[
      _PlainPage(
        key: _listPageKey,
        restorationId: 'list',
        child: _buildListPane(
          style,
          isSplit: false,
          width: null,
          canLeave: canLeave,
          compactPane: false,
        ),
      ),
      if (picked != null) _hostPage(style, picked),
    ];
    return NotificationListener<NavigationNotification>(
      onNotification: _handleStackNavigation,
      child: Navigator(
        key: _stackKey,
        restorationScopeId: widget.restorationId == null ? null : 'stack',
        // Tab leaves the navigator's pages for the rest of the app, as in
        // the app's own navigator (nested ones default to a closed loop).
        routeTraversalEdgeBehavior: TraversalEdgeBehavior.parentScope,
        observers: [_stackObserver],
        pages: pages,
        onGenerateRoute: _generateStackRoute,
        onUnknownRoute: _unknownStackRoute,
        onDidRemovePage: _handleStackPageRemoved,
      ),
    );
  }

  Page<void> _hostPage(ResolvedSettingsStyle style, String id) {
    final child = PopScope<Object?>(
      // The page's back swipe (and predictive back) would close it even
      // while a page pushed inside it could go back, or the page vetoes
      // back with a PopScope: then back goes through the split view.
      canPop: !_detailCanPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: _DetailHost(
        generation: _hostGeneration,
        background: style.themeData.settingsListBackground,
        child: _buildDetailNavigator(style),
      ),
    );
    if (settingsUsesCupertinoRoutes(settingsStyleFamily(style.platform))) {
      return CupertinoPage<void>(
        key: _hostPageKey,
        name: id,
        restorationId: 'detail',
        child: child,
      );
    }
    return MaterialPage<void>(
      key: _hostPageKey,
      name: id,
      restorationId: 'detail',
      child: child,
    );
  }

  Widget _buildDetailNavigator(ResolvedSettingsStyle style) {
    return NotificationListener<NavigationNotification>(
      onNotification: _handleDetailNavigation,
      child: Navigator(
        key: _detailKey,
        restorationScopeId: widget.restorationId == null ? null : 'detail',
        // Tab moves on from the detail pane to the list pane (a closed loop
        // would keep the focus in the page). Showing a page picked in the
        // list leaves the focus in the list, like the platforms' sidebars;
        // pages opened inside the pane take it (see _DetailObserver).
        routeTraversalEdgeBehavior: TraversalEdgeBehavior.parentScope,
        requestFocus: false,
        observers: [_detailObserver],
        pages: [_detailRootPage(style)],
        onDidRemovePage: (_) {},
      ),
    );
  }

  Page<void> _detailRootPage(ResolvedSettingsStyle style) {
    final id = _detailRootId;
    final entry = _lookup(id);
    if (entry == null) {
      return _PlainPage(
        key: const ValueKey<String>('settings_split_empty'),
        child: Material(
          color: style.themeData.settingsListBackground,
          child: Builder(
            builder: (context) =>
                widget.emptyDetailBuilder?.call(context) ??
                const SizedBox.expand(),
          ),
        ),
      );
    }
    return _PlainPage(
      key: ValueKey<String>('settings_split_page_$id'),
      name: id,
      restorationId: 'page_$id',
      child: SettingsDestinationPage(
        destination: entry.destination,
        title: entry.title,
        config: style.resolvedConfig,
        isDetailRoot: true,
      ),
    );
  }

  Widget _buildListPane(
    ResolvedSettingsStyle style, {
    required bool isSplit,
    required double? width,
    required bool canLeave,
    required bool compactPane,
  }) {
    final theme = style.themeData;
    final family = settingsStyleFamily(style.platform);
    final title = widget.title;
    // The macOS, Windows and GNOME sidebars. GNOME Settings also shows its
    // sidebar as the first page when it's collapsed.
    final sidebar = switch (family) {
      SettingsStyleFamily.macos || SettingsStyleFamily.fluent => isSplit,
      SettingsStyleFamily.adwaita => true,
      _ => false,
    };
    final background = isSplit || sidebar
        ? (theme.listPaneBackground ?? theme.settingsListBackground)
        : theme.settingsListBackground;
    final onBack = canLeave ? _leave : null;

    // The list pane's own background, for the tiles too (iOS descriptions
    // are drawn on it).
    SettingsThemeData withBackground(SettingsThemeData? theme) =>
        (theme ?? const SettingsThemeData()).merge(
          theme: SettingsThemeData(settingsListBackground: background),
        );

    final iosLargeTitle =
        family == SettingsStyleFamily.cupertino && title != null;
    final EdgeInsetsGeometry? padding;
    if (sidebar) {
      switch (family) {
        case SettingsStyleFamily.macos:
          padding = const EdgeInsets.only(bottom: 10);
        case SettingsStyleFamily.fluent:
          // Windows Settings' open pane starts its items 16 from the
          // window edge; the rail and the pane opened from it keep
          // NavigationView's own 4.
          padding = EdgeInsetsDirectional.only(
            start: compactPane ? 0 : kFluentPaneGutter,
            bottom: 8,
          );
        default:
          padding = const EdgeInsets.only(
            top: kAdwaitaSidebarPaddingTop,
            bottom: kAdwaitaSidebarPaddingBottom,
          );
      }
    } else if (!isSplit) {
      padding = null;
    } else {
      switch (family) {
        case SettingsStyleFamily.cupertino:
          padding = const EdgeInsets.only(bottom: 20);
        case SettingsStyleFamily.material:
          padding = const EdgeInsets.only(bottom: 16);
        default:
          padding = const EdgeInsets.symmetric(vertical: 8);
      }
    }

    final List<AbstractSettingsSection> sections;
    if (isSplit && family == SettingsStyleFamily.web) {
      // Chrome's menu separates its groups with a full-width line.
      sections = _interleave(
        widget.sections,
        (_) => const CustomSettingsSection(child: _WebMenuSeparator()),
      );
    } else if (sidebar) {
      sections = _interleave(_shownSections(widget.sections), (next) {
        switch (family) {
          case SettingsStyleFamily.macos:
            return const CustomSettingsSection(child: MacosSidebarSectionGap());
          case SettingsStyleFamily.fluent:
            return CustomSettingsSection(
              child: FluentPaneSeparator(
                beforeTitle: next is SettingsSection && next.title != null,
              ),
            );
          default:
            return const CustomSettingsSection(
              child: AdwaitaSidebarSeparator(),
            );
        }
      });
    } else {
      sections = widget.sections;
    }

    Widget list = SettingsList(
      platform: style.platform,
      brightness: widget.brightness,
      lightTheme: withBackground(widget.lightTheme),
      darkTheme: withBackground(widget.darkTheme),
      applicationType: widget.applicationType,
      contentPadding: padding,
      sections: [
        if (iosLargeTitle)
          CustomSettingsSection(child: SettingsLargeTitle(title: title)),
        ...sections,
      ],
    );

    if (family == SettingsStyleFamily.fluent) {
      // One pane shows the title as a Windows page title over the list.
      list = FluentPageTitleAbove(above: !isSplit, child: list);
    }

    // Keep the same widget structure in both layouts, so the list pane (it
    // moves between them under a GlobalKey) keeps its scroll position.
    Widget content;
    switch (family) {
      case SettingsStyleFamily.cupertino:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _largeTitleHidden,
              builder: (context, hidden, _) => SettingsPageBar(
                platform: style.platform,
                title: title,
                // With a large title in the list, the bar shows the title
                // only once it scrolled away, like iOS.
                showTitle: !iosLargeTitle || hidden,
                onBack: onBack,
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: NotificationListener<ScrollUpdateNotification>(
                  onNotification: (notification) {
                    if (notification.depth == 0) {
                      _largeTitleHidden.value =
                          notification.metrics.pixels > 40;
                    }
                    return false;
                  },
                  child: list,
                ),
              ),
            ),
          ],
        );
      case SettingsStyleFamily.material:
        content = title != null
            ? SettingsCollapsingTitleView(
                title: title,
                onBack: onBack,
                background: background,
                body: list,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsPageBar(
                    platform: style.platform,
                    title: null,
                    onBack: onBack,
                  ),
                  Expanded(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: list,
                    ),
                  ),
                ],
              );
      case SettingsStyleFamily.web:
      case SettingsStyleFamily.macos:
      case SettingsStyleFamily.fluent:
      case SettingsStyleFamily.adwaita:
        final Widget header;
        switch (family) {
          case SettingsStyleFamily.web:
            header = isSplit
                ? _WebMenuHeader(title: title, onBack: onBack)
                : SettingsPageBar(
                    platform: style.platform,
                    title: title,
                    onBack: onBack,
                  );
          case SettingsStyleFamily.macos:
            // The sidebar runs under the title bar; one pane is a page.
            header = isSplit
                ? MacosSidebarTopBar(onBack: onBack)
                : MacosToolbar(title: title, onBack: onBack);
          case SettingsStyleFamily.fluent:
            header = isSplit
                ? FluentPaneHeader(
                    title: title,
                    onBack: onBack,
                    onTogglePane: compactPane ? _toggleFluentPane : null,
                  )
                : FluentPageHeader(title: title, onBack: onBack);
          default:
            header = AdwaitaHeaderBar(title: title, onBack: onBack);
        }
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: list,
              ),
            ),
          ],
        );
    }

    // Keyboard navigation of the desktop sidebars, the macOS window focus
    // and the Windows selection indicator. They wrap the list in both
    // layouts, so its structure stays the same.
    switch (family) {
      case SettingsStyleFamily.macos:
        content = MacosWindowActivity(
          child: SettingsSidebarKeyboard(
            enabled: sidebar,
            selectionFollowsFocus: true,
            child: content,
          ),
        );
      case SettingsStyleFamily.fluent:
        content = FluentNavigationPane(enabled: sidebar, child: content);
      case SettingsStyleFamily.adwaita:
        content = SettingsSidebarKeyboard(child: content);
      case SettingsStyleFamily.cupertino:
      case SettingsStyleFamily.material:
      case SettingsStyleFamily.web:
        break;
    }

    final hideLeading =
        isSplit &&
        family == SettingsStyleFamily.material &&
        width != null &&
        width < 380;

    return SettingsSplitListScope(
      isSplit: isSplit,
      sidebar: sidebar || isSplit,
      selectedId: _shownId,
      onOpen: _openFromTile,
      hideLeading: hideLeading,
      child: KeyedSubtree(
        key: const ValueKey<String>('settings_split_list_pane'),
        child: Material(
          key: _listKey,
          color: background,
          child: Focus(focusNode: _listFocusNode, child: content),
        ),
      ),
    );
  }
}

/// [sections] without the [SettingsSection]s that have no tiles (they show
/// nothing), so separators between sections don't double up.
List<AbstractSettingsSection> _shownSections(
  List<AbstractSettingsSection> sections,
) => [
  for (final section in sections)
    if (section is! SettingsSection || section.tiles.isNotEmpty) section,
];

/// [sections] with a separator from [separatorBefore] between each two.
List<AbstractSettingsSection> _interleave(
  List<AbstractSettingsSection> sections,
  AbstractSettingsSection Function(AbstractSettingsSection next)
  separatorBefore,
) => [
  for (final (index, section) in sections.indexed) ...[
    if (index > 0) separatorBefore(section),
    section,
  ],
];

/// Tab and Shift+Tab in a split view. A page without any control leaves
/// its route's focus scope with nothing to move to, which would keep the
/// focus there: then the focus goes on to the list pane.
class _PaneFocusAction<T extends Intent> extends Action<T> {
  _PaneFocusAction(this.view, this.forward);

  final _SettingsSplitViewState view;
  final bool forward;

  @override
  Object? invoke(T intent) {
    final node = FocusManager.instance.primaryFocus;
    if (node == null) return null;
    // Nothing is focused yet: the detail navigator took the focus when it
    // was built (navigators autofocus). Start in the list pane, like the
    // platforms' settings apps, not after the navigator in the page.
    if (forward &&
        view._isNavigatorFocus(node) &&
        view._focusListPane(first: true)) {
      return null;
    }
    final moved = forward ? node.nextFocus() : node.previousFocus();
    if (!moved) view._focusListPane(first: forward);
    return null;
  }
}

/// Chrome's settings toolbar over the menu: "Settings" in 22px.
class _WebMenuHeader extends StatelessWidget {
  const _WebMenuHeader({required this.title, required this.onBack});

  final Widget? title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final title = this.title;
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            if (onBack != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12),
                child: IconButton(
                  onPressed: onBack,
                  iconSize: 20,
                  icon: Icon(
                    Icons.arrow_back,
                    semanticLabel: settingsBackLabel(context),
                  ),
                  color: theme.leadingIconsColor,
                ),
              )
            else
              const SizedBox(width: 24),
            if (title != null)
              Expanded(
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: theme.settingsTileTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Semantics(header: true, child: title),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The line between groups in Chrome's settings menu.
class _WebMenuSeparator extends StatelessWidget {
  const _WebMenuSeparator();

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 1,
        color:
            theme.dividerColor ??
            theme.settingsTileTextColor?.withValues(alpha: 0.12),
      ),
    );
  }
}

/// The page one pane pushes over the list. It holds the detail navigator,
/// unless a newer page took it while this one animates out.
class _DetailHost extends StatelessWidget {
  const _DetailHost({
    required this.generation,
    required this.background,
    required this.child,
  });

  final int generation;
  final Color? background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = SettingsSplitScope.maybeOf(context);
    if (scope != null && scope.hostGeneration != generation) {
      return ColoredBox(color: background ?? const Color(0x00000000));
    }
    return child;
  }
}

/// A page without a transition: the list under one pane, and the root of
/// the detail pane, which iPad, Android and Chrome all swap in place.
class _PlainPage extends Page<void> {
  const _PlainPage({
    required LocalKey super.key,
    super.name,
    super.restorationId,
    required this.child,
  });

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) => _PlainPageRoute(this);
}

class _PlainPageRoute extends PageRoute<void> {
  _PlainPageRoute(_PlainPage page) : super(settings: page);

  _PlainPage get _page => settings as _PlainPage;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _page.child,
    );
  }
}

/// Watches the one-pane navigator for routes pushed from the list pane:
/// routes without a page, such as a tile's own `Navigator.push`, a menu or
/// a bottom sheet.
class _StackObserver extends NavigatorObserver {
  _StackObserver(this.onChanged);

  /// Called when a route pushed from the list pane has finished animating
  /// out. Pushes and pops also dispatch a [NavigationNotification].
  final VoidCallback onChanged;

  /// The navigator's top route.
  Route<dynamic>? _top;

  /// Routes without a page, until they have animated out.
  final Set<Route<dynamic>> _pageless = <Route<dynamic>>{};

  bool get topIsPageless {
    final top = _top;
    return top != null && top.settings is! Page;
  }

  bool get hasPageless => _pageless.isNotEmpty;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _top = route;
    if (route.settings is! Page) _pageless.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route == _top) _top = previousRoute;
    _release(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route == _top) _top = previousRoute;
    _pageless.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute == _top) _top = newRoute;
    _pageless.remove(oldRoute);
    if (newRoute != null && newRoute.settings is! Page) _pageless.add(newRoute);
  }

  /// Forgets [route] once its exit animation is over.
  void _release(Route<dynamic> route) {
    if (!_pageless.contains(route)) return;
    final animation = route is TransitionRoute<dynamic>
        ? route.animation
        : null;
    if (animation == null || animation.isDismissed) {
      _pageless.remove(route);
      return;
    }
    void handleStatus(AnimationStatus status) {
      if (!status.isDismissed) return;
      animation.removeStatusListener(handleStatus);
      if (_pageless.remove(route)) onChanged();
    }

    animation.addStatusListener(handleStatus);
  }
}

class _DetailObserver extends NavigatorObserver {
  _DetailObserver(this.onUserPush);

  final VoidCallback onUserPush;

  /// The detail navigator's top route.
  Route<dynamic>? top;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    top = route;
    if (previousRoute != null && route.settings is! Page) {
      onUserPush();
      // The detail navigator doesn't move the focus by itself: give it to a
      // page opened from inside the pane, as a navigator normally does.
      if (route is ModalRoute<dynamic>) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          final context = route.subtreeContext;
          if (route.isActive && route.isCurrent && context != null) {
            FocusScope.of(context).requestFocus();
          }
        });
      }
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route == top) top = previousRoute;
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route == top) top = previousRoute;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute == top) top = newRoute;
  }
}
