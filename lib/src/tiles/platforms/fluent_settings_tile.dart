import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/tiles/platforms/fluent_settings_switch.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/utils/fluent_tokens.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

// CommunityToolkit SettingsCard (SettingsCard.xaml), adjusted to what the
// Windows Settings app draws. All sizes are in effective pixels.

/// Windows Settings cards are at least 68 inside their 1px borders, so 70
/// outside (the Toolkit's SettingsCard is 68 outside).
const double _kMinHeight = 70;

/// A compact card is as tall as a SettingsExpander item.
const double _kCompactMinHeight = 52;
const double _kPadding = 16;
const double _kBorderWidth = 1;
const double _kRadius = 4;

/// Below this card width the content moves under the header.
const double _kWrapThreshold = 476;

/// Below this card width the header icon is hidden too.
const double _kWrapNoIconThreshold = 286;

const double _kIconSize = 20;
const EdgeInsetsDirectional _kIconMargin = EdgeInsetsDirectional.only(
  start: 2,
  end: 20,
);
const double _kHeaderPanelEndMargin = 24;
const double _kWrappedRowSpacing = 8;

/// Space between the value, the trailing widget and the switch. 12 is the
/// gap between a ToggleSwitch and its On/Off text.
const double _kValueTrailingGap = 8;
const double _kTrailingSwitchGap = 12;

/// The action icon (E974 ChevronRightMed) is at most 13x13, 14 after the
/// content.
const double _kChevronSize = 13;
const double _kChevronMargin = 14;

/// [foreground] over [background], rounded to 8 bits per channel so the
/// default colors come out exactly as the flat WinUI values.
Color _blend(Color foreground, Color background) =>
    Color(Color.alphaBlend(foreground, background).toARGB32());

/// A setting on its own card, like a Windows 11 Settings row (a Windows
/// Community Toolkit `SettingsCard`).
class FluentSettingsTile extends StatefulWidget {
  const FluentSettingsTile({
    required this.tileType,
    required this.leading,
    required this.title,
    required this.titleDescription,
    required this.description,
    required this.onPressed,
    required this.onToggle,
    required this.value,
    required this.initialValue,
    required this.activeSwitchColor,
    required this.enabled,
    required this.trailing,
    this.compact = false,
    this.titlePadding,
    this.leadingPadding,
    this.trailingPadding,
    this.descriptionPadding,
    this.titleDescriptionPadding,
    super.key,
  });

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget? title;
  final Widget? titleDescription;
  final Widget? description;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final Widget? value;
  final bool initialValue;
  final bool enabled;
  final bool compact;
  final Color? activeSwitchColor;
  final Widget? trailing;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? leadingPadding;
  final EdgeInsetsGeometry? trailingPadding;
  final EdgeInsetsGeometry? descriptionPadding;
  final EdgeInsetsGeometry? titleDescriptionPadding;

  @override
  State<FluentSettingsTile> createState() => _FluentSettingsTileState();
}

