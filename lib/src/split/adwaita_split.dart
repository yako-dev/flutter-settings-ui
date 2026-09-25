import 'package:flutter/gestures.dart' show kPrimaryButton;
import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/split/settings_page_header.dart';
import 'package:settings_ui/src/tiles/platforms/adwaita_settings_switch.dart';
import 'package:settings_ui/src/tiles/platforms/adwaita_settings_tile.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

// GNOME Settings 51 (libadwaita 1.10 `AdwNavigationSplitView` with a
// `.navigation-sidebar` list), measured against real GNOME 48/50 captures.
// All sizes are logical pixels (1 CSS px).

/// Flat header bars: the sidebar's and the content's.
const double kAdwaitaHeaderBarHeight = 46;

/// Panel rows of the GNOME Settings sidebar are 43 tall, 2 apart.
const double kAdwaitaSidebarRowHeight = 43;

/// `.navigation-sidebar > row` margin: 0 6 2 6.
const double _kRowMarginH = 6;
const double _kRowMarginBottom = 2;
const double _kRowRadius = 9;

/// The 16px symbolic icon starts 20 from the sidebar edge (6 margin + 14),
/// the label at 48 (12 after the icon).
const double _kRowPadding = 14;
const double _kIconSize = 16;
const double _kIconGap = 12;

/// `.navigation-sidebar` list padding: 6 top, 4 bottom.
const double kAdwaitaSidebarPaddingTop = 6;
const double kAdwaitaSidebarPaddingBottom = 4;

/// Flat header bar buttons: 34x34 with 9 corners, 6 from the bar's edge.
const double _kButtonSize = 34;
const double _kBarPadding = 6;

/// Body text: 11pt (14.67px) on an 18px line; bold for titles.
const double _kBodyFontSize = 44 / 3;

const TextStyle _kLabelStyle = TextStyle(
  fontSize: _kBodyFontSize,
  fontWeight: FontWeight.w400,
  height: 18 / _kBodyFontSize,
  leadingDistribution: TextLeadingDistribution.even,
);

const TextStyle _kTitleStyle = TextStyle(
  fontSize: _kBodyFontSize,
  fontWeight: FontWeight.w700,
  height: 18 / _kBodyFontSize,
  leadingDistribution: TextLeadingDistribution.even,
);

/// Row backgrounds, as shares of the foreground color: hover 7%, selected
/// 10%, selected and hovered 13%, pressed 16% (selected and pressed 19%).
const double _kHover = 0.07;
const double _kSelectedHover = 0.13;
const double _kPressed = 0.16;
const double _kSelectedPressed = 0.19;

/// `--accent-color`; focus rings use it at 50%.
const Color _kAccentLight = Color(0xFF0461BE);
const Color _kAccentDark = Color(0xFF81D0FF);

/// The GNOME foreground color in light mode, `rgba(0, 0, 6, 0.8)`.
const Color _kForegroundLight = Color.fromRGBO(0, 0, 6, 0.8);

Color _foregroundOf(SettingsThemeData theme) =>
    theme.settingsTileTextColor ?? _kForegroundLight;

Color _share(Color foreground, double share) =>
    foreground.withValues(alpha: foreground.a * share);

/// `--sidebar-border-color`, the 1px line on the sidebar's content side.
Color adwaitaSidebarBorderColor(SettingsThemeData theme) => adwaitaIsDark(theme)
    ? const Color.fromRGBO(0, 0, 6, 0.36)
    : const Color.fromRGBO(0, 0, 6, 0.07);

/// A row of the GNOME Settings sidebar: a tile in the list pane of a GNOME
/// style split view (also with one pane, where the sidebar is the first
/// page). Internal.
///
/// 43 tall with 6px side margins and 9px corners, a 16px symbolic icon and
/// the 14.67px label, which stays in the foreground color when selected.
/// Hover 7%, selected 10% (a neutral grey, not the accent), selected and
/// hovered 13%, pressed 16% of the foreground; a 2px accent focus ring.
/// Like GNOME rows, a switch row toggles when the row is clicked.
/// Descriptions and values are not shown.
class AdwaitaSidebarRow extends StatefulWidget {
  const AdwaitaSidebarRow({
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

  @override
  State<AdwaitaSidebarRow> createState() => _AdwaitaSidebarRowState();
}

class _AdwaitaSidebarRowState extends State<AdwaitaSidebarRow> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focusHighlight = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
  };

  bool get _isSwitch => widget.tileType == SettingsTileType.switchTile;

  bool get _activatable =>
      widget.enabled &&
      (_isSwitch ? widget.onToggle != null : widget.onPressed != null);

  void _activate() {
    if (!_activatable) return;
    if (_isSwitch) {
      widget.onToggle!(!widget.initialValue);
    } else {
      widget.onPressed!(context);
    }
  }

