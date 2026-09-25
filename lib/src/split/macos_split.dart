import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/split/settings_page_header.dart';
import 'package:settings_ui/src/split/sidebar_keyboard.dart';
import 'package:settings_ui/src/tiles/platforms/macos_settings_switch.dart';
import 'package:settings_ui/src/tiles/platforms/macos_settings_tile.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

// The macOS 26/27 System Settings split view (a SwiftUI
// `NavigationSplitView`), measured on macOS 27. All sizes are in points.

/// The unified toolbar: the sidebar's top strip (where the traffic lights
/// sit) and the detail pane's title bar.
const double kMacosToolbarHeight = 52;

/// Sidebar rows (NSTableView rowHeight, "medium" sidebar size).
const double kMacosSidebarRowHeight = 32;

/// The selection is inset this far from both sidebar edges...
const double _kSelectionInset = 10;

/// ...with these corners.
const double _kSelectionRadius = 8;

/// Row content starts 16 from the sidebar edge (6 inside the selection).
const double _kContentInset = 6;

/// A 20pt icon at 19 (3 into the content) and the label at 46.
const double _kIconSize = 20;
const double _kIconStart = 3;
const double _kIconGap = 7;

/// Section headers: 11pt bold in a 19pt row, text at 14.
const double _kHeaderRowHeight = 19;
const double _kHeaderStart = 14;

/// Space between two sidebar sections, with or without a header.
const double kMacosSidebarSectionGap = 13;

/// The selection of a key window: [SettingsThemeData.selectedTileColor].
/// In an inactive window it turns grey (measured #D7D7D6 / #424742 on the
/// replica's glass; `unemphasizedSelectedContentBackgroundColor` is #DCDCDC /
/// #464646), and the label keeps its color.
const Color _kInactiveSelectionLight = Color(0xFFD7D7D7);
const Color _kInactiveSelectionDark = Color(0xFF464646);

/// Plain symbols (not the colored squircles of System Settings) take the
/// accent color, as SwiftUI sidebars draw them.
const Color _kSymbolTintLight = Color(0xFF0077FF);
const Color _kSymbolTintDark = Color(0xFF008FFF);

/// Section headers render in the tertiary label color.
const Color _kHeaderLight = Color(0xFFA0A0A0);
const Color _kHeaderDark = Color(0xFF5A5A5A);

/// The toolbar title renders grey, not in the label color.
const Color _kToolbarTitleLight = Color(0xFF4C4C4C);
const Color _kToolbarTitleDark = Color(0xFFE9E9E9);

/// `keyboardFocusIndicatorColor`.
const Color _kFocusLight = Color(0x800067F4);
const Color _kFocusDark = Color(0x801AA9FF);

/// 13pt body text, semibold when selected.
const TextStyle _kLabelStyle = kMacosBodyStyle;

/// Section headers: 11pt bold, set as tight as SwiftUI draws them.
const TextStyle _kHeaderStyle = TextStyle(
  fontSize: 11,
  height: 14 / 11,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.1,
);

/// The toolbar title: SF Pro Semibold 15.
const TextStyle _kToolbarTitleStyle = TextStyle(
  fontSize: 15,
  height: 19 / 15,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.2,
);

bool _isDark(BuildContext context) =>
    macosIsDark(context, SettingsTheme.of(context).themeData);

/// The hairline between the sidebar and the detail pane (0.5pt). The glass
/// sidebar's edge barely shows in System Settings; this keeps it as faint.
Color macosSidebarEdgeColor(SettingsThemeData theme) {
  final page = theme.settingsListBackground;
  final isDark =
      page != null &&
      ThemeData.estimateBrightnessForColor(page) == Brightness.dark;
  return isDark ? const Color(0x59000000) : const Color(0x0F000000);
}

/// Tracks whether the app's window is active (AppKit's key window), so the
/// sidebar selection can turn grey when it isn't. Internal.
///
/// Flutter reports [AppLifecycleState.inactive] when the app loses the
/// focus (on the web, when the browser window does).
class MacosWindowActivity extends StatefulWidget {
  const MacosWindowActivity({super.key, required this.child});

  final Widget child;