class _FluentSettingsTileState extends State<FluentSettingsTile> {
  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
  };

  bool _hovered = false;
  bool _pressed = false;
  bool _focusHighlight = false;

  /// The pointer that pressed the card, while it is down.
  int? _pressPointer;
  Offset _pressOrigin = Offset.zero;

  /// Pointers that went down on the switch. Like a WinUI control that
  /// handles the pointer, the switch does not press the card.
  final Set<int> _controlPointers = <int>{};

  /// A clickable card (WinUI `IsClickEnabled`): hover, press and keyboard
  /// focus only apply to these.
  bool get _clickable => widget.enabled && widget.onPressed != null;

  bool get _isSwitch => widget.tileType == SettingsTileType.switchTile;

  bool get _isNavigation => widget.tileType == SettingsTileType.navigationTile;

  @override
  void didUpdateWidget(FluentSettingsTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_clickable) {
      _pressed = false;
      _pressPointer = null;
    }
  }

  void _activate() {
    if (_clickable) widget.onPressed!.call(context);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!_clickable ||
        _pressPointer != null ||
        _controlPointers.contains(event.pointer)) {
      return;
    }
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons != kPrimaryMouseButton) {
      return;
    }
    _pressPointer = event.pointer;
    _pressOrigin = event.position;
    setState(() => _pressed = true);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pressPointer) return;
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final bool inside = box.size.contains(box.globalToLocal(event.position));
    // A finger that moves is scrolling. A mouse stays pressed until it
    // leaves the card.
    final bool scrolling =
        event.kind != PointerDeviceKind.mouse &&
        (event.position - _pressOrigin).distance >
            computeHitSlop(event.kind, null);
    if (!inside || scrolling) _release();
  }

  void _handlePointerEnd(PointerEvent event) {
    _controlPointers.remove(event.pointer);
    if (event.pointer == _pressPointer) _release();
  }

  void _release() {
    _pressPointer = null;
    if (_pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final SettingsThemeData theme = SettingsTheme.of(context).themeData;
    final FluentTokens tokens = FluentTokens.of(
      FluentTokens.brightnessOf(context),
    );
    final bool enabled = widget.enabled;
    final bool clickable = _clickable;
    final bool pressed = clickable && _pressed;
    final bool hovered = clickable && _hovered;

    // Card states from SettingsCard.xaml. The border sits over the page
    // (BackgroundSizing InnerBorderEdge), so its translucent colors are
    // flattened onto the page color.
    final Color card = theme.settingsSectionBackground ?? tokens.card;
    final Color page = theme.settingsListBackground ?? tokens.page;
    final Color background;
    final Color borderColor;
    Color? edgeColor;
    if (!enabled) {
      background = _blend(tokens.cardDisabledOverlay, card);
      borderColor = _blend(tokens.controlStroke, page);
    } else if (pressed) {
      background = theme.tileHighlightColor ?? tokens.cardPressed;
      borderColor = _blend(tokens.controlStroke, page);
    } else if (hovered) {
      background = _blend(tokens.cardHoverOverlay, card);
      borderColor = _blend(tokens.controlStroke, page);
      edgeColor = _blend(tokens.controlStrokeSecondary, page);
    } else {
      background = card;
      borderColor = theme.dividerColor ?? tokens.cardStroke;
    }

    // Foregrounds. Pressing turns the header and icon secondary.
    final Color primary = theme.settingsTileTextColor ?? tokens.textPrimary;
    final Color secondary =
        theme.tileDescriptionTextColor ?? tokens.textSecondary;
    final Color disabledTitle = theme.inactiveTitleColor ?? tokens.textDisabled;
    final Color disabledSubtitle =
        theme.inactiveSubtitleColor ?? tokens.textDisabled;
    final Color iconColor = theme.leadingIconsColor ?? primary;

    final _TileParts parts = _TileParts(
      leading: widget.leading == null
          ? null
          : Padding(
              padding: widget.leadingPadding ?? _kIconMargin,
              child: IconTheme.merge(
                data: IconThemeData(
                  size: _kIconSize,
                  color: !enabled
                      ? disabledTitle
                      : pressed
                      ? secondary
                      : iconColor,
                ),
                child: widget.leading!,
              ),
            ),
      header: _buildHeader(
        theme: theme,
        titleColor: !enabled
            ? disabledTitle
            : pressed
            ? secondary
            : primary,
        descriptionColor: enabled ? secondary : disabledSubtitle,
      ),
      value: widget.value == null || _isSwitch
          ? null
          : DefaultTextStyle(
              style: FluentTypography.body.copyWith(
                color: enabled
                    ? (theme.trailingTextColor ?? secondary)
                    : disabledSubtitle,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: widget.value!,
            ),
      trailing: widget.trailing == null
          ? null
          : Padding(
              padding:
                  widget.trailingPadding ??
                  EdgeInsetsDirectional.only(
                    start: widget.value != null && !_isSwitch
                        ? _kValueTrailingGap
                        : 0,
                    end: _isSwitch ? _kTrailingSwitchGap : 0,
                  ),
              child: IconTheme.merge(
                data: IconThemeData(
                  size: _kIconSize,
                  color: enabled ? iconColor : disabledTitle,
                ),
                child: DefaultTextStyle(
                  style: FluentTypography.body.copyWith(
                    color: enabled ? primary : disabledTitle,
                  ),
                  child: widget.trailing!,
                ),
              ),
            ),
      control: !_isSwitch
          ? null
          : Listener(
              onPointerDown: (event) => _controlPointers.add(event.pointer),
              child: FluentSettingsSwitch(
                value: widget.initialValue,
                onChanged: enabled ? widget.onToggle : null,
                activeTrackColor: widget.activeSwitchColor,
              ),
            ),
      chevron: !_isNavigation
          ? null
          : Padding(
              padding: const EdgeInsetsDirectional.only(start: _kChevronMargin),
              child: CustomPaint(
                size: const Size.square(_kChevronSize),
                painter: _ChevronPainter(
                  color: enabled ? iconColor : disabledTitle,
                  textDirection: Directionality.of(context),
                ),
              ),
            ),
    );

    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final double verticalPadding = widget.compact ? _kPadding / 2 : _kPadding;

    Widget tile = TweenAnimationBuilder<Color?>(
      // Background changes fade in 83 ms (BrushTransition).
      tween: ColorTween(end: background),
      duration: reduceMotion ? Duration.zero : kFluentFasterDuration,
      builder: (context, color, child) => CustomPaint(
        painter: _CardPainter(
          background: color ?? background,
          borderColor: borderColor,
          edgeColor: edgeColor,
          edgeAtBottom: tokens == FluentTokens.light,
          focusTokens: _focusHighlight && clickable ? tokens : null,
        ),
        child: child,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: widget.compact ? _kCompactMinHeight : _kMinHeight,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _kPadding + _kBorderWidth,
            vertical: verticalPadding + _kBorderWidth,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => _layout(
              parts,
              cardWidth: constraints.maxWidth + 2 * (_kPadding + _kBorderWidth),
              contentWidth: constraints.maxWidth,
            ),
          ),
        ),
      ),
    );

    tile = FocusableActionDetector(
      enabled: clickable,
      actions: _actions,
      onShowFocusHighlight: (bool value) {
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
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerEnd,
          onPointerCancel: _handlePointerEnd,
          child: GestureDetector(
            excludeFromSemantics: true,
            behavior: HitTestBehavior.opaque,
            onTap: clickable ? _activate : null,
            child: tile,
          ),
        ),
      ),
    );

    // A switch tile reads as the switch ("Wi-Fi, switch, on"). A switch tile
    // that also opens a page keeps its switch as a separate node.
    final bool isButton = widget.onPressed != null;
    final bool mergeAll = !_isSwitch || widget.onPressed == null;
    Widget semantics = Semantics(
      container: !mergeAll,
      button: isButton,
      enabled: isButton || !enabled ? enabled : null,
      onTap: clickable ? _activate : null,
      child: tile,
    );
    if (mergeAll) semantics = MergeSemantics(child: semantics);

    return IgnorePointer(ignoring: !enabled, child: semantics);
  }

  Widget _buildHeader({
    required SettingsThemeData theme,
    required Color titleColor,
    required Color descriptionColor,
  }) {
    final TextStyle descriptionStyle =
        (theme.tileDescriptionTextStyle ?? FluentTypography.caption).copyWith(
          color: descriptionColor,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: widget.titlePadding ?? EdgeInsets.zero,
          child: DefaultTextStyle(
            style: (theme.tileTextStyle ?? FluentTypography.body).copyWith(
              color: titleColor,
            ),
            child: widget.title ?? const SizedBox.shrink(),
          ),
        ),
        if (widget.titleDescription != null)
          Padding(
            padding: widget.titleDescriptionPadding ?? EdgeInsets.zero,
            child: DefaultTextStyle(
              style: descriptionStyle,
              child: widget.titleDescription!,
            ),
          ),
        if (widget.description != null)
          Padding(
            padding: widget.descriptionPadding ?? EdgeInsets.zero,
            child: DefaultTextStyle(
              style: descriptionStyle,
              child: widget.description!,
            ),
          ),
      ],
    );
  }

  /// Lays the parts out like the SettingsCard grid: icon, header, content,
  /// chevron in a row; or, in narrow cards, the content under the header.
  Widget _layout(
    _TileParts parts, {
    required double cardWidth,
    required double contentWidth,
  }) {
    final bool wrapped = cardWidth < _kWrapThreshold;
    final Widget? leading = cardWidth < _kWrapNoIconThreshold
        ? null
        : parts.leading;
    // Next to the header the value takes at most half the row, like the
    // iOS style. Under the header it can take the whole row.
    final Widget? content = parts.content(
      maxValueWidth: wrapped ? null : contentWidth / 2,
    );

    if (!wrapped) {
      return Row(
        children: [
          ?leading,
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                end: _kHeaderPanelEndMargin,
              ),
              child: parts.header,
            ),
          ),
          ?content,
          ?parts.chevron,
        ],
      );
    }

    final Widget body;
    if (leading == null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          parts.header,
          if (content != null) ...[
            const SizedBox(height: _kWrappedRowSpacing),
            content,
          ],
        ],
      );
    } else {
      // A table keeps the content in the header's column and the icon
      // centered on the header row.
      body = Table(
        columnWidths: const <int, TableColumnWidth>{
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [leading, parts.header]),
          if (content != null)
            TableRow(
              children: [
                const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.only(top: _kWrappedRowSpacing),
                  child: content,
                ),
              ],
            ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: body),
        ?parts.chevron,
      ],
    );
  }
}

