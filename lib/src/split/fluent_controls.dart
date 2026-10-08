import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/split/sidebar_button.dart';
import 'package:settings_ui/src/utils/fluent_tokens.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

// What the pane, the page header and the overlay of the Windows style split
// view share: the theme resources, the focus visual and the subtle button.

/// ControlCornerRadius.
const double kFluentControlRadius = 4;

/// The WinUI theme resources for [context].
FluentTokens fluentTokensOf(BuildContext context) =>
    FluentTokens.of(FluentTokens.brightnessOf(context));

/// [child] with the WinUI keyboard focus visual around it.
Widget fluentFocusRing(FluentTokens tokens, Widget child) =>
    CustomPaint(foregroundPainter: _FocusRingPainter(tokens), child: child);

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter(this.tokens);

  final FluentTokens tokens;

  @override
  void paint(Canvas canvas, Size size) => paintFluentFocusRing(
    canvas,
    Offset.zero & size,
    kFluentControlRadius,
    tokens,
  );

  @override
  bool shouldRepaint(_FocusRingPainter oldDelegate) =>
      oldDelegate.tokens != tokens;
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
class FluentSubtleButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final tokens = fluentTokensOf(context);
    final primary = theme.settingsTileTextColor ?? tokens.textPrimary;
    final secondary = theme.tileDescriptionTextColor ?? tokens.textSecondary;
    final textDirection = Directionality.of(context);
    return SidebarButton(
      semanticLabel: semanticLabel,
      onPressed: onPressed,
      builder: (context, states) {
        final button = Container(
          width: 40,
          height: 36,
          decoration: BoxDecoration(
            color: states.pressed
                ? tokens.navItemPressed
                : states.hovered
                ? tokens.navItemSelected
                : null,
            borderRadius: BorderRadius.circular(kFluentControlRadius),
          ),
          alignment: Alignment.center,
          child: CustomPaint(
            size: const Size.square(16),
            painter: _GlyphPainter(
              glyph: glyph,
              color: states.pressed ? secondary : primary,
              textDirection: textDirection,
            ),
          ),
        );
        return states.focused ? fluentFocusRing(tokens, button) : button;
      },
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
