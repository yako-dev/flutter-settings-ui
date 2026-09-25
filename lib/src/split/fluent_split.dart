import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/split/settings_page_header.dart';
import 'package:settings_ui/src/split/settings_page_trail.dart';
import 'package:settings_ui/src/split/sidebar_keyboard.dart';
import 'package:settings_ui/src/tiles/platforms/fluent_settings_switch.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/utils/fluent_tokens.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

// The WinUI 3 `NavigationView` of Windows 11 Settings (left pane), from
// microsoft-ui-xaml's NavigationView_themeresources.xaml, measured against
// real Settings captures. All sizes are effective pixels.

/// NavigationViewItemOnLeftMinHeight.
const double kFluentPaneItemMinHeight = 36;

/// NavigationViewItemButtonMargin (4,2): items are 4 from the pane edges
/// and 4 apart.
const double _kItemMarginH = 4;
const double _kItemMarginV = 2;

/// ControlCornerRadius.
const double _kItemRadius = 4;

/// The icon is 16 (NavigationViewItemOnLeftIconBoxHeight), centered in a 40
/// column (NavigationViewIconBoxWidth): 24 from the pane edge.
const double _kIconColumn = 40;
const double _kIconSize = 16;

/// NavigationViewItemContentPresenterMargin (4,-1,8,-1): the label starts
/// 48 from the pane edge.
const double _kLabelStart = 4;
const double _kLabelEnd = 8;

/// The selection indicator: a 3x16 accent pill with 2 corners at the
/// item's start edge.
const double _kPillWidth = 3;
const double _kPillHeight = 16;
const double _kPillRadius = 2;

/// The pill slides (and stretches) from the old item to the new one.
const Duration _kPillDuration = Duration(milliseconds: 350);

/// Windows Settings puts the open pane's items 16 from the window edge,
/// 12 more than NavigationView's own 4 item margin.
const double kFluentPaneGutter = 12;

/// The pane's top row, where Windows Settings has its title bar ("←
/// Settings", 48 tall).
const double kFluentPaneHeaderHeight = 48;

/// The pane opened over the content from the compact rail
/// (OpenPaneLength).
const double kFluentOverlayPaneWidth = 320;

/// NavigationViewItemHeader: BodyStrong in the secondary text color, 16 in
/// (NavigationViewItemInnerHeaderMargin), on a 40 row.
const double _kHeaderHeight = 40;
const double _kHeaderStart = 16;

/// Page titles: Title, 28/36 semibold.
const TextStyle kFluentTitleStyle = TextStyle(
  fontSize: 28,
  height: 36 / 28,
  fontWeight: FontWeight.w600,
  letterSpacing: 0,
  leadingDistribution: TextLeadingDistribution.even,
);

FluentTokens _tokensOf(BuildContext context) =>
    FluentTokens.of(FluentTokens.brightnessOf(context));

/// Tells the items of a Windows pane whether it is the compact icon rail.
/// Internal.
class FluentPaneModeScope extends InheritedWidget {
  const FluentPaneModeScope({
    super.key,
    required this.compact,
    required super.child,
  });

  final bool compact;

  static bool compactOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<FluentPaneModeScope>()
          ?.compact ??
      false;

  @override
  bool updateShouldNotify(FluentPaneModeScope oldWidget) =>
      compact != oldWidget.compact;
}

/// The list pane of a Windows style split view: the keyboard navigation
/// and the selection indicator that the items share, so it can slide from
/// one to the other. Internal.
class FluentNavigationPane extends StatefulWidget {
  const FluentNavigationPane({
    super.key,
    this.enabled = true,
    required this.child,
  });

  /// False when the list is not a pane (one pane shows cards).
  final bool enabled;
  final Widget child;

  @override
  State<FluentNavigationPane> createState() => _FluentNavigationPaneState();
}

class _FluentNavigationPaneState extends State<FluentNavigationPane> {
  final _FluentSelectionIndicator _indicator = _FluentSelectionIndicator();