  /// Whether the window at [context] is active. True outside a
  /// [MacosWindowActivity].
  static bool isActiveOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_MacosWindowActiveScope>()
          ?.active ??
      true;

  @override
  State<MacosWindowActivity> createState() => _MacosWindowActivityState();
}

class _MacosWindowActivityState extends State<MacosWindowActivity>
    with WidgetsBindingObserver {
  late bool _active = _isActive(WidgetsBinding.instance.lifecycleState);

  static bool _isActive(AppLifecycleState? state) =>
      state == null || state == AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final active = _isActive(state);
    if (active != _active) setState(() => _active = active);
  }

  @override
  Widget build(BuildContext context) =>
      _MacosWindowActiveScope(active: _active, child: widget.child);
}

class _MacosWindowActiveScope extends InheritedWidget {
  const _MacosWindowActiveScope({required this.active, required super.child});

  final bool active;

  @override
  bool updateShouldNotify(_MacosWindowActiveScope oldWidget) =>
      active != oldWidget.active;
}

/// A row of the macOS System Settings sidebar: a tile in the list pane of a
/// macOS style split view. Internal.
///
/// 32pt tall, a 20pt icon and the 13pt label; the selected row is a
/// rounded rect inset 10pt, in the accent color with a white semibold label
/// while the window is active, grey otherwise. A plain [Icon] takes the
/// accent color (white on the accent). No hover highlight, like AppKit
/// sidebars. Descriptions and values are not shown.
class MacosSidebarItem extends StatefulWidget {
  const MacosSidebarItem({
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
    required this.opensPage,
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

  /// The tile opens a page, so the arrow keys select it.
  final bool opensPage;

  @override
  State<MacosSidebarItem> createState() => _MacosSidebarItemState();
}

class _MacosSidebarItemState extends State<MacosSidebarItem> {
  bool _focusHighlight = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
    SidebarSelectIntent: CallbackAction<SidebarSelectIntent>(
      onInvoke: (_) {
        if (widget.opensPage && !widget.selected) _activate();
        return null;
      },
    ),
  };

  bool get _canPress => widget.enabled && widget.onPressed != null;

  void _activate() {
    if (_canPress) widget.onPressed!(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final textScaler = MediaQuery.textScalerOf(context);
    final isDark = _isDark(context);
    final active = MacosWindowActivity.isActiveOf(context);
    final selected = widget.selected;
    final emphasized = selected && active;
    final enabled = widget.enabled;

    final Color? fill = !selected
        ? null
        : active
        ? theme.selectedTileColor
        : (isDark ? _kInactiveSelectionDark : _kInactiveSelectionLight);
    // AppKit draws sidebar labels vibrant: plain black or white.
    final label = theme.settingsTileTextColor?.withValues(alpha: 1);
    final Color? textColor = !enabled
        ? theme.inactiveTitleColor
        : emphasized
        ? (theme.selectedTileTextColor ?? label)
        : label;
    final Color? iconColor = !enabled
        ? theme.inactiveTitleColor
        : emphasized
        ? (theme.selectedTileIconColor ?? textColor)
        : (isDark ? _kSymbolTintDark : _kSymbolTintLight);

    final labelStyle = (theme.tileTextStyle ?? _kLabelStyle).copyWith(
      color: textColor,
      fontWeight: selected ? FontWeight.w600 : null,
    );

    final isSwitch = widget.tileType == SettingsTileType.switchTile;
    final row = Row(
      children: [
        if (widget.leading != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: _kIconStart,
              end: _kIconGap,
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: iconColor, size: _kIconSize),
              child: widget.leading!,
            ),
          ),
        Expanded(
          child: DefaultTextStyle(
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: widget.title,
          ),
        ),
        if (widget.trailing != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: IconTheme.merge(
              data: IconThemeData(color: textColor, size: 16),
              child: DefaultTextStyle(
                style: _kLabelStyle.copyWith(color: textColor),
                child: widget.trailing!,
              ),
            ),
          ),
        if (isSwitch)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: CupertinoTheme(
              data: CupertinoTheme.of(context).copyWith(
                brightness: isDark ? Brightness.dark : Brightness.light,
              ),
              child: ExcludeFocus(
                child: MacosSettingsSwitch(
                  value: widget.initialValue,
                  onChanged: enabled ? widget.onToggle : null,
                  activeTrackColor: widget.activeSwitchColor,
                ),
              ),
            ),
          ),
      ],
    );

