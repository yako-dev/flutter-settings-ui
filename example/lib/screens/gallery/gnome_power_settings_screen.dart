import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// A replica of the Power panel of GNOME Settings 51 on a desktop computer
/// (no battery), in the Linux (libadwaita) style.
class GnomePowerSettingsScreen extends StatefulWidget {
  const GnomePowerSettingsScreen({super.key});

  @override
  State<GnomePowerSettingsScreen> createState() =>
      _GnomePowerSettingsScreenState();
}

enum _PowerMode { performance, balanced, powerSaver }

class _GnomePowerSettingsScreenState extends State<GnomePowerSettingsScreen> {
  _PowerMode powerMode = _PowerMode.balanced;
  bool dimScreen = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF222226)
          : const Color(0xFFFAFAFB),
      body: Column(
        children: [
          _GnomeHeaderBar(title: 'Power', isDark: isDark),
          Expanded(
            child: SettingsList(
              platform: DevicePlatform.linux,
              sections: [
                SettingsSection(
                  title: const Text('Power Mode'),
                  tiles: [
                    _powerModeTile(
                      _PowerMode.performance,
                      'Performance',
                      'High performance and power usage',
                    ),
                    _powerModeTile(
                      _PowerMode.balanced,
                      'Balanced',
                      'Standard performance and power usage',
                    ),
                    _powerModeTile(
                      _PowerMode.powerSaver,
                      'Power Saver',
                      'Reduced performance and power usage',
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Power Saving'),
                  tiles: [
                    SettingsTile.switchTile(
                      title: const Text('Dim Screen'),
                      description: const Text(
                        'Reduce screen brightness when the computer is '
                        'inactive',
                      ),
                      initialValue: dimScreen,
                      onToggle: (value) => setState(() => dimScreen = value),
                    ),
                    SettingsTile(
                      title: const Text('Screen Blank'),
                      description: const Text(
                        'Turn the screen off after a period of inactivity',
                      ),
                      trailing: const _ComboValue('5 minutes'),
                      onPressed: (_) {},
                    ),
                    SettingsTile.navigation(
                      title: const Text('Automatic Suspend'),
                      description: const Text(
                        'Pause the computer after a period of inactivity',
                      ),
                      value: const Text('Off'),
                      onPressed: (_) {},
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('General'),
                  tiles: [
                    SettingsTile(
                      title: const Text('Power Button Behavior'),
                      trailing: const _ComboValue('Suspend'),
                      onPressed: (_) {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SettingsTile _powerModeTile(_PowerMode mode, String title, String subtitle) {
    return SettingsTile(
      leading: _Radio(selected: powerMode == mode),
      title: Text(title),
      description: Text(subtitle),
      onPressed: (_) => setState(() => powerMode = mode),
    );
  }
}

/// A flat GNOME header bar: 46 tall, on the window background, with the
/// page title in bold in the middle.
class _GnomeHeaderBar extends StatelessWidget {
  const _GnomeHeaderBar({required this.title, required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final foreground = isDark
        ? Colors.white
        : const Color.fromRGBO(0, 0, 6, 0.8);
    final canPop = Navigator.of(context).canPop();

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 44 / 3,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
            if (canPop)
              PositionedDirectional(
                start: 6,
                child: _FlatButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: CustomPaint(
                    size: const Size.square(16),
                    painter: _SymbolicPainter(
                      _Symbolic.goPrevious,
                      foreground,
                      mirrored: Directionality.of(context) == TextDirection.rtl,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A flat 34x34 header bar button with 9 px corners.
class _FlatButton extends StatelessWidget {
  const _FlatButton({
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9),
          splashFactory: NoSplash.splashFactory,
          child: SizedBox.square(dimension: 34, child: Center(child: child)),
        ),
      ),
    );
  }
}

/// The value of a GNOME combo row: the selected item at full strength, then
/// a `pan-down-symbolic` arrow.
class _ComboValue extends StatelessWidget {
  const _ComboValue(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 44 / 3,
            height: 18 / (44 / 3),
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        CustomPaint(
          size: const Size.square(16),
          painter: _SymbolicPainter(_Symbolic.panDown, color),
        ),
      ],
    );
  }
}

/// A GNOME radio button: a 20 px circle with a 2 px ring when off, filled
/// with the accent and a white dot when on.
class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color!;
    return CustomPaint(
      size: const Size.square(20),
      painter: _RadioPainter(selected: selected, foreground: color),
    );
  }
}

class _RadioPainter extends CustomPainter {
  const _RadioPainter({required this.selected, required this.foreground});

  final bool selected;
  final Color foreground;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    if (selected) {
      canvas.drawCircle(center, 10, Paint()..color = const Color(0xFF3584E4));
      canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);
    } else {
      canvas.drawCircle(
        center,
        9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = foreground.withValues(alpha: foreground.a * 0.15),
      );
    }
  }

  @override
  bool shouldRepaint(_RadioPainter oldDelegate) =>
      oldDelegate.selected != selected || oldDelegate.foreground != foreground;
}

enum _Symbolic { goPrevious, panDown }

/// Adwaita symbolic arrows: 16 px chevrons drawn with a 2 px round stroke.
class _SymbolicPainter extends CustomPainter {
  const _SymbolicPainter(this.icon, this.color, {this.mirrored = false});

  final _Symbolic icon;
  final Color color;
  final bool mirrored;

  @override
  void paint(Canvas canvas, Size size) {
    final points = switch (icon) {
      _Symbolic.goPrevious => const [
        Offset(11, 2),
        Offset(5, 8),
        Offset(11, 14),
      ],
      _Symbolic.panDown => const [Offset(2, 5), Offset(8, 11), Offset(14, 5)],
    };
    Offset map(Offset p) => Offset(mirrored ? 16 - p.dx : p.dx, p.dy);
    canvas.drawPath(
      Path()..addPolygon([for (final p in points) map(p)], false),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SymbolicPainter oldDelegate) =>
      oldDelegate.icon != icon ||
      oldDelegate.color != color ||
      oldDelegate.mirrored != mirrored;
}
