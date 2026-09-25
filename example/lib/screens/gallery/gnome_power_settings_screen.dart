import 'package:example/utils/launch_options.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// A replica of the Power panel of GNOME Settings 48 to 51 on a laptop, in
/// the Linux (libadwaita) style. Since GNOME 48 the panel has two pages,
/// General and Power Saving, picked with a view switcher in the header bar.
class GnomePowerSettingsScreen extends StatefulWidget {
  const GnomePowerSettingsScreen({super.key});

  @override
  State<GnomePowerSettingsScreen> createState() =>
      _GnomePowerSettingsScreenState();
}

enum _PowerPage { general, powerSaving }

enum _PowerMode { performance, balanced, powerSaver }

class _GnomePowerSettingsScreenState extends State<GnomePowerSettingsScreen> {
  _PowerPage page = LaunchOptions.tab == 'power-saving'
      ? _PowerPage.powerSaving
      : _PowerPage.general;
  _PowerMode powerMode = _PowerMode.balanced;
  bool showBatteryPercentage = false;
  bool dimScreen = true;
  bool automaticPowerSaver = true;
  bool automaticScreenBlank = true;
  bool suspendOnBattery = true;
  bool suspendWhenPluggedIn = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF222226)
          : const Color(0xFFFAFAFB),
      body: Column(
        children: [
          _GnomeHeaderBar(
            isDark: isDark,
            center: _ViewSwitcher(
              isDark: isDark,
              selected: page.index,
              onSelected: (index) =>
                  setState(() => page = _PowerPage.values[index]),
              items: const [
                (Icons.battery_charging_full_outlined, 'General'),
                (Icons.eco_outlined, 'Power Saving'),
              ],
            ),
          ),
          Expanded(
            child: SettingsList(
              key: ValueKey(page),
              platform: DevicePlatform.linux,
              sections: switch (page) {
                _PowerPage.general => _generalPage(),
                _PowerPage.powerSaving => _powerSavingPage(),
              },
            ),
          ),
        ],
      ),
    );
  }

  List<AbstractSettingsSection> _generalPage() => [
    SettingsSection(
      title: const Text('Battery Level'),
      tiles: [
        const CustomSettingsTile(
          child: _BatteryLevel(level: 0.44, remaining: '55 minutes remaining'),
        ),
      ],
    ),
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
      title: const Text('General'),
      tiles: [
        SettingsTile(
          title: const Text('Power Button Behavior'),
          trailing: const _ComboValue('Suspend'),
          onPressed: (_) {},
        ),
        SettingsTile.switchTile(
          title: const Text('Show Battery Percentage'),
          description: const Text('Show exact charge level in the top bar'),
          initialValue: showBatteryPercentage,
          onToggle: (value) => setState(() => showBatteryPercentage = value),
        ),
      ],
    ),
  ];

  List<AbstractSettingsSection> _powerSavingPage() => [
    SettingsSection(
      tiles: [
        SettingsTile.switchTile(
          title: const Text('Dim Screen'),
          description: const Text(
            'Reduce screen brightness when the device is inactive',
          ),
          initialValue: dimScreen,
          onToggle: (value) => setState(() => dimScreen = value),
        ),
        SettingsTile.switchTile(
          title: const Text('Automatic Power Saver'),
          description: const Text(
            'Turn on power saver mode when battery power is low',
          ),
          initialValue: automaticPowerSaver,
          onToggle: (value) => setState(() => automaticPowerSaver = value),
        ),
      ],
    ),
    SettingsSection(
      tiles: [
        SettingsTile.switchTile(
          title: const Text('Automatic Screen Blank'),
          description: const Text(
            'Turn the screen off after a period of inactivity',
          ),
          initialValue: automaticScreenBlank,
          onToggle: (value) => setState(() => automaticScreenBlank = value),
        ),
        _delayTile('5 minutes', enabled: automaticScreenBlank),
      ],
    ),
    SettingsSection(
      title: const Text('Automatic Suspend'),
      tiles: [
        SettingsTile.switchTile(
          title: const Text('On Battery Power'),
          initialValue: suspendOnBattery,
          onToggle: (value) => setState(() => suspendOnBattery = value),
        ),
        _delayTile('15 minutes', enabled: suspendOnBattery),
      ],
    ),
    SettingsSection(
      tiles: [
        SettingsTile.switchTile(
          title: const Text('When Plugged In'),
          initialValue: suspendWhenPluggedIn,
          onToggle: (value) => setState(() => suspendWhenPluggedIn = value),
        ),
        _delayTile('15 minutes', enabled: suspendWhenPluggedIn),
      ],
    ),
  ];

  SettingsTile _powerModeTile(_PowerMode mode, String title, String subtitle) {
    return SettingsTile(
      leading: _Radio(selected: powerMode == mode),
      title: Text(title),
      description: Text(subtitle),
      onPressed: (_) => setState(() => powerMode = mode),
    );
  }

  /// A combo row that GNOME turns insensitive while its switch is off.
  SettingsTile _delayTile(String value, {required bool enabled}) {
    return SettingsTile(
      title: const Text('Delay'),
      trailing: _ComboValue(value),
      enabled: enabled,
      onPressed: (_) {},
    );
  }
}

