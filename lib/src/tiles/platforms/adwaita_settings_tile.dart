import 'package:flutter/gestures.dart' show kPrimaryButton;
import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/tiles/platforms/adwaita_settings_switch.dart';
import 'package:settings_ui/src/tiles/platforms/adwaita_symbolic_icons.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

// Rows of a GNOME boxed list (`AdwActionRow` in `.boxed-list`, libadwaita
// 1.10). All sizes are in logical pixels (1 CSS px).

/// One-line rows are 54 tall: 2 px row padding around a 50 px header.
const double kAdwaitaRowMinHeight = 54;

/// Compact rows keep half the space around the text: 9 px instead of 18 px.
const double kAdwaitaCompactRowMinHeight = 36;

/// Corner radius of a boxed list (a card).
const double kAdwaitaCardRadius = 12;

/// Text starts 14 px from the card edge: 2 px row padding + 12 px margin.
const double _kRowInset = 14;

/// Space above and below the title and subtitle: 2 px row padding + 6 px
/// title box margin.
const double _kTitleBoxPadding = 8;

/// `border-spacing` of the row header and of its suffixes.
const double _kSpacing = 6;

/// Prefix icons are 16 px symbolic icons, 12 px before the title.
const double _kIconSize = 16;
const double _kIconGap = 12;

/// Space between the title and the subtitle.
const double _kSubtitleGap = 3;

/// Rows fade their hover and pressed backgrounds in 200 ms, ease-out-quad.
const Duration _kHighlightDuration = Duration(milliseconds: 200);
const Curve _kHighlightCurve = Cubic(0.25, 0.46, 0.45, 0.94);

/// Body text: Adwaita Sans 11 pt (14.67 px) on an 18 px line.
const double _kBodyFontSize = 44 / 3;

/// Row subtitles use the `smaller` size (12.22 px) on a 15 px line.
const double _kSubtitleFontSize = _kBodyFontSize / 1.2;

const TextStyle _kTitleStyle = TextStyle(
  fontSize: _kBodyFontSize,
  fontWeight: FontWeight.w400,
  height: 18 / _kBodyFontSize,
  leadingDistribution: TextLeadingDistribution.even,
);

const TextStyle _kSubtitleStyle = TextStyle(
  fontSize: _kSubtitleFontSize,
  fontWeight: FontWeight.w400,
  height: 15 / _kSubtitleFontSize,
  leadingDistribution: TextLeadingDistribution.even,
);

/// The GNOME foreground color in light mode, `rgba(0, 0, 6, 0.8)`.
const Color _kForegroundLight = Color.fromRGBO(0, 0, 6, 0.8);

/// `--accent-color`, which focus rings use at 50%.
const Color _kAccentLight = Color(0xFF0461BE);
const Color _kAccentDark = Color(0xFF81D0FF);

/// Whether the theme has light text, so the dark GNOME colors apply. The
/// colors are the foreground color at different strengths, like
/// `currentColor` in the libadwaita stylesheet.
bool adwaitaIsDark(SettingsThemeData theme) =>
    (theme.settingsTileTextColor ?? _kForegroundLight).computeLuminance() > 0.5;