  @override
  Widget build(BuildContext context) {
    return _FluentIndicatorScope(
      indicator: _indicator,
      child: SettingsSidebarKeyboard(
        enabled: widget.enabled,
        child: widget.child,
      ),
    );
  }
}

/// Where the selection indicator was last shown, so the next selected item
/// can slide it in from there.
class _FluentSelectionIndicator {
  final Map<String, _FluentNavigationItemState> _items =
      <String, _FluentNavigationItemState>{};

  /// The item whose pill shows (or last showed).
  String? shownId;

  void register(String id, _FluentNavigationItemState item) =>
      _items[id] = item;

  void unregister(String id, _FluentNavigationItemState item) {
    if (_items[id] == item) _items.remove(id);
  }

  /// The pill of the item [id] in global coordinates, if it is on screen.
  Rect? globalPillRectOf(String id) {
    final item = _items[id];
    if (item == null || !item.mounted) return null;
    final box = item.context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return MatrixUtils.transformRect(
      box.getTransformTo(null),
      item.pillRect(box.size),
    );
  }
}

class _FluentIndicatorScope extends InheritedWidget {
  const _FluentIndicatorScope({required this.indicator, required super.child});

  final _FluentSelectionIndicator indicator;

  static _FluentSelectionIndicator? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_FluentIndicatorScope>()?.indicator;

  @override
  bool updateShouldNotify(_FluentIndicatorScope oldWidget) =>
      indicator != oldWidget.indicator;
}

/// An item of the Windows Settings navigation pane (a WinUI
/// `NavigationViewItem`): a tile in the list pane of a Windows style split
/// view. Internal.
///
/// At least 36 tall with 4,2 margins and 4 corners; a 16 icon in a 40
/// column and the Body label at 48. Selected: the neutral
/// SubtleFillSecondary fill and a 3x16 accent pill at the start edge, which
/// slides over from the previously selected item. Hover and pressed fills,
/// a secondary label while pressed, and the Fluent focus ring. In the
/// compact rail the item is 40 wide and shows only its icon, with the label
/// in a tooltip. Descriptions and values are not shown.
class FluentNavigationItem extends StatefulWidget {
  const FluentNavigationItem({
    super.key,
    required this.id,
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
  });

  /// The id of the page the item opens, if any: the selection indicator
  /// finds the item by it.
  final String? id;
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

  @override
  State<FluentNavigationItem> createState() => _FluentNavigationItemState();
}