/// The pieces of a card, built once and placed by the layout.
class _TileParts {
  const _TileParts({
    required this.leading,
    required this.header,
    required this.value,
    required this.trailing,
    required this.control,
    required this.chevron,
  });

  final Widget? leading;
  final Widget header;
  final Widget? value;
  final Widget? trailing;
  final Widget? control;
  final Widget? chevron;

  /// The card content: value text, trailing widget and switch, in that
  /// order. Null when there is none.
  ///
  /// With [maxValueWidth] the value is capped at that width (the row is then
  /// laid out with unbounded width); without it the value is flexible.
  Widget? content({required double? maxValueWidth}) {
    if (value == null && trailing == null && control == null) return null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value != null)
          if (maxValueWidth == null)
            Flexible(child: value!)
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxValueWidth),
              child: value,
            ),
        ?trailing,
        ?control,
      ],
    );
  }
}

class _CardPainter extends CustomPainter {
  const _CardPainter({
    required this.background,
    required this.borderColor,
    required this.edgeColor,
    required this.edgeAtBottom,
    required this.focusTokens,
  });

  final Color background;
  final Color borderColor;

  /// ControlElevationBorderBrush: the hovered card's border is darker along
  /// its bottom edge in light mode and lighter along its top edge in dark
  /// mode, fading into [borderColor] over 3 px.
  final Color? edgeColor;
  final bool edgeAtBottom;
  final FluentTokens? focusTokens;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect outer = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_kRadius),
    );
    canvas.drawRRect(outer, Paint()..color = background);

    final Paint border = Paint();
    if (edgeColor != null) {
      final double edge = edgeAtBottom ? rect.bottom : rect.top;
      border.shader = ui.Gradient.linear(
        Offset(0, edge),
        Offset(0, edgeAtBottom ? edge - 3 : edge + 3),
        [edgeColor!, borderColor],
        const [0.33, 1.0],
      );
    } else {
      border.color = borderColor;
    }
    canvas.drawDRRect(outer, outer.deflate(_kBorderWidth), border);

    if (focusTokens != null) {
      paintFluentFocusRing(canvas, rect, _kRadius, focusTokens!);
    }
  }

  @override
  bool shouldRepaint(_CardPainter oldDelegate) =>
      oldDelegate.background != background ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.edgeColor != edgeColor ||
      oldDelegate.edgeAtBottom != edgeAtBottom ||
      oldDelegate.focusTokens != focusTokens;
}

/// The Segoe Fluent Icons E974 (ChevronRightMed) glyph at 13 px: a thin
/// chevron, mirrored in right-to-left layouts.
class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color, required this.textDirection});

  final Color color;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.shortestSide / _kChevronSize;
    canvas.save();
    if (textDirection == TextDirection.rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    canvas.scale(scale);
    canvas.drawPath(
      Path()
        ..moveTo(5, 2.75)
        ..lineTo(8.75, 6.5)
        ..lineTo(5, 10.25),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.textDirection != textDirection;
}
