import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// A replica of Windows 11 Settings > System > Display, in the Windows
/// (Fluent) style.
class WindowsDisplaySettingsScreen extends StatefulWidget {
  const WindowsDisplaySettingsScreen({super.key});

  @override
  State<WindowsDisplaySettingsScreen> createState() =>
      _WindowsDisplaySettingsScreenState();
}

class _WindowsDisplaySettingsScreenState
    extends State<WindowsDisplaySettingsScreen> {
  bool nightLight = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SettingsList(
          platform: DevicePlatform.windows,
          sections: [
            CustomSettingsSection(child: _PageTitle()),
            SettingsSection(
              // Settings puts the first header 52 below the title's capitals.
              titlePadding: const EdgeInsetsDirectional.only(
                start: 1,
                top: 19,
                bottom: 6,
              ),
              title: const Text('Brightness & color'),
              tiles: [
                SettingsTile.switchTile(
                  leading: const Icon(Icons.nightlight_outlined),
                  title: const Text('Night light'),
                  description: const Text(
                    'Use warmer colors to help block blue light',
                  ),
                  trailing: Text(nightLight ? 'On' : 'Off'),
                  initialValue: nightLight,
                  onToggle: (value) => setState(() => nightLight = value),
                  onPressed: (_) {},
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.hdr_on_outlined),
                  title: const Text('HDR'),
                  description: const Text('More about HDR'),
                  onPressed: (_) {},
                ),
              ],
            ),
            SettingsSection(
              title: const Text('Scale & layout'),
              tiles: [
                SettingsTile.navigation(
                  leading: const Icon(Icons.fit_screen_outlined),
                  title: const Text('Scale'),
                  description: const Text(
                    'Change the size of text, apps, and other items',
                  ),
                  value: const Text('150% (Recommended)'),
                  onPressed: (_) {},
                ),
                SettingsTile(
                  leading: const Icon(Icons.aspect_ratio_outlined),
                  title: const Text('Display resolution'),
                  description: const Text(
                    'Adjust the resolution to fit your connected display',
                  ),
                  value: const Text('1920 × 1080 (Recommended)'),
                ),
                SettingsTile(
                  leading: const Icon(Icons.screen_rotation_outlined),
                  title: const Text('Display orientation'),
                  value: const Text('Landscape'),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.desktop_windows_outlined),
                  title: const Text('Multiple displays'),
                  description: const Text(
                    'Choose the presentation mode for your displays',
                  ),
                  onPressed: (_) {},
                ),
              ],
            ),
            SettingsSection(
              title: const Text('Related settings'),
              tiles: [
                SettingsTile.navigation(
                  leading: const Icon(Icons.monitor_outlined),
                  title: const Text('Advanced display'),
                  description: const Text('Display information, refresh rate'),
                  onPressed: (_) {},
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.memory_outlined),
                  title: const Text('Graphics'),
                  onPressed: (_) {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The page title of Windows Settings: a breadcrumb in the Title style
/// (28/36 semibold), with a back button when there is a page to go back to.
class _PageTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final primary = theme.settingsTileTextColor;
    final secondary = theme.tileDescriptionTextColor;
    const title = TextStyle(
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          if (Navigator.of(context).canPop())
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: IconButton(
                tooltip: 'Back',
                icon: Icon(Icons.arrow_back, size: 16, color: primary),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'System',
                    style: title.copyWith(color: secondary),
                  ),
                  // A thin 7x12 chevron centered on the capitals: it sits
                  // on the baseline in a box as tall as the cap height.
                  WidgetSpan(
                    alignment: PlaceholderAlignment.aboveBaseline,
                    baseline: TextBaseline.alphabetic,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 19,
                        end: 17,
                      ),
                      child: CustomPaint(
                        size: const Size(7, 20),
                        painter: _BreadcrumbChevron(
                          color: secondary ?? const Color(0xFF5F5F5F),
                          textDirection: Directionality.of(context),
                        ),
                      ),
                    ),
                  ),
                  TextSpan(
                    text: 'Display',
                    style: title.copyWith(color: primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The breadcrumb separator: a thin chevron, 7 wide and 12 tall, centered
/// in its box and mirrored in right-to-left layouts.
class _BreadcrumbChevron extends CustomPainter {
  const _BreadcrumbChevron({required this.color, required this.textDirection});

  final Color color;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final double top = (size.height - 12) / 2;
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
  bool shouldRepaint(_BreadcrumbChevron oldDelegate) =>
      oldDelegate.color != color || oldDelegate.textDirection != textDirection;
}