class _FluentNavigationItemState extends State<FluentNavigationItem>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  bool _focusHighlight = false;
  int? _pressPointer;

  /// Slides the pill in when the item becomes selected.
  late final AnimationController _pill;

  /// Where the pill slides in from, in this item's coordinates.
  Rect? _pillFrom;

  _FluentSelectionIndicator? _indicator;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
  };

  bool get _isSwitch => widget.tileType == SettingsTileType.switchTile;

  /// A switch item in the rail has no room for its switch: a tap toggles.
  bool _togglesOnTap(bool compact) =>
      compact &&
      _isSwitch &&
      widget.onPressed == null &&
      widget.onToggle != null;

  bool _clickable(bool compact) =>
      widget.enabled && (widget.onPressed != null || _togglesOnTap(compact));

  void _activate() {
    if (!widget.enabled) return;
    if (widget.onPressed != null) {
      widget.onPressed!(context);
    } else if (_togglesOnTap(FluentPaneModeScope.compactOf(context))) {
      widget.onToggle!(!widget.initialValue);
    }
  }

  @override
  void initState() {
    super.initState();
    _pill = AnimationController(
      vsync: this,
      duration: _kPillDuration,
      value: 1,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final indicator = _FluentIndicatorScope.maybeOf(context);
    if (indicator != _indicator) {
      final id = widget.id;
      if (id != null) _indicator?.unregister(id, this);
      _indicator = indicator;
      if (id != null) indicator?.register(id, this);
      if (widget.selected && id != null) indicator?.shownId ??= id;
    }
  }

  @override
  void didUpdateWidget(FluentNavigationItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      if (oldWidget.id != null) _indicator?.unregister(oldWidget.id!, this);
      if (widget.id != null) _indicator?.register(widget.id!, this);
    }
    if (!widget.enabled) {
      _pressed = false;
      _pressPointer = null;
    }
    if (widget.selected && !oldWidget.selected) {
      // Find the old pill once every item has rebuilt.
      WidgetsBinding.instance.addPostFrameCallback((_) => _slidePillIn());
    }
  }

  @override
  void dispose() {
    final id = widget.id;
    if (id != null) _indicator?.unregister(id, this);
    _pill.dispose();
    super.dispose();
  }

  void _slidePillIn() {
    if (!mounted || !widget.selected) return;
    final indicator = _indicator;
    final id = widget.id;
    final previous = indicator?.shownId;
    if (id != null) indicator?.shownId = id;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final from = previous == null || previous == id || reduceMotion
        ? null
        : indicator?.globalPillRectOf(previous);
    final box = context.findRenderObject();
    if (from == null || box is! RenderBox || !box.hasSize) {
      _pillFrom = null;
      _pill.value = 1;
      return;
    }
    final toLocal = Matrix4.tryInvert(box.getTransformTo(null));
    if (toLocal == null) return;
    setState(() => _pillFrom = MatrixUtils.transformRect(toLocal, from));
    _pill.forward(from: 0);
  }

  /// The pill's rectangle in an item of [size] (margins included).
  Rect pillRect(Size size) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final left = isRtl
        ? size.width - _kItemMarginH - _kPillWidth
        : _kItemMarginH;
    return Rect.fromLTWH(
      left,
      (size.height - _kPillHeight) / 2,
      _kPillWidth,
      _kPillHeight,
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pressPointer != null) return;
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons != kPrimaryMouseButton) {
      return;
    }
    _pressPointer = event.pointer;
    setState(() => _pressed = true);
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer != _pressPointer) return;
    _pressPointer = null;
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final tokens = _tokensOf(context);
    final compact = FluentPaneModeScope.compactOf(context);
    final enabled = widget.enabled;
    final clickable = _clickable(compact);
    final selected = widget.selected;
    final pressed = clickable && _pressed;
    final hovered = clickable && _hovered;

    final selectedFill = theme.selectedTileColor ?? tokens.navItemSelected;
    final Color? fill;
    if (!enabled) {
      fill = selected ? selectedFill : null;
    } else if (selected) {
      fill = pressed
          ? selectedFill
          : hovered
          ? tokens.navItemPressed
          : selectedFill;
    } else {
      fill = pressed
          ? tokens.navItemPressed
          : hovered
          ? tokens.navItemSelected
          : null;
    }

    final primary = selected
        ? (theme.selectedTileTextColor ??
              theme.settingsTileTextColor ??
              tokens.textPrimary)
        : (theme.settingsTileTextColor ?? tokens.textPrimary);
    final secondary = theme.tileDescriptionTextColor ?? tokens.textSecondary;
    final foreground = !enabled
        ? (theme.inactiveTitleColor ?? tokens.textDisabled)
        : pressed
        ? secondary
        : primary;
    final iconColor = !enabled
        ? foreground
        : pressed
        ? secondary
        : selected
        ? (theme.selectedTileIconColor ?? primary)
        : (theme.leadingIconsColor ?? primary);

    final labelStyle = (theme.tileTextStyle ?? FluentTypography.body).copyWith(
      color: foreground,
    );

    final title = widget.title;
    final String? tooltip = title is Text
        ? (title.data ?? title.textSpan?.toPlainText())
        : null;

    Widget? icon = widget.leading;
    if (icon == null && compact && tooltip != null && tooltip.isNotEmpty) {
      // The rail needs something to click: the label's first letter.
      icon = ExcludeSemantics(
        child: Text(
          tooltip.characters.first,
          style: labelStyle.copyWith(fontWeight: FontWeight.w600),
        ),
      );
    }

    final textScaler = MediaQuery.textScalerOf(context);
    Widget content = Row(
      children: [
        SizedBox(
          width: _kIconColumn,
          child: icon == null
              ? null
              : Center(
                  child: IconTheme.merge(
                    data: IconThemeData(color: iconColor, size: _kIconSize),
                    child: icon,
                  ),
                ),
        ),
        if (!compact) ...[
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: _kLabelStart,
                end: _kLabelEnd,
              ),
              child: DefaultTextStyle(
                style: labelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: title,
              ),
            ),
          ),
          if (widget.trailing != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: _kLabelEnd),
              child: IconTheme.merge(
                data: IconThemeData(color: iconColor, size: _kIconSize),
                child: DefaultTextStyle(
                  style: labelStyle,
                  child: widget.trailing!,
                ),
              ),
            ),
          if (_isSwitch)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: _kLabelEnd),
              child: ExcludeFocus(
                child: FluentSettingsSwitch(
                  value: widget.initialValue,
                  onChanged: enabled ? widget.onToggle : null,
                  activeTrackColor: widget.activeSwitchColor,
                ),
              ),
            ),
        ],
      ],
    );

    content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kFluentPaneItemMinHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: textScaler.scale(2)),
        child: content,
      ),
    );

    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    Widget item = TweenAnimationBuilder<Color?>(
      // Background changes fade in 83 ms (BrushTransition).
      tween: ColorTween(
        end: fill ?? tokens.navItemSelected.withValues(alpha: 0),
      ),
      duration: reduceMotion ? Duration.zero : kFluentFasterDuration,
      builder: (context, color, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(_kItemRadius),
        ),
        child: child,
      ),
      child: content,
    );

    if (_focusHighlight && clickable) {
      item = CustomPaint(
        foregroundPainter: _FocusRingPainter(tokens),
        child: item,
      );
    }

    item = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _kItemMarginH,
        vertical: _kItemMarginV,
      ),
      child: item,
    );

    // The pill paints over the item (and, while it slides, over its
    // neighbors), in the accent color.
    item = CustomPaint(
      foregroundPainter: selected
          ? _PillPainter(
              animation: _pill,
              from: _pillFrom,
              rectFor: pillRect,
              color: tokens.accent,
            )
          : null,
      child: item,
    );

    item = FocusableActionDetector(
      enabled: clickable,
      actions: _actions,
      onShowFocusHighlight: (value) {
        if (value != _focusHighlight) setState(() => _focusHighlight = value);
      },
      mouseCursor: clickable && kIsWeb
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: MouseRegion(
        onEnter: (_) {
          if (!_hovered) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (_hovered) setState(() => _hovered = false);
        },
        child: Listener(
          onPointerDown: clickable ? _handlePointerDown : null,
          onPointerUp: _handlePointerEnd,
          onPointerCancel: _handlePointerEnd,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: clickable ? _activate : null,
            child: item,
          ),
        ),
      ),
    );

    if (compact && tooltip != null) {
      item = Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        waitDuration: const Duration(milliseconds: 400),
        preferBelow: false,
        verticalOffset: 0,
        margin: const EdgeInsetsDirectional.only(start: _kIconColumn + 12),
        decoration: BoxDecoration(
          color: tokens.overlayPane,
          borderRadius: BorderRadius.circular(_kItemRadius),
          border: Border.all(color: tokens.overlayStroke),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        textStyle: FluentTypography.caption.copyWith(color: tokens.textPrimary),
        padding: const EdgeInsets.fromLTRB(9, 6, 9, 8),
        child: item,
      );
    }

    return IgnorePointer(
      ignoring: !enabled,
      child: Semantics(
        container: true,
        button: clickable,
        enabled: enabled,
        onTap: clickable ? _activate : null,
        label: compact ? tooltip : null,
        child: item,
      ),
    );
  }
}