/// A flat GNOME header bar: 46 tall, on the window background, with
/// [center] in the middle and a back button when the page can pop.
class _GnomeHeaderBar extends StatelessWidget {
  const _GnomeHeaderBar({required this.center, required this.isDark});

  final Widget center;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final foreground = _foreground(isDark);
    final canPop = Navigator.of(context).canPop();

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 46,
        child: Stack(
          alignment: Alignment.center,
          children: [
            center,
            if (canPop)
              PositionedDirectional(
                start: 6,
                child: _FlatButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: CustomPaint(
                    size: const Size.square(16),
                    painter: _GoPreviousPainter(
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

/// An `AdwViewSwitcher` in its wide form: equally wide 34-tall buttons with
/// an icon and a bold label, 4 apart. The selected one is on a pill of the
/// foreground at 10%.
class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({
    required this.items,
    required this.selected,
    required this.onSelected,
    required this.isDark,
  });

  final List<(IconData, String)> items;
  final int selected;
  final ValueChanged<int> onSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final foreground = _foreground(isDark);
    return IntrinsicWidth(
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Semantics(
                selected: i == selected,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => onSelected(i),
                    borderRadius: BorderRadius.circular(9),
                    splashFactory: NoSplash.splashFactory,
                    hoverColor: foreground.withValues(
                      alpha: foreground.a * 0.07,
                    ),
                    child: Ink(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: i == selected
                            ? foreground.withValues(alpha: foreground.a * 0.1)
                            : null,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(items[i].$1, size: 16, color: foreground),
                          const SizedBox(width: 6),
                          Text(
                            items[i].$2,
                            style: TextStyle(
                              fontSize: 44 / 3,
                              fontWeight: FontWeight.w700,
                              color: foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
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
/// the `pan-down-symbolic` arrow 9 px after it. In a Linux style tile the
/// text and the arrow get the row's foreground color and font.
class _ComboValue extends StatelessWidget {
  const _ComboValue(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        const SizedBox(width: 9),
        const AdwaitaPanDownIcon(),
      ],
    );
  }
}

/// The battery card of the Power panel: a level bar and the time left.
class _BatteryLevel extends StatelessWidget {
  const _BatteryLevel({required this.level, required this.remaining});

  final double level;
  final String remaining;

  @override
  Widget build(BuildContext context) {
    final foreground = SettingsTheme.of(
      context,
    ).themeData.settingsTileTextColor!;
    final style = TextStyle(
      fontSize: 44 / 3,
      height: 18 / (44 / 3),
      color: foreground,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // GtkLevelBar: an 8 px pill, the accent over the foreground at 15%.
          Container(
            height: 8,
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              color: foreground.withValues(alpha: foreground.a * 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: level,
              heightFactor: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF3584E4),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(remaining, style: style)),
              Text('${(level * 100).round()} %', style: style),
            ],
          ),
        ],
      ),
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

/// The `go-previous-symbolic` arrow of the back button: a 16 px chevron
/// drawn with a 2 px round stroke.
class _GoPreviousPainter extends CustomPainter {
  const _GoPreviousPainter(this.color, {this.mirrored = false});

  final Color color;
  final bool mirrored;

  @override
  void paint(Canvas canvas, Size size) {
    const points = [Offset(11, 2), Offset(5, 8), Offset(11, 14)];
    canvas.drawPath(
      Path()..addPolygon([
        for (final p in points) Offset(mirrored ? 16 - p.dx : p.dx, p.dy),
      ], false),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_GoPreviousPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.mirrored != mirrored;
}

Color _foreground(bool isDark) =>
    isDark ? Colors.white : const Color.fromRGBO(0, 0, 6, 0.8);