    final focusColor = isDark ? _kFocusDark : _kFocusLight;
    final Widget item = Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kSelectionInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(_kSelectionRadius),
        ),
        position: DecorationPosition.background,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: _focusHighlight && _canPress
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(_kSelectionRadius),
                  border: Border.all(
                    color: focusColor,
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                )
              : const BoxDecoration(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMacosSidebarRowHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _kContentInset,
                vertical: textScaler.scale(4),
              ),
              child: row,
            ),
          ),
        ),
      ),
    );

    return IgnorePointer(
      ignoring: !enabled,
      child: Semantics(
        container: true,
        button: _canPress,
        enabled: enabled,
        selected: widget.semanticsSelected,
        child: FocusableActionDetector(
          enabled: _canPress,
          actions: _actions,
          onShowFocusHighlight: (value) {
            if (value != _focusHighlight) {
              setState(() => _focusHighlight = value);
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: !_canPress,
            onTap: _canPress ? _activate : null,
            child: item,
          ),
        ),
      ),
    );
  }
}

/// A group of the macOS sidebar: an optional 11pt bold header over its
/// rows. Sections are 13pt apart ([MacosSidebarSectionGap]). Internal.
class MacosSidebarSection extends StatelessWidget {
  const MacosSidebarSection({
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
    final textScaler = MediaQuery.textScalerOf(context);
    final isDark = _isDark(context);
    final title = this.title;
    final style = theme.titleTextStyle ?? _kHeaderStyle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Semantics(
            container: true,
            header: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _kHeaderRowHeight),
              child: Padding(
                padding:
                    titlePadding ??
                    EdgeInsetsDirectional.only(
                      start: _kHeaderStart,
                      end: _kHeaderStart,
                      top: textScaler.scale(3),
                      bottom: textScaler.scale(2),
                    ),
                child: DefaultTextStyle(
                  style: style.copyWith(
                    color:
                        style.color ?? (isDark ? _kHeaderDark : _kHeaderLight),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: title,
                ),
              ),
            ),
          ),
        ...tiles,
      ],
    );
  }
}

/// The 13pt space between two sections of the macOS sidebar. Internal.
class MacosSidebarSectionGap extends StatelessWidget {
  const MacosSidebarSectionGap({super.key});

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: kMacosSidebarSectionGap);
}

/// The top of the macOS sidebar: the 52pt strip under the (transparent)
/// title bar, where the traffic lights sit. With [onBack] (the split view
/// can be left), a round glass back button at its end, where SwiftUI puts
/// the sidebar button. Internal.
class MacosSidebarTopBar extends StatelessWidget {
  const MacosSidebarTopBar({super.key, required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kMacosToolbarHeight,
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: onBack == null
              ? null
              : Padding(
                  padding: const EdgeInsetsDirectional.only(end: 7),
                  child: MacosNavigationCapsule(
                    onBack: onBack!,
                    showForward: false,
                  ),
                ),
        ),
      ),
    );
  }
}