/// Paints the selection pill at its place in the item, or on its way there
/// from the previously selected item: the edge in front moves first and the
/// one behind catches up, so the pill stretches as it travels.
class _PillPainter extends CustomPainter {
  _PillPainter({
    required this.animation,
    required this.from,
    required this.rectFor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Rect? from;
  final Rect Function(Size size) rectFor;
  final Color color;

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  void paint(Canvas canvas, Size size) {
    final to = rectFor(size);
    final from = this.from;
    final t = animation.value;
    var rect = to;
    if (from != null && t < 1) {
      final lead = Curves.easeOutCubic.transform((t / 0.65).clamp(0.0, 1.0));
      final trail = Curves.easeInOutCubic.transform(
        ((t - 0.25) / 0.75).clamp(0.0, 1.0),
      );
      final down = to.center.dy >= from.center.dy;
      final top = _lerp(from.top, to.top, down ? trail : lead);
      final bottom = _lerp(from.bottom, to.bottom, down ? lead : trail);
      final left = _lerp(from.left, to.left, lead);
      rect = Rect.fromLTRB(
        left,
        math.min(top, bottom - _kPillWidth),
        left + _kPillWidth,
        bottom,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(_kPillRadius)),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_PillPainter oldDelegate) =>
      oldDelegate.from != from ||
      oldDelegate.color != color ||
      oldDelegate.animation != animation;
}

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter(this.tokens);

  final FluentTokens tokens;

  @override
  void paint(Canvas canvas, Size size) =>
      paintFluentFocusRing(canvas, Offset.zero & size, _kItemRadius, tokens);

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      oldDelegate.tokens != tokens;
}

/// A group of the Windows pane: a NavigationViewItemHeader (hidden in the
/// compact rail) over its items. Internal.
class FluentNavigationSection extends StatelessWidget {
  const FluentNavigationSection({
    super.key,
    required this.title,
    required this.tiles,
    this.titlePadding,
  });

  final Widget? title;
  final List<Widget> tiles;
  final EdgeInsetsGeometry? titlePadding;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final tokens = _tokensOf(context);
    final compact = FluentPaneModeScope.compactOf(context);
    final title = this.title;
    final style = theme.titleTextStyle ?? FluentTypography.bodyStrong;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null && !compact)
          Semantics(
            container: true,
            header: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _kHeaderHeight),
              child: Padding(
                padding:
                    titlePadding ??
                    const EdgeInsetsDirectional.only(
                      start: _kHeaderStart,
                      end: _kHeaderStart,
                    ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: DefaultTextStyle(
                    style: style.copyWith(
                      color:
                          style.color ??
                          theme.tileDescriptionTextColor ??
                          tokens.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: title,
                  ),
                ),
              ),
            ),
          ),
        ...tiles,
      ],
    );
  }
}