class AdwaitaSettingsTile extends StatefulWidget {
  const AdwaitaSettingsTile({
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
  final Widget title;
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
  State<AdwaitaSettingsTile> createState() => _AdwaitaSettingsTileState();
}

class _AdwaitaSettingsTileState extends State<AdwaitaSettingsTile> {
  bool _hovered = false;
  bool _pressed = false;
  bool _showFocusHighlight = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
  };

  bool get _isSwitch => widget.tileType == SettingsTileType.switchTile;

  bool get _hasAction =>
      _isSwitch ? widget.onToggle != null : widget.onPressed != null;

  /// Like `.activatable` rows: only these highlight, take focus and react.
  bool get _activatable => widget.enabled && _hasAction;

  /// A switch row toggles on a click anywhere in the row, like
  /// `AdwSwitchRow`. It never calls `onPressed`.
  void _activate() {
    if (!_activatable) return;
    if (_isSwitch) {
      widget.onToggle!(!widget.initialValue);
    } else {
      widget.onPressed!(context);
    }
  }

  void _setPressed(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(AdwaitaSettingsTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_activatable) {
      _pressed = false;
      _hovered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final info = AdwaitaSettingsTileAdditionalInfo.of(context);
    final isDark = adwaitaIsDark(theme);
    final enabled = widget.enabled;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final foreground = theme.settingsTileTextColor ?? _kForegroundLight;
    final iconColor = enabled
        ? theme.leadingIconsColor
        : theme.inactiveTitleColor;
    final titleStyle = (theme.tileTextStyle ?? _kTitleStyle).copyWith(
      color: enabled ? theme.settingsTileTextColor : theme.inactiveTitleColor,
    );
    final subtitleStyle = (theme.tileDescriptionTextStyle ?? _kSubtitleStyle)
        .copyWith(
          color: enabled
              ? theme.tileDescriptionTextColor
              : theme.inactiveSubtitleColor,
        );

    final pressedColor =
        theme.tileHighlightColor ??
        foreground.withValues(alpha: foreground.a * 0.08);
    // GNOME uses the foreground at 3% on hover and 8% while pressed.
    final hoverColor = pressedColor.withValues(alpha: pressedColor.a * 3 / 8);
    final idleColor = pressedColor.withValues(alpha: 0);
    final background = !_activatable
        ? idleColor
        : _pressed
        ? pressedColor
        : _hovered
        ? hoverColor
        : idleColor;

    final titleBox = Padding(
      padding: EdgeInsets.symmetric(
        vertical: widget.compact ? _kTitleBoxPadding / 2 : _kTitleBoxPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: widget.titlePadding ?? EdgeInsets.zero,
            child: DefaultTextStyle(style: titleStyle, child: widget.title),
          ),
          // GNOME rows have one subtitle, under the title. Both
          // descriptions go there, the title description first.
          if (widget.titleDescription != null)
            Padding(
              padding:
                  widget.titleDescriptionPadding ??
                  const EdgeInsets.only(top: _kSubtitleGap),
              child: DefaultTextStyle(
                style: subtitleStyle,
                child: widget.titleDescription!,
              ),
            ),
          if (widget.description != null)
            Padding(
              padding:
                  widget.descriptionPadding ??
                  const EdgeInsets.only(top: _kSubtitleGap),
              child: DefaultTextStyle(
                style: subtitleStyle,
                child: widget.description!,
              ),
            ),
        ],
      ),
    );

    Widget buildSuffixes(double maxValueWidth) {
      final suffixes = <Widget>[
        // A value is a dimmed label at the end of the row, like the
        // secondary label of a GNOME Settings row.
        if (!_isSwitch && widget.value != null)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxValueWidth),
            child: DefaultTextStyle(
              style: (theme.tileDescriptionTextStyle ?? _kTitleStyle).copyWith(
                color: enabled
                    ? theme.trailingTextColor
                    : theme.inactiveSubtitleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              child: widget.value!,
            ),
          ),
        // Text in `trailing` gets the title style, like a label suffix in
        // GTK, so a combo row value (text + AdwaitaPanDownIcon) needs no
        // style of its own.
        if (widget.trailing != null)
          Padding(
            padding: widget.trailingPadding ?? EdgeInsets.zero,
            child: DefaultTextStyle(
              style: titleStyle,
              child: IconTheme.merge(
                data: IconThemeData(color: iconColor, size: _kIconSize),
                child: widget.trailing!,
              ),
            ),
          ),
        if (_isSwitch)
          // The row takes the focus and the clicks, like `AdwSwitchRow`.
          ExcludeFocus(
            child: AdwaitaSettingsSwitch(
              value: widget.initialValue,
              onChanged: enabled ? widget.onToggle : null,
              activeTrackColor: enabled
                  ? widget.activeSwitchColor
                  : (theme.inactiveSwitchColor ?? widget.activeSwitchColor),
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
        if (widget.tileType == SettingsTileType.navigationTile)
          AdwaitaGoNextIcon(color: iconColor),
      ];
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final suffix in suffixes) ...[
            const SizedBox(width: _kSpacing),
            suffix,
          ],
        ],
      );
    }

    final row = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: widget.compact
            ? kAdwaitaCompactRowMinHeight
            : kAdwaitaRowMinHeight,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: _kRowInset),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              if (widget.leading != null)
                Padding(
                  padding:
                      widget.leadingPadding ??
                      const EdgeInsetsDirectional.only(end: _kIconGap),
                  child: IconTheme.merge(
                    data: IconThemeData(color: iconColor, size: _kIconSize),
                    child: widget.leading!,
                  ),
                ),
              Expanded(child: titleBox),
              // The value may take up to half the row, so neither a long
              // title nor a long value hides the other.
              buildSuffixes(constraints.maxWidth / 2),
            ],
          ),
        ),
      ),
    );

    final accent = isDark ? _kAccentDark : _kAccentLight;
    const corner = Radius.circular(kAdwaitaCardRadius);
    final highlighted = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : _kHighlightDuration,
      curve: _kHighlightCurve,
      decoration: BoxDecoration(color: background),
      // A 2 px accent ring just inside the row, following the card corners.
      foregroundDecoration: _showFocusHighlight && _activatable
          ? BoxDecoration(
              border: Border.all(
                color: accent.withValues(alpha: 0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.vertical(
                top: info.isFirst ? corner : Radius.zero,
                bottom: info.isLast ? corner : Radius.zero,
              ),
            )
          : null,
      child: row,
    );

    return MergeSemantics(
      child: Semantics(
        button: !_isSwitch && _hasAction,
        enabled: _hasAction ? enabled : null,
        onTap: _activatable ? _activate : null,
        child: IgnorePointer(
          ignoring: !enabled,
          child: FocusableActionDetector(
            enabled: _activatable,
            actions: _actions,
            onShowFocusHighlight: (value) {
              if (value != _showFocusHighlight) {
                setState(() => _showFocusHighlight = value);
              }
            },
            onShowHoverHighlight: (value) {
              if (value != _hovered) setState(() => _hovered = value);
            },
            child: Listener(
              // GTK shows `:active` as soon as the button goes down.
              onPointerDown: _activatable
                  ? (event) {
                      if (event.buttons == kPrimaryButton) _setPressed(true);
                    }
                  : null,
              onPointerUp: (_) => _setPressed(false),
              onPointerCancel: (_) => _setPressed(false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onTap: _activatable ? _activate : null,
                onTapCancel: () => _setPressed(false),
                child: highlighted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tells an [AdwaitaSettingsTile] where it is in its boxed list, so its
/// focus ring can follow the rounded corners of the card.
class AdwaitaSettingsTileAdditionalInfo extends InheritedWidget {
  const AdwaitaSettingsTileAdditionalInfo({
    super.key,
    required this.isFirst,
    required this.isLast,
    required super.child,
  });

  final bool isFirst;
  final bool isLast;

  @override
  bool updateShouldNotify(AdwaitaSettingsTileAdditionalInfo oldWidget) =>
      oldWidget.isFirst != isFirst || oldWidget.isLast != isLast;

  static AdwaitaSettingsTileAdditionalInfo of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<
              AdwaitaSettingsTileAdditionalInfo
            >() ??
        const AdwaitaSettingsTileAdditionalInfo(
          isFirst: true,
          isLast: true,
          child: SizedBox(),
        );
  }
}
