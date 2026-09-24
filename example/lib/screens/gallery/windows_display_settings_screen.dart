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
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: secondary,
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