/// A NavigationViewItemSeparator between two sections of the Windows pane
/// (1px, 3 above and 4 below). A section header already separates in the
/// open pane, so the line only shows before an untitled section, or in the
/// compact rail, which hides the headers. Internal.
class FluentPaneSeparator extends StatelessWidget {
  const FluentPaneSeparator({super.key, required this.beforeTitle});

  /// The next section has a title.
  final bool beforeTitle;

  @override
  Widget build(BuildContext context) {
    if (beforeTitle && !FluentPaneModeScope.compactOf(context)) {
      return const SizedBox(height: 4);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 3, bottom: 4),
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: _tokensOf(context).divider),
      ),
    );
  }
}

/// The top of the Windows pane. The open pane shows the split view's title
/// like the Windows Settings title bar ("Settings" in Caption, with the
/// back button when the view can be left); the compact rail has room for
/// the back button and the pane toggle ("hamburger") button only. Internal.
class FluentPaneHeader extends StatelessWidget {
  const FluentPaneHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onTogglePane,
  });

  final Widget? title;
  final VoidCallback? onBack;

  /// Opens or closes the pane over the content. Null for the open pane
  /// of wide windows, which has no toggle.
  final VoidCallback? onTogglePane;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final tokens = _tokensOf(context);
    final compact = FluentPaneModeScope.compactOf(context);
    final title = this.title;
    final onBack = this.onBack;
    final onTogglePane = this.onTogglePane;

    Widget titleText() => DefaultTextStyle(
      style: FluentTypography.caption.copyWith(
        color: theme.settingsTileTextColor ?? tokens.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: Semantics(header: true, child: title!),
    );

    final rows = <Widget>[];
    if (onTogglePane == null) {
      // The open pane of a wide window.
      rows.add(
        SizedBox(
          height: kFluentPaneHeaderHeight,
          child: Row(
            children: [
              if (onBack != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: _kItemMarginH,
                    end: _kItemMarginH,
                  ),
                  child: FluentSubtleButton(
                    semanticLabel: settingsBackLabel(context),
                    onPressed: onBack,
                    glyph: FluentGlyph.back,
                  ),
                )
              else
                const SizedBox(width: 16),
              if (title != null) Expanded(child: titleText()),
            ],
          ),
        ),
      );
    } else {
      if (onBack != null) {
        rows.add(
          SizedBox(
            height: kFluentPaneHeaderHeight,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: _kItemMarginH),
                child: FluentSubtleButton(
                  semanticLabel: settingsBackLabel(context),
                  onPressed: onBack,
                  glyph: FluentGlyph.back,
                ),
              ),
            ),
          ),
        );
      }
      rows.add(
        Padding(
          padding: EdgeInsets.only(
            top: onBack == null ? 6 : 0,
            bottom: _kItemMarginV,
          ),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: _kItemMarginH,
                    end: _kItemMarginH,
                  ),
                  child: FluentSubtleButton(
                    semanticLabel: settingsMenuLabel(context),
                    onPressed: onTogglePane,
                    glyph: FluentGlyph.menu,
                  ),
                ),
                if (!compact && title != null) Expanded(child: titleText()),
              ],
            ),
          ),
        ),
      );
    }
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}

