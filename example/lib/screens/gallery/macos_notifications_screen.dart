import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:example/widgets/macos_widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// A replica of the Notifications pane of macOS 27 System Settings.
class MacosNotificationsScreen extends StatefulWidget {
  const MacosNotificationsScreen({super.key});

  @override
  State<MacosNotificationsScreen> createState() =>
      _MacosNotificationsScreenState();
}

class _MacosNotificationsScreenState extends State<MacosNotificationsScreen> {
  bool whenSleeping = false;
  bool whenLocked = true;
  bool whenMirroring = false;
  bool playSound = true;

  static const _apps = <(String, IconData, Color, String)>[
    ('App Store', CupertinoIcons.app_badge_fill, Color(0xFF1E88F5), 'Badges'),
    ('Calendar', CupertinoIcons.calendar, Color(0xFFFF3B30), 'Alerts'),
    (
      'FaceTime',
      CupertinoIcons.video_camera_solid,
      Color(0xFF30C552),
      'Badges, Sounds, Banners',
    ),
    (
      'Find My',
      CupertinoIcons.location_fill,
      Color(0xFF34C759),
      'Sounds, Banners',
    ),
    ('Home', CupertinoIcons.house_fill, Color(0xFFFF9500), 'Banners'),
    (
      'Mail',
      CupertinoIcons.mail_solid,
      Color(0xFF1E88F5),
      'Badges, Sounds, Banners',
    ),
    (
      'Messages',
      CupertinoIcons.chat_bubble_fill,
      Color(0xFF30C552),
      'Badges, Sounds, Banners',
    ),
    ('Reminders', CupertinoIcons.list_bullet, Color(0xFFFF9500), 'Off'),
    (
      'Screen Time',
      CupertinoIcons.hourglass,
      Color(0xFF7D5CF0),
      'Sounds, Banners',
    ),
    ('Wallet', CupertinoIcons.creditcard_fill, Color(0xFF1C1C1E), 'Banners'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _MacosToolbar(title: 'Notifications'),
          Expanded(
            child: SettingsList(
              platform: DevicePlatform.macOS,
              sections: [
                SettingsSection(
                  title: const Text('Notification Center'),
                  tiles: [
                    SettingsTile(
                      title: const Text('Show previews'),
                      trailing: const MacosPopupValue('When Unlocked'),
                    ),
                    SettingsTile.navigation(
                      title: const Text('Summarize notifications'),
                      value: const Text('Off'),
                      onPressed: (_) {},
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Allow notifications'),
                  tiles: [
                    SettingsTile.switchTile(
                      title: const Text('When the display is sleeping'),
                      initialValue: whenSleeping,
                      onToggle: (value) => setState(() => whenSleeping = value),
                    ),
                    SettingsTile.switchTile(
                      title: const Text('When the screen is locked'),
                      initialValue: whenLocked,
                      onToggle: (value) => setState(() => whenLocked = value),
                    ),
                    SettingsTile.switchTile(
                      title: const Text(
                        'When mirroring or sharing the display',
                      ),
                      initialValue: whenMirroring,
                      onToggle: (value) =>
                          setState(() => whenMirroring = value),
                    ),
                  ],
                ),
                SettingsSection(
                  tiles: [
                    SettingsTile.switchTile(
                      title: const Text('Play sound for notifications'),
                      initialValue: playSound,
                      onToggle: (value) => setState(() => playSound = value),
                      description: const Text(
                        'Apps can still play their own sounds when this is '
                        'off.',
                      ),
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Application Notifications'),
                  tiles: [
                    for (final (name, icon, color, summary) in _apps)
                      SettingsTile.navigation(
                        leading: MacosIconBadge(icon: icon, color: color),
                        title: Text(name),
                        titleDescription: Text(summary),
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
}

/// The top of a System Settings pane: the pane title in 15pt semibold on the
/// window background, and a back button when there is a page to go back to.
class _MacosToolbar extends StatelessWidget {
  const _MacosToolbar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = isDark ? const Color(0xD8FFFFFF) : const Color(0xD8000000);
    final canPop = Navigator.of(context).canPop();

    return Container(
      height: 52,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsetsDirectional.only(start: 12, end: 20),
      child: Row(
        children: [
          if (canPop)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 10),
              child: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                style: IconButton.styleFrom(
                  fixedSize: const Size(36, 36),
                  minimumSize: const Size(36, 36),
                  backgroundColor: isDark
                      ? const Color(0x14FFFFFF)
                      : const Color(0x0D000000),
                ),
                icon: Icon(CupertinoIcons.chevron_left, size: 15, color: label),
              ),
            )
          else
            const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              height: 19 / 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: label,
            ),
          ),
        ],
      ),
    );
  }
}