  void _setPressed(bool value) {
    if (mounted && _pressed != value) setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(AdwaitaSidebarRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_activatable) {
      _pressed = false;
      _hovered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final textScaler = MediaQuery.textScalerOf(context);
    final foreground = _foregroundOf(theme);
    final isDark = adwaitaIsDark(theme);
    final enabled = widget.enabled;
    final selected = widget.selected;
    final pressed = _activatable && _pressed;
    final hovered = _activatable && _hovered;

    final Color background;
    if (selected) {
      background = pressed
          ? _share(foreground, _kSelectedPressed)
          : hovered
          ? _share(foreground, _kSelectedHover)
          : (theme.selectedTileColor ?? _share(foreground, 0.10));
    } else {
      background = pressed
          ? _share(foreground, _kPressed)
          : hovered
          ? _share(foreground, _kHover)
          : _share(foreground, 0);
    }

    final textColor = !enabled
        ? (theme.inactiveTitleColor ?? _share(foreground, 0.5))
        : selected
        ? (theme.selectedTileTextColor ?? foreground)
        : foreground;
    final iconColor = !enabled
        ? textColor
        : selected
        ? (theme.selectedTileIconColor ?? foreground)
        : (theme.leadingIconsColor ?? foreground);

    final row = Row(
      children: [
        if (widget.leading != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: _kIconGap),
            child: IconTheme.merge(
              data: IconThemeData(color: iconColor, size: _kIconSize),
              child: widget.leading!,
            ),
          ),
        Expanded(
          child: DefaultTextStyle(
            style: (theme.tileTextStyle ?? _kLabelStyle).copyWith(
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: widget.title,
          ),
        ),
        if (widget.trailing != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: IconTheme.merge(
              data: IconThemeData(color: iconColor, size: _kIconSize),
              child: DefaultTextStyle(
                style: _kLabelStyle.copyWith(color: textColor),
                child: widget.trailing!,
              ),
            ),
          ),
        if (_isSwitch)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            // The row takes the focus and the clicks, like `AdwSwitchRow`.
            child: ExcludeFocus(
              child: AdwaitaSettingsSwitch(
                value: widget.initialValue,
                onChanged: enabled ? widget.onToggle : null,
                activeTrackColor: widget.activeSwitchColor,
                brightness: isDark ? Brightness.dark : Brightness.light,
              ),
            ),
          ),
      ],
    );

    final accent = isDark ? _kAccentDark : _kAccentLight;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final box = AnimatedContainer(
      // Rows fade their hover and pressed backgrounds in 200 ms.
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 200),
      curve: const Cubic(0.25, 0.46, 0.45, 0.94),
      constraints: const BoxConstraints(minHeight: kAdwaitaSidebarRowHeight),
      padding: EdgeInsets.symmetric(
        horizontal: _kRowPadding,
        vertical: textScaler.scale(4),
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(_kRowRadius),
      ),
      foregroundDecoration: _focusHighlight && _activatable
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(_kRowRadius),
              border: Border.all(
                color: accent.withValues(alpha: 0.5),
                width: 2,
              ),
            )
          : null,
      child: row,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: _kRowMarginH,
        end: _kRowMarginH,
        bottom: _kRowMarginBottom,
      ),
      child: MergeSemantics(
        child: Semantics(
          button: !_isSwitch && widget.onPressed != null,
          enabled: enabled,
          onTap: _activatable ? _activate : null,
          child: IgnorePointer(
            ignoring: !enabled,
            child: FocusableActionDetector(
              enabled: _activatable,
              actions: _actions,
              onShowFocusHighlight: (value) {
                if (value != _focusHighlight) {
                  setState(() => _focusHighlight = value);
                }
              },
              child: MouseRegion(
                onEnter: (_) {
                  if (_activatable && !_hovered) {
                    setState(() => _hovered = true);
                  }
                },
                onExit: (_) {
                  if (_hovered) setState(() => _hovered = false);
                },
                child: Listener(
                  // GTK shows `:active` as soon as the button goes down.
                  onPointerDown: _activatable
                      ? (event) {
                          if (event.buttons == kPrimaryButton) {
                            _setPressed(true);
                          }
                        }
                      : null,
                  onPointerUp: (_) => _setPressed(false),
                  onPointerCancel: (_) => _setPressed(false),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    excludeFromSemantics: true,
                    onTap: _activatable ? _activate : null,
                    onTapCancel: () => _setPressed(false),
                    child: box,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A group of the GNOME sidebar: its rows, under a bold heading when it has
/// a title (as `AdwSidebar` sections do). GNOME Settings separates its
/// groups with lines ([AdwaitaSidebarSeparator]). Internal.
class AdwaitaSidebarSection extends StatelessWidget {
  const AdwaitaSidebarSection({
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
    final title = this.title;
    final style = theme.titleTextStyle ?? _kTitleStyle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Semantics(
            container: true,
            header: true,
            child: Padding(
              padding:
                  titlePadding ??
                  const EdgeInsetsDirectional.only(
                    start: _kRowMarginH + _kRowPadding,
                    end: _kRowMarginH + _kRowPadding,
                    top: 6,
                    bottom: 6,
                  ),
              child: DefaultTextStyle(
                style: style.copyWith(
                  color:
                      style.color ??
                      theme.titleTextColor ??
                      _foregroundOf(theme),
                ),
                child: title,
              ),
            ),
          ),
        ...tiles,
      ],
    );
  }
}

/// The line between two groups of the GNOME Settings sidebar: 1px of the
/// foreground at 15% with 6px margins, so rows on both sides of it are 58
/// apart (45 otherwise). Internal.
class AdwaitaSidebarSeparator extends StatelessWidget {
  const AdwaitaSidebarSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    return Padding(
      padding: const EdgeInsets.all(_kRowMarginH),
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: _share(_foregroundOf(theme), 0.15)),
      ),
    );
  }
}

/// A flat GNOME header bar: 46 tall and transparent, with the title in
/// bold in the middle, a back button (`go-previous-symbolic`) at the start
/// when [onBack] is set, and [actions] at the end. Used over the sidebar
/// (with the split view's title) and over each page. Internal.
class AdwaitaHeaderBar extends StatelessWidget {
  const AdwaitaHeaderBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  final Widget? title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final foreground = _foregroundOf(theme);
    final title = this.title;
    final actions = this.actions;
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kAdwaitaHeaderBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _kBarPadding),
          child: NavigationToolbar(
            leading: onBack == null
                ? null
                : Align(
                    widthFactor: 1,
                    child: AdwaitaFlatButton(
                      semanticLabel: settingsBackLabel(context),
                      onPressed: onBack!,
                      child: _GoPreviousIcon(color: foreground),
                    ),
                  ),
            middle: title == null
                ? null
                : Semantics(
                    header: true,
                    child: DefaultTextStyle(
                      style: _kTitleStyle.copyWith(color: foreground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: title,
                    ),
                  ),
            trailing: actions == null || actions.isEmpty
                ? null
                : Row(mainAxisSize: MainAxisSize.min, children: actions),
            middleSpacing: 6,
          ),
        ),
      ),
    );
  }
}