/// The glyphs of the Windows pane buttons (Segoe Fluent Icons), drawn.
enum FluentGlyph {
  /// E72B Back.
  back,

  /// E700 GlobalNavigationButton.
  menu,
}

/// A 40x36 subtle button of the Windows pane and title bar (back, pane
/// toggle): transparent at rest, SubtleFillSecondary on hover,
/// SubtleFillTertiary with a secondary glyph while pressed. Internal.
class FluentSubtleButton extends StatefulWidget {
  const FluentSubtleButton({
    super.key,
    required this.semanticLabel,
    required this.onPressed,
    required this.glyph,
  });

  final String semanticLabel;
  final VoidCallback onPressed;
  final FluentGlyph glyph;

  @override
  State<FluentSubtleButton> createState() => _FluentSubtleButtonState();
}

class _FluentSubtleButtonState extends State<FluentSubtleButton> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focusHighlight = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final tokens = _tokensOf(context);
    final primary = theme.settingsTileTextColor ?? tokens.textPrimary;
    final secondary = theme.tileDescriptionTextColor ?? tokens.textSecondary;
    final fill = _pressed
        ? tokens.navItemPressed
        : _hovered
        ? tokens.navItemSelected
        : null;
    Widget button = Container(
      width: 40,
      height: 36,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(_kItemRadius),
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: const Size.square(16),
        painter: _GlyphPainter(
          glyph: widget.glyph,
          color: _pressed ? secondary : primary,
          textDirection: Directionality.of(context),
        ),
      ),
    );
    if (_focusHighlight) {
      button = CustomPaint(
        foregroundPainter: _FocusRingPainter(tokens),
        child: button,
      );
    }
    return Semantics(
      container: true,
      button: true,
      label: widget.semanticLabel,
      onTap: widget.onPressed,
      child: FocusableActionDetector(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => widget.onPressed(),
          ),
        },
        onShowFocusHighlight: (value) {
          if (value != _focusHighlight) {
            setState(() => _focusHighlight = value);
          }
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            onTap: widget.onPressed,
            child: button,
          ),
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({
    required this.glyph,
    required this.color,
    required this.textDirection,
  });

  final FluentGlyph glyph;
  final Color color;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final scale = size.shortestSide / 16;
    canvas.scale(scale);
    switch (glyph) {
      case FluentGlyph.back:
        if (textDirection == TextDirection.rtl) {
          canvas.translate(16, 0);
          canvas.scale(-1, 1);
        }
        canvas.drawPath(
          Path()
            ..moveTo(14.5, 8)
            ..lineTo(1.5, 8)
            ..moveTo(7.5, 2)
            ..lineTo(1.5, 8)
            ..lineTo(7.5, 14),
          paint,
        );
      case FluentGlyph.menu:
        for (final y in [3.5, 8.0, 12.5]) {
          canvas.drawLine(Offset(1.5, y), Offset(14.5, y), paint);
        }
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) =>
      oldDelegate.glyph != glyph ||
      oldDelegate.color != color ||
      oldDelegate.textDirection != textDirection;
}