/// The toolbar of a macOS System Settings pane: 52pt tall, the Liquid
/// Glass back/forward capsule when there is a page to go back to, and the
/// page title in 15pt semibold grey (at 20pt without the capsule, 13pt
/// after it). There is no large title in the content. Internal.
class MacosToolbar extends StatelessWidget {
  const MacosToolbar({
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
    final isDark = _isDark(context);
    final title = this.title;
    final actions = this.actions;
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kMacosToolbarHeight,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: onBack == null ? 20 : 8,
            end: 20,
          ),
          child: Row(
            children: [
              if (onBack != null) ...[
                MacosNavigationCapsule(onBack: onBack!),
                const SizedBox(width: 13),
              ],
              Expanded(
                child: title == null
                    ? const SizedBox.shrink()
                    : Semantics(
                        header: true,
                        // AppKit centers the title's text box (y 16.5, 19
                        // tall): 1pt above where Flutter puts the line.
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: DefaultTextStyle(
                            style: _kToolbarTitleStyle.copyWith(
                              color: isDark
                                  ? _kToolbarTitleDark
                                  : _kToolbarTitleLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: title,
                          ),
                        ),
                      ),
              ),
              if (actions != null && actions.isNotEmpty)
                Row(mainAxisSize: MainAxisSize.min, children: actions),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Liquid Glass back/forward capsule of the System Settings toolbar:
/// 73x36 with `‹` and `›` split by a hairline (forward stays disabled), or a
/// 36pt circle with only `‹`. Internal.
class MacosNavigationCapsule extends StatelessWidget {
  const MacosNavigationCapsule({
    super.key,
    required this.onBack,
    this.showForward = true,
  });

  final VoidCallback onBack;
  final bool showForward;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final isDark = _isDark(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    // Toolbar glyphs render in plain black or white; disabled ones at 30%.
    final label = (theme.settingsTileTextColor ?? const Color(0xD8000000))
        .withValues(alpha: 1);
    final disabled = label.withValues(alpha: 0.3);
    return Container(
      width: showForward ? 73 : 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFFCFCFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0x24FFFFFF) : const Color(0x21000000),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x12000000),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _CapsuleButton(
              label: settingsBackLabel(context),
              onPressed: onBack,
              isDark: isDark,
              child: _MacosToolbarChevron(color: label, pointsLeft: !isRtl),
            ),
          ),
          if (showForward) ...[
            Container(
              width: 1,
              height: 20,
              color: isDark ? const Color(0x26FFFFFF) : const Color(0x33000000),
            ),
            Expanded(
              child: _CapsuleButton(
                label: 'Forward',
                onPressed: null,
                isDark: isDark,
                child: _MacosToolbarChevron(color: disabled, pointsLeft: isRtl),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CapsuleButton extends StatefulWidget {
  const _CapsuleButton({
    required this.label,
    required this.onPressed,
    required this.isDark,
    required this.child,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDark;
  final Widget child;

  @override
  State<_CapsuleButton> createState() => _CapsuleButtonState();
}

class _CapsuleButtonState extends State<_CapsuleButton> {
  bool _pressed = false;
  bool _focusHighlight = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = widget.onPressed;
    return Semantics(
      container: true,
      button: true,
      enabled: onPressed != null,
      label: widget.label,
      onTap: onPressed,
      child: FocusableActionDetector(
        enabled: onPressed != null,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => onPressed?.call(),
          ),
        },
        onShowFocusHighlight: (value) {
          if (value != _focusHighlight) {
            setState(() => _focusHighlight = value);
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapDown: onPressed == null ? null : (_) => _setPressed(true),
          onTapUp: onPressed == null ? null : (_) => _setPressed(false),
          onTapCancel: onPressed == null ? null : () => _setPressed(false),
          onTap: onPressed,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: _pressed
                  ? (widget.isDark
                        ? const Color(0x1FFFFFFF)
                        : const Color(0x14000000))
                  : null,
              borderRadius: BorderRadius.circular(18),
              border: _focusHighlight
                  ? Border.all(
                      color: widget.isDark ? _kFocusDark : _kFocusLight,
                      width: 3,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: ExcludeSemantics(child: widget.child),
          ),
        ),
      ),
    );
  }
}

/// The toolbar's `chevron.left` / `chevron.right`: 8x14pt of ink with a
/// 2pt round stroke.
class _MacosToolbarChevron extends StatelessWidget {
  const _MacosToolbarChevron({required this.color, required this.pointsLeft});

  final Color color;
  final bool pointsLeft;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(8, 14),
      painter: _ToolbarChevronPainter(color: color, pointsLeft: pointsLeft),
    );
  }
}

class _ToolbarChevronPainter extends CustomPainter {
  const _ToolbarChevronPainter({required this.color, required this.pointsLeft});

  final Color color;
  final bool pointsLeft;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.0;
    const inset = stroke / 2;
    double x(double fromLeft) => pointsLeft ? fromLeft : size.width - fromLeft;
    canvas.drawPath(
      Path()
        ..moveTo(x(size.width - inset), inset)
        ..lineTo(x(inset), size.height / 2)
        ..lineTo(x(size.width - inset), size.height - inset),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ToolbarChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointsLeft != pointsLeft;
}