/// A flat 34x34 header bar button with 9px corners: the foreground at 7%
/// on hover and 16% while pressed, and the accent focus ring. Internal.
class AdwaitaFlatButton extends StatefulWidget {
  const AdwaitaFlatButton({
    super.key,
    required this.semanticLabel,
    required this.onPressed,
    required this.child,
  });

  final String semanticLabel;
  final VoidCallback onPressed;
  final Widget child;

  @override
  State<AdwaitaFlatButton> createState() => _AdwaitaFlatButtonState();
}

class _AdwaitaFlatButtonState extends State<AdwaitaFlatButton> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focusHighlight = false;

  void _setPressed(bool value) {
    if (mounted && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final foreground = _foregroundOf(theme);
    final accent = adwaitaIsDark(theme) ? _kAccentDark : _kAccentLight;
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
            child: Container(
              width: _kButtonSize,
              height: _kButtonSize,
              decoration: BoxDecoration(
                color: _pressed
                    ? _share(foreground, _kPressed)
                    : _hovered
                    ? _share(foreground, _kHover)
                    : null,
                borderRadius: BorderRadius.circular(_kRowRadius),
              ),
              foregroundDecoration: _focusHighlight
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(_kRowRadius),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    )
                  : null,
              alignment: Alignment.center,
              child: ExcludeSemantics(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

/// `go-previous-symbolic`: a 16px chevron drawn with a 2px round stroke,
/// mirrored in right-to-left layouts.
class _GoPreviousIcon extends StatelessWidget {
  const _GoPreviousIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(_kIconSize),
      painter: _GoPreviousPainter(
        color: color,
        mirrored: Directionality.of(context) == TextDirection.rtl,
      ),
    );
  }
}

class _GoPreviousPainter extends CustomPainter {
  const _GoPreviousPainter({required this.color, required this.mirrored});

  final Color color;
  final bool mirrored;

  @override
  void paint(Canvas canvas, Size size) {
    const points = [Offset(11, 2), Offset(5, 8), Offset(11, 14)];
    final scale = size.shortestSide / 16;
    canvas.drawPath(
      Path()..addPolygon([
        for (final p in points)
          Offset((mirrored ? 16 - p.dx : p.dx) * scale, p.dy * scale),
      ], false),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_GoPreviousPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.mirrored != mirrored;
}