/// The side margins of a Windows page's content in a page [width] wide:
/// the Fluent `SettingsList` column (at most 1000, 24 margins, 16 below
/// 641).
double fluentPageSideMargin(double width) =>
    math.max(width < 641 ? 16.0 : 24.0, (width - 1000) / 2);

/// The title of a Windows Settings page: Title (28/36 semibold) over the
/// content column, 24 from the top. A page opened from another page shows
/// a breadcrumb ("System › Display") whose parent crumbs are in the
/// secondary color and go back to their page when clicked. A first page
/// with somewhere to go back to gets a back button before its title.
/// Internal.
class FluentPageHeader extends StatelessWidget {
  const FluentPageHeader({
    super.key,
    required this.title,
    this.parents = const <SettingsPageTrailEntry>[],
    this.onBack,
    this.actions,
  });

  final Widget? title;
  final List<SettingsPageTrailEntry> parents;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final tokens = _tokensOf(context);
    final primary = theme.settingsTileTextColor ?? tokens.textPrimary;
    final secondary = theme.tileDescriptionTextColor ?? tokens.textSecondary;
    final onBack = parents.isEmpty ? this.onBack : null;
    final actions = this.actions;
    final title = this.title;

    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = fluentPageSideMargin(constraints.maxWidth);
          return Padding(
            padding: EdgeInsetsDirectional.only(
              start: onBack == null ? side : math.max(0, side - 8),
              end: side,
              top: 24,
            ),
            child: Row(
              children: [
                if (onBack != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: FluentSubtleButton(
                      semanticLabel: settingsBackLabel(context),
                      onPressed: onBack,
                      glyph: FluentGlyph.back,
                    ),
                  ),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final parent in parents) ...[
                          _Crumb(
                            entry: parent,
                            color: secondary,
                            hoverColor: primary,
                          ),
                          _BreadcrumbChevron(color: secondary),
                        ],
                        if (title != null)
                          DefaultTextStyle(
                            style: kFluentTitleStyle.copyWith(color: primary),
                            child: title,
                          ),
                      ],
                    ),
                  ),
                ),
                if (actions != null && actions.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: actions),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A parent page in the breadcrumb: secondary text that turns primary on
/// hover and goes back to its page when clicked.
class _Crumb extends StatefulWidget {
  const _Crumb({
    required this.entry,
    required this.color,
    required this.hoverColor,
  });

  final SettingsPageTrailEntry entry;
  final Color color;
  final Color hoverColor;

  @override
  State<_Crumb> createState() => _CrumbState();
}

class _CrumbState extends State<_Crumb> {
  bool _hovered = false;
  bool _focusHighlight = false;

  void _activate() => popToSettingsPage(context, widget.entry);

  @override
  Widget build(BuildContext context) {
    Widget crumb = DefaultTextStyle(
      style: kFluentTitleStyle.copyWith(
        color: _hovered || _focusHighlight ? widget.hoverColor : widget.color,
      ),
      child: widget.entry.title,
    );
    if (_focusHighlight) {
      crumb = CustomPaint(
        foregroundPainter: _FocusRingPainter(_tokensOf(context)),
        child: crumb,
      );
    }
    return Semantics(
      container: true,
      button: true,
      onTap: _activate,
      child: FocusableActionDetector(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => _activate(),
          ),
        },
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (value) {
          if (value != _focusHighlight) {
            setState(() => _focusHighlight = value);
          }
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: _activate,
            child: crumb,
          ),
        ),
      ),
    );
  }
}

