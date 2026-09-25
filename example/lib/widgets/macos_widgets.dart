import 'package:material_ui/material_ui.dart';

/// The colored rounded-square icon of a macOS System Settings row: a white
/// glyph on a squircle with a light top-to-bottom gradient.
///
/// Pass it as a `SettingsTile.leading`. System Settings uses 24pt badges in
/// its lists (rows with one are 48pt tall) and 20pt ones in the sidebar.
class MacosIconBadge extends StatelessWidget {
  const MacosIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final Color color;
  final double size;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(size * 0.25),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, Colors.white, 0.15)!, color],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.62, color: iconColor),
    );
  }
}

/// The value of a macOS pop-up button in a settings row: the selected item
/// in the label color, then a 20pt circle with `chevron.up.chevron.down`.
///
/// Pass it as a `SettingsTile.trailing`.
class MacosPopupValue extends StatelessWidget {
  const MacosPopupValue(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = isDark ? const Color(0xD8FFFFFF) : const Color(0xD8000000);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        const SizedBox(width: 12),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0x12FFFFFF) : const Color(0x14000000),
          ),
          child: CustomPaint(painter: _UpDownChevronPainter(label)),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _UpDownChevronPainter extends CustomPainter {
  const _UpDownChevronPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - 3, c.dy - 1.5)
        ..lineTo(c.dx, c.dy - 4.5)
        ..lineTo(c.dx + 3, c.dy - 1.5)
        ..moveTo(c.dx - 3, c.dy + 1.5)
        ..lineTo(c.dx, c.dy + 4.5)
        ..lineTo(c.dx + 3, c.dy + 1.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(_UpDownChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}
