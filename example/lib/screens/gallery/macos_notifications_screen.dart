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

/// The top of a System Settings pane: the Liquid Glass back/forward capsule
/// (always shown; back works when there is a page to go back to) and the
/// pane title in 15pt semibold grey.
class _MacosToolbar extends StatelessWidget {
  const _MacosToolbar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = isDark ? const Color(0xD8FFFFFF) : const Color(0xD8000000);
    final canPop = Navigator.of(context).canPop();

    // On a phone the status bar sits over the top of the screen: draw the
    // toolbar's color behind it and the toolbar below it.
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      height: 52 + topInset,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: EdgeInsetsDirectional.only(start: 8, end: 20, top: topInset),
      child: Row(
        children: [
          Container(
            width: 73,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFFCFCFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0x1FFFFFFF)
                    : const Color(0x0F000000),
                width: 0.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                _ToolbarButton(
                  icon: CupertinoIcons.chevron_left,
                  tooltip: 'Back',
                  color: label,
                  onPressed: canPop
                      ? () => Navigator.of(context).maybePop()
                      : null,
                ),
                Container(
                  width: 1,
                  height: 16,
                  color: isDark
                      ? const Color(0x26FFFFFF)
                      : const Color(0xFFCACBCA),
                ),
                _ToolbarButton(
                  icon: CupertinoIcons.chevron_right,
                  tooltip: 'Forward',
                  color: label,
                  onPressed: null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              height: 19 / 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              // The toolbar title renders grey, not in the label color.
              color: isDark ? const Color(0xFFE9E9E9) : const Color(0xFF4C4C4C),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          minimumSize: const Size(36, 36),
          shape: const StadiumBorder(),
        ),
        icon: Icon(
          icon,
          size: 16,
          color: onPressed == null ? color.withValues(alpha: 0.25) : color,
        ),
      ),
    );
  }
}