/// The breadcrumb separator: a thin chevron, 7 wide and 12 tall, mirrored
/// in right-to-left layouts, with the spacing Windows Settings leaves
/// around it.
class _BreadcrumbChevron extends StatelessWidget {
  const _BreadcrumbChevron({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 19, end: 17),
      child: CustomPaint(
        size: const Size(7, 36),
        painter: _BreadcrumbChevronPainter(
          color: color,
          textDirection: Directionality.of(context),
        ),
      ),
    );
  }
}

class _BreadcrumbChevronPainter extends CustomPainter {
  const _BreadcrumbChevronPainter({
    required this.color,
    required this.textDirection,
  });

  final Color color;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    // Centered on the capitals, which sit a little above the line's middle.
    final top = (size.height - 12) / 2 + 1;
    if (textDirection == TextDirection.rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    canvas.drawPath(
      Path()
        ..moveTo(0.75, top + 0.75)
        ..lineTo(6.25, top + 6)
        ..lineTo(0.75, top + 11.25),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_BreadcrumbChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.textDirection != textDirection;
}

/// The two panes of a Windows style split view between 641 and 1007 wide:
/// the compact icon rail next to the content, which opens over the content
/// (the NavigationView "LeftCompact" mode). Internal.
///
/// While open, the pane is [openWidth] wide on the acrylic fallback color
/// with a shadow and rounded end corners; a click outside it or Escape
/// closes it ([onDismiss]).
class FluentCompactPaneLayout extends StatefulWidget {
  const FluentCompactPaneLayout({
    super.key,
    required this.open,
    required this.railWidth,
    required this.openWidth,
    required this.onDismiss,
    required this.pane,
    required this.detail,
  });

  final bool open;
  final double railWidth;
  final double openWidth;
  final VoidCallback onDismiss;
  final Widget pane;
  final Widget detail;

  @override
  State<FluentCompactPaneLayout> createState() =>
      _FluentCompactPaneLayoutState();
}

class _FluentCompactPaneLayoutState extends State<FluentCompactPaneLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: widget.open ? 1 : 0,
  )..addStatusListener((_) => setState(() {}));

  @override
  void didUpdateWidget(FluentCompactPaneLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != oldWidget.open) {
      final reduceMotion =
          MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      if (reduceMotion) {
        _controller.value = widget.open ? 1 : 0;
      } else if (widget.open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _tokensOf(context);
    final closed = _controller.status == AnimationStatus.dismissed;
    final openWidth = math.max(widget.railWidth, widget.openWidth);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final endCorner = BorderRadiusDirectional.horizontal(
      end: const Radius.circular(8),
    ).resolve(Directionality.of(context));

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (widget.open) widget.onDismiss();
        },
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              children: [
                SizedBox(width: widget.railWidth),
                Expanded(child: widget.detail),
              ],
            ),
          ),
          // A click outside the open pane closes it (light dismiss).
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !widget.open,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onTap: widget.onDismiss,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = kFluentFastOutSlowIn.transform(_controller.value);
                final width =
                    widget.railWidth + (openWidth - widget.railWidth) * t;
                return Container(
                  width: width,
                  clipBehavior: closed ? Clip.none : Clip.antiAlias,
                  decoration: closed
                      ? null
                      : BoxDecoration(
                          color: tokens.overlayPane,
                          borderRadius: endCorner,
                          border: BorderDirectional(
                            end: BorderSide(color: tokens.overlayStroke),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.14 * t),
                              blurRadius: 16,
                              offset: Offset(isRtl ? -2 : 2, 0),
                            ),
                          ],
                        ),
                  child: child,
                );
              },
              child: FluentPaneModeScope(
                compact: closed,
                child: OverflowBox(
                  alignment: AlignmentDirectional.topStart,
                  minWidth: closed ? widget.railWidth : openWidth,
                  maxWidth: closed ? widget.railWidth : openWidth,
                  child: widget.pane,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
