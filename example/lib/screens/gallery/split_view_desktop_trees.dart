import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:example/screens/gallery/demo_switches.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// The settings trees the split view demo shows in the macOS, Windows and
/// GNOME styles, shaped like System Settings, Windows Settings and GNOME
/// Settings. The values are made up.

Widget _page(List<AbstractSettingsSection> sections) =>
    SettingsList(sections: sections);

SettingsTile _nav(String title, {String? value, Widget? leading}) =>
    SettingsTile.navigation(
      leading: leading,
      title: Text(title),
      value: value == null ? null : Text(value),
      onPressed: (_) {},
    );

SettingsTile _value(String title, String value) =>
    SettingsTile(title: Text(title), value: Text(value));

/// A switch the demo keeps the state of (see [demoSwitch]).
SettingsTile _switch(
  String title, {
  bool value = false,
  Widget? leading,
  Widget? description,
  Widget? titleDescription,
}) => demoSwitch(
  title,
  value: value,
  leading: leading,
  description: description,
  titleDescription: titleDescription,
);

/// A page with switches that toggle.
class _SwitchPage extends StatefulWidget {
  const _SwitchPage(this.sections);

  /// Each section: an optional title and its switches (title, value).
  final List<(String?, List<(String, bool)>)> sections;

  @override
  State<_SwitchPage> createState() => _SwitchPageState();
}

class _SwitchPageState extends State<_SwitchPage> {
  late final Map<String, bool> _values = {
    for (final (_, switches) in widget.sections)
      for (final (title, value) in switches) title: value,
  };

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      sections: [
        for (final (title, switches) in widget.sections)
          SettingsSection(
            title: title == null ? null : Text(title),
            tiles: [
              for (final (name, _) in switches)
                SettingsTile.switchTile(
                  title: Text(name),
                  initialValue: _values[name]!,
                  onToggle: (value) => setState(() => _values[name] = value),
                ),
            ],
          ),
      ],
    );
  }
}

// macOS System Settings ---------------------------------------------------------

/// The 20pt colored squircles of the System Settings sidebar: a white SF
/// Symbol on the color, lighter at the top.
class MacSidebarIcon extends StatelessWidget {
  const MacSidebarIcon(this.icon, this.color, {super.key, this.size = 20});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final top = Color.lerp(color, const Color(0xFFFFFFFF), 0.18)!;
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(size / 4),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [top, color],
          ),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: const Color(0xFFFFFFFF), size: size * 0.62),
      ),
    );
  }
}

const _macBlue = Color(0xFF0A84FF);
const _macGrey = Color(0xFF8E8E93);
const _macGreen = Color(0xFF30C552);
const _macRed = Color(0xFFFF3B30);
const _macPink = Color(0xFFFF2D55);
const _macIndigo = Color(0xFF5E5CE6);
const _macBlack = Color(0xFF2C2C2E);
const _macCyan = Color(0xFF32ADE6);
const _macOrange = Color(0xFFFF9500);

SettingsTile _macCategory(
  String id,
  String title,
  IconData icon,
  Color color,
  WidgetBuilder builder,
) => SettingsTile.navigation(
  leading: MacSidebarIcon(icon, color),
  title: Text(title),
  destination: SettingsDestination(id: id, builder: demoLive(builder)),
);

List<AbstractSettingsSection> macSplitSections() => [
  SettingsSection(
    tiles: [
      _macCategory(
        'wifi',
        'Wi-Fi',
        CupertinoIcons.wifi,
        _macBlue,
        (_) => _page([
          SettingsSection(
            tiles: [
              _switch(
                'Wi-Fi',
                value: true,
                leading: const MacSidebarIcon(
                  CupertinoIcons.wifi,
                  _macBlue,
                  size: 24,
                ),
              ),
              _value('Network', 'Home'),
            ],
          ),
          SettingsSection(
            title: const Text('Known Networks'),
            tiles: [_nav('Home'), _nav('Office'), _nav('Café')],
          ),
          SettingsSection(
            tiles: [
              _nav('Ask to join networks', value: 'Notify'),
              _nav('Ask to join hotspots', value: 'Ask to Join'),
            ],
          ),
        ]),
      ),
      _macCategory(
        'bluetooth',
        'Bluetooth',
        CupertinoIcons.bluetooth,
        _macBlue,
        (_) => _page([
          SettingsSection(
            tiles: [
              _switch(
                'Bluetooth',
                value: true,
                description: const Text(
                  'This Mac is discoverable as "Mac" while Bluetooth '
                  'Settings is open.',
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('My Devices'),
            tiles: [
              _nav('Keyboard', value: 'Connected'),
              _nav('Headphones', value: 'Not Connected'),
            ],
          ),
        ]),
      ),
      _macCategory(
        'network',
        'Network',
        CupertinoIcons.globe,
        _macBlue,
        (_) => _page([
          SettingsSection(
            tiles: [
              _nav('Wi-Fi', value: 'Connected'),
              _nav('Thunderbolt Bridge', value: 'Not Connected'),
            ],
          ),
          SettingsSection(
            tiles: [
              _nav('Firewall', value: 'Inactive'),
              _nav('VPN Configurations'),
            ],
          ),
        ]),
      ),
      _macCategory(
        'battery',
        'Battery',
        CupertinoIcons.battery_full,
        _macGreen,
        (_) => _page([
          SettingsSection(
            tiles: [
              _value('Low Power Mode', 'Never'),
              _nav('Battery Health', value: 'Normal'),
            ],
          ),
          SettingsSection(tiles: [_nav('Options…')]),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _macCategory(
        'general',
        'General',
        CupertinoIcons.gear_alt_fill,
        _macGrey,
        (_) => _macGeneralPage(),
      ),
      _macCategory(
        'accessibility',
        'Accessibility',
        CupertinoIcons.person_crop_circle,
        _macBlue,
        (_) => _page([
          SettingsSection(
            title: const Text('Vision'),
            tiles: [
              _nav('VoiceOver', value: 'Off'),
              _nav('Zoom', value: 'Off'),
              _nav('Display'),
              _nav('Motion'),
            ],
          ),
          SettingsSection(
            title: const Text('Hearing'),
            tiles: [_nav('Audio'), _nav('Captions')],
          ),
        ]),
      ),
      _macCategory(
        'appearance',
        'Appearance',
        CupertinoIcons.circle_lefthalf_fill,
        _macBlack,
        (_) => _page([
          SettingsSection(
            tiles: [
              _value('Appearance', 'Auto'),
              _value('Accent color', 'Multicolor'),
              _value('Highlight color', 'Accent Color'),
              _value('Sidebar icon size', 'Medium'),
              _switch('Allow wallpaper tinting in windows', value: true),
            ],
          ),
          SettingsSection(
            tiles: [
              _value('Show scroll bars', 'Automatically'),
              _value('Click in the scroll bar to', 'Jump to the next page'),
            ],
          ),
        ]),
      ),
      _macCategory(
        'control-center',
        'Control Center',
        CupertinoIcons.slider_horizontal_3,
        _macGrey,
        (_) => const _SwitchPage([
          (
            'Control Center Modules',
            [
              ('Wi-Fi', true),
              ('Bluetooth', true),
              ('AirDrop', false),
              ('Focus Modes', true),
              ('Stage Manager', false),
            ],
          ),
          ('Other Modules', [('Battery', true), ('Hearing', false)]),
        ]),
      ),
      _macCategory(
        'desktop-dock',
        'Desktop & Dock',
        CupertinoIcons.macwindow,
        _macBlack,
        (_) => _page([
          SettingsSection(
            title: const Text('Dock'),
            tiles: [
              _value('Size', 'Medium'),
              _switch('Magnification'),
              _value('Position on screen', 'Bottom'),
              _value('Minimize windows using', 'Genie Effect'),
              _switch('Automatically hide and show the Dock'),
              _switch('Animate opening applications', value: true),
              _switch('Show indicators for open applications', value: true),
            ],
          ),
          SettingsSection(
            title: const Text('Desktop & Stage Manager'),
            tiles: [
              _value('Show Items', 'On Desktop'),
              _value(
                'Click wallpaper to reveal desktop',
                'Only in Stage Manager',
              ),
              _switch('Stage Manager'),
            ],
          ),
        ]),
      ),
      _macCategory(
        'displays',
        'Displays',
        CupertinoIcons.sun_max_fill,
        _macBlue,
        (_) => _page([
          SettingsSection(
            tiles: [
              _value('Use as', 'Main display'),
              _value('Resolution', 'Default'),
              _switch('Automatically adjust brightness', value: true),
              _switch('True Tone', value: true),
            ],
          ),
          SettingsSection(
            tiles: [
              _value('Color profile', 'Color LCD'),
              _value('Refresh rate', 'ProMotion'),
            ],
          ),
          SettingsSection(tiles: [_nav('Night Shift…')]),
        ]),
      ),
      _macCategory(
        'spotlight',
        'Spotlight',
        CupertinoIcons.search,
        _macGrey,
        (_) => const _SwitchPage([
          (
            'Search results',
            [
              ('Applications', true),
              ('Calculator', true),
              ('Contacts', true),
              ('Documents', true),
              ('Folders', true),
              ('Mail & Messages', false),
            ],
          ),
        ]),
      ),
      _macCategory(
        'wallpaper',
        'Wallpaper',
        CupertinoIcons.photo_fill,
        _macCyan,
        (_) => _page([
          SettingsSection(
            tiles: [
              _switch('Show on all Spaces', value: true),
              _value('Screen saver', 'Drift'),
            ],
          ),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _macCategory(
        'notifications',
        'Notifications',
        CupertinoIcons.bell_fill,
        _macRed,
        (_) => _page([
          SettingsSection(
            title: const Text('Notification Center'),
            tiles: [
              _value('Show previews', 'When Unlocked'),
              _switch('Allow notifications when the display is sleeping'),
              _switch('Allow notifications when the screen is locked'),
            ],
          ),
        ]),
      ),
      _macCategory(
        'sound',
        'Sound',
        CupertinoIcons.speaker_3_fill,
        _macPink,
        (_) => _page([
          SettingsSection(
            title: const Text('Sound Effects'),
            tiles: [
              _value('Alert sound', 'Boop'),
              _switch('Play sound on startup', value: true),
              _switch('Play user interface sound effects', value: true),
            ],
          ),
          SettingsSection(
            title: const Text('Output & Input'),
            tiles: [_value('Output device', 'Speakers')],
          ),
        ]),
      ),
      _macCategory(
        'focus',
        'Focus',
        CupertinoIcons.moon_fill,
        _macIndigo,
        (_) => _page([
          SettingsSection(
            tiles: [_nav('Do Not Disturb'), _nav('Sleep'), _nav('Work')],
          ),
          SettingsSection(tiles: [_switch('Share across devices')]),
        ]),
      ),
      _macCategory(
        'screen-time',
        'Screen Time',
        CupertinoIcons.hourglass,
        _macIndigo,
        (_) => _page([
          SettingsSection(
            tiles: [
              _nav('App & Website Activity'),
              _nav('Notifications'),
              _nav('Downtime', value: 'Off'),
            ],
          ),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _macCategory(
        'lock-screen',
        'Lock Screen',
        CupertinoIcons.lock_fill,
        _macBlack,
        (_) => _page([
          SettingsSection(
            tiles: [
              _value('Start Screen Saver when inactive', 'For 20 minutes'),
              _value('Turn display off when inactive', 'For 10 minutes'),
              _value('Require password after display is off', 'Immediately'),
            ],
          ),
        ]),
      ),
      _macCategory(
        'privacy',
        'Privacy & Security',
        CupertinoIcons.hand_raised_fill,
        _macBlue,
        (_) => _page([
          SettingsSection(
            tiles: [
              _nav('Location Services', value: 'On'),
              _nav('Calendars'),
              _nav('Camera'),
              _nav('Microphone'),
            ],
          ),
          SettingsSection(
            title: const Text('Security'),
            tiles: [_value('Allow applications from', 'App Store')],
          ),
        ]),
      ),
      _macCategory(
        'touch-id',
        'Touch ID & Password',
        CupertinoIcons.lock_shield_fill,
        _macPink,
        (_) => _page([
          SettingsSection(
            tiles: [
              _switch('Use Touch ID to unlock your Mac', value: true),
              _switch('Use Touch ID for autofilling passwords', value: true),
            ],
          ),
        ]),
      ),
      _macCategory(
        'users',
        'Users & Groups',
        CupertinoIcons.person_2_fill,
        _macBlue,
        (_) => _page([
          SettingsSection(tiles: [_nav('Guest User', value: 'Off')]),
          SettingsSection(tiles: [_value('Automatically log in as', 'Off')]),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _macCategory(
        'keyboard',
        'Keyboard',
        CupertinoIcons.keyboard,
        _macGrey,
        (_) => _page([
          SettingsSection(
            tiles: [
              _value('Key repeat rate', 'Fast'),
              _value('Delay until repeat', 'Short'),
              _switch('Adjust keyboard brightness in low light', value: true),
            ],
          ),
        ]),
      ),
      _macCategory(
        'printers',
        'Printers & Scanners',
        CupertinoIcons.printer_fill,
        _macOrange,
        (_) => _page([
          SettingsSection(
            tiles: [
              _value('Default printer', 'Last Printer Used'),
              _value('Default paper size', 'A4'),
            ],
          ),
        ]),
      ),
    ],
  ),
];

Widget _macGeneralPage() => _page([
  SettingsSection(
    tiles: [
      SettingsTile.navigation(
        leading: const MacSidebarIcon(
          CupertinoIcons.desktopcomputer,
          _macGrey,
          size: 24,
        ),
        title: const Text('About'),
        destination: SettingsDestination(
          id: 'about',
          builder: (_) => _page([
            SettingsSection(
              tiles: [
                _value('Name', 'Mac'),
                _value('Chip', 'Apple M5'),
                _value('Memory', '16 GB'),
                _value('macOS', 'Version 27.0'),
              ],
            ),
            SettingsSection(
              tiles: [
                _value('Displays', 'Built-in Display'),
                _value('Storage', '512 GB'),
              ],
            ),
          ]),
        ),
      ),
      _nav(
        'Software Update',
        leading: const MacSidebarIcon(
          CupertinoIcons.gear_alt_fill,
          _macGrey,
          size: 24,
        ),
      ),
      _nav(
        'Storage',
        leading: const MacSidebarIcon(
          CupertinoIcons.square_stack_3d_up_fill,
          _macGrey,
          size: 24,
        ),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _nav(
        'AirDrop & Handoff',
        leading: const MacSidebarIcon(
          CupertinoIcons.rectangle_on_rectangle,
          _macBlue,
          size: 24,
        ),
      ),
      _nav(
        'AutoFill & Passwords',
        leading: const MacSidebarIcon(
          CupertinoIcons.lock_shield_fill,
          _macGrey,
          size: 24,
        ),
      ),
      _nav(
        'Date & Time',
        leading: const MacSidebarIcon(
          CupertinoIcons.clock_fill,
          _macBlue,
          size: 24,
        ),
      ),
      _nav(
        'Language & Region',
        leading: const MacSidebarIcon(CupertinoIcons.globe, _macBlue, size: 24),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _nav(
        'Time Machine',
        leading: const MacSidebarIcon(
          CupertinoIcons.arrow_2_circlepath,
          _macGreen,
          size: 24,
        ),
      ),
      _nav(
        'Transfer or Reset',
        leading: const MacSidebarIcon(
          CupertinoIcons.arrow_counterclockwise,
          _macGrey,
          size: 24,
        ),
      ),
    ],
  ),
]);

// Windows Settings ----------------------------------------------------------------

const _winBlue = Color(0xFF0078D4);
const Color? _winGrey = null;
const _winGreen = Color(0xFF107C10);
const _winOrange = Color(0xFFDA3B01);
const _winTeal = Color(0xFF038387);

/// A colored pane icon, like the Windows Settings ones, lighter in dark
/// mode. Grey icons take the pane's text color.
class _WinIcon extends StatelessWidget {
  const _WinIcon(this.icon, this.color);

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      icon,
      color: color == null || !dark
          ? color
          : Color.lerp(color, const Color(0xFFFFFFFF), 0.4),
    );
  }
}

SettingsTile _winCategory(
  String id,
  String title,
  IconData icon,
  Color? color,
  WidgetBuilder builder,
) => SettingsTile.navigation(
  leading: _WinIcon(icon, color),
  title: Text(title),
  destination: SettingsDestination(id: id, builder: demoLive(builder)),
);

SettingsTile _card(String title, String description, IconData icon) =>
    SettingsTile.navigation(
      leading: Icon(icon),
      title: Text(title),
      description: Text(description),
      onPressed: (_) {},
    );

List<AbstractSettingsSection> windowsSplitSections() => [
  SettingsSection(
    tiles: [
      _winCategory(
        'home',
        'Home',
        Icons.home_outlined,
        _winGrey,
        (_) => _page([
          SettingsSection(
            title: const Text('Recommended settings'),
            tiles: [
              _card(
                'Display',
                'Monitors, brightness, night light, display profile',
                Icons.desktop_windows_outlined,
              ),
              _card(
                'Sound',
                'Volume levels, output, input, sound devices',
                Icons.volume_up_outlined,
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Bluetooth devices'),
            tiles: [
              _switch(
                'Bluetooth',
                value: true,
                leading: const Icon(Icons.bluetooth),
              ),
            ],
          ),
        ]),
      ),
      _winCategory(
        'system',
        'System',
        Icons.laptop_windows_outlined,
        _winBlue,
        (_) => _windowsSystemPage(),
      ),
      _winCategory(
        'bluetooth',
        'Bluetooth & devices',
        Icons.bluetooth,
        _winBlue,
        (_) => _page([
          SettingsSection(
            tiles: [
              demoSwitch(
                'Bluetooth',
                value: true,
                leading: const Icon(Icons.bluetooth),
                description: const Text('Discoverable as "Desktop-PC"'),
                showState: true,
              ),
              _card(
                'Devices',
                'Mouse, keyboard, pen, audio, displays and docks, other '
                    'devices',
                Icons.devices_other_outlined,
              ),
              _card(
                'Printers & scanners',
                'Preferences, troubleshoot',
                Icons.print_outlined,
              ),
              _card(
                'Mobile devices',
                'Instantly access your mobile devices from your PC',
                Icons.phone_android_outlined,
              ),
              _card(
                'Cameras',
                'Connected cameras, default image settings',
                Icons.photo_camera_outlined,
              ),
              _card(
                'Mouse',
                'Buttons, mouse pointer speed, scrolling',
                Icons.mouse_outlined,
              ),
            ],
          ),
        ]),
      ),
      _winCategory(
        'network',
        'Network & internet',
        Icons.wifi,
        _winBlue,
        (_) => _page([
          SettingsSection(
            tiles: [
              _card('Wi-Fi', 'Connect, manage known networks', Icons.wifi),
              _card(
                'Ethernet',
                'Authentication, IP and DNS settings',
                Icons.lan_outlined,
              ),
              _card('VPN', 'Add, connect, manage', Icons.vpn_key_outlined),
              _switch(
                'Airplane mode',
                description: const Text('Stop all wireless communication'),
                leading: const Icon(Icons.airplanemode_active),
              ),
              _card(
                'Proxy',
                'Proxy server for Wi-Fi and Ethernet connections',
                Icons.public,
              ),
              _card(
                'Advanced network settings',
                'View all network adapters, network reset',
                Icons.settings_ethernet,
              ),
            ],
          ),
        ]),
      ),
      _winCategory(
        'personalization',
        'Personalization',
        Icons.brush_outlined,
        _winOrange,
        (_) => _page([
          SettingsSection(
            tiles: [
              _card(
                'Background',
                'Background image, color, slideshow',
                Icons.image_outlined,
              ),
              _card(
                'Colors',
                'Accent color, transparency effects, color theme',
                Icons.palette_outlined,
              ),
              _card('Themes', 'Install, create, manage', Icons.brush_outlined),
              _card(
                'Lock screen',
                'Lock screen images, apps, animations',
                Icons.lock_outline,
              ),
              _card('Start', 'Recent apps and items, folders', Icons.grid_view),
              _card(
                'Taskbar',
                'Taskbar behaviors, system pins',
                Icons.web_asset,
              ),
              _card('Fonts', 'Install, manage', Icons.font_download_outlined),
            ],
          ),
        ]),
      ),
      _winCategory(
        'apps',
        'Apps',
        Icons.apps,
        _winGrey,
        (_) => _page([
          SettingsSection(
            tiles: [
              _card('Installed apps', 'Uninstall, reorder', Icons.list),
              _card(
                'Advanced app settings',
                'Choose where to get apps, app archiving',
                Icons.tune,
              ),
              _card(
                'Default apps',
                'Defaults for file and link types, other defaults',
                Icons.check_box_outlined,
              ),
              _card(
                'Startup',
                'Apps that start automatically when you sign in',
                Icons.rocket_launch_outlined,
              ),
            ],
          ),
        ]),
      ),
      _winCategory(
        'accounts',
        'Accounts',
        Icons.person_outline,
        _winGreen,
        (_) => _page([
          SettingsSection(
            title: const Text('Account settings'),
            tiles: [
              _card('Your info', 'Profile photo', Icons.badge_outlined),
              _card(
                'Sign-in options',
                'Windows Hello, security key, password, dynamic lock',
                Icons.key_outlined,
              ),
              _card(
                'Email & accounts',
                'Accounts used by email, calendar, and contacts',
                Icons.mail_outline,
              ),
              _card(
                'Other users',
                'Device access, work or school users',
                Icons.group_outlined,
              ),
            ],
          ),
        ]),
      ),
      _winCategory(
        'time-language',
        'Time & language',
        Icons.language,
        _winBlue,
        (_) => _page([
          SettingsSection(
            tiles: [
              _card(
                'Date & time',
                'Time zones, automatic clock settings, calendar display',
                Icons.schedule,
              ),
              _card(
                'Language & region',
                'Windows and some apps format dates and time based on your region',
                Icons.translate,
              ),
              _card(
                'Typing',
                'Touch keyboard, text suggestions, preferences',
                Icons.keyboard_outlined,
              ),
            ],
          ),
        ]),
      ),
      _winCategory(
        'gaming',
        'Gaming',
        Icons.sports_esports_outlined,
        _winGrey,
        (_) => _page([
          SettingsSection(
            tiles: [
              _card(
                'Game Bar',
                'Controller and keyboard shortcuts',
                Icons.gamepad_outlined,
              ),
              _card(
                'Captures',
                'Save location, recording preferences',
                Icons.videocam_outlined,
              ),
              _switch(
                'Game Mode',
                value: true,
                description: const Text('Optimize your PC for play'),
                leading: const Icon(Icons.speed),
              ),
            ],
          ),
        ]),
      ),
      _winCategory(
        'accessibility',
        'Accessibility',
        Icons.accessibility_new,
        _winBlue,
        (_) => _page([
          SettingsSection(
            title: const Text('Vision'),
            tiles: [
              _card(
                'Text size',
                'Text size throughout Windows and your apps',
                Icons.text_fields,
              ),
              _card(
                'Visual effects',
                'Scroll bars, transparency, animations',
                Icons.auto_awesome_outlined,
              ),
              _card('Magnifier', 'Zoom level, zoom increment', Icons.zoom_in),
              _card(
                'Contrast themes',
                'Color themes for low vision, light sensitivity',
                Icons.contrast,
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Hearing'),
            tiles: [
              _card('Audio', 'Mono audio, audio notifications', Icons.hearing),
              _card('Captions', 'Styles', Icons.closed_caption_outlined),
            ],
          ),
        ]),
      ),
      _winCategory(
        'privacy',
        'Privacy & security',
        Icons.shield_outlined,
        _winGrey,
        (_) => _page([
          SettingsSection(
            title: const Text('Security'),
            tiles: [
              _card(
                'Windows Security',
                'Antivirus, browser, firewall, and network protection for your device',
                Icons.shield_outlined,
              ),
              _card(
                'Find my device',
                'Track your device if you think you\'ve lost it',
                Icons.location_searching,
              ),
              _card(
                'For developers',
                'These settings are intended for development use only',
                Icons.code,
              ),
            ],
          ),
        ]),
      ),
      _winCategory(
        'windows-update',
        'Windows Update',
        Icons.sync,
        _winTeal,
        (_) => _page([
          SettingsSection(
            tiles: [
              SettingsTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('You\'re up to date'),
                description: const Text('Last checked: Today, 9:41 AM'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('More options'),
            tiles: [
              _switch(
                'Get the latest updates as soon as they\'re available',
                description: const Text(
                  'Be among the first to get the latest non-security updates, '
                  'fixes, and improvements as they roll out.',
                ),
                leading: const Icon(Icons.campaign_outlined),
              ),
              _card('Update history', 'Recent updates', Icons.history),
              _card(
                'Advanced options',
                'Delivery optimization, optional updates, active hours, other '
                    'update settings',
                Icons.settings_outlined,
              ),
            ],
          ),
        ]),
      ),
    ],
  ),
];

Widget _windowsSystemPage() => _page([
  SettingsSection(
    tiles: [
      SettingsTile.navigation(
        leading: const Icon(Icons.desktop_windows_outlined),
        title: const Text('Display'),
        description: const Text(
          'Monitors, brightness, night light, display profile',
        ),
        destination: SettingsDestination(
          id: 'display',
          builder: demoLive(
            (_) => _page([
              SettingsSection(
                title: const Text('Brightness & color'),
                tiles: [
                  demoSwitch(
                    'Night light',
                    leading: const Icon(Icons.nightlight_outlined),
                    description: const Text(
                      'Use warmer colors to help block blue light',
                    ),
                  ),
                  _card('HDR', 'More about HDR', Icons.hdr_on_outlined),
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
                  SettingsTile.navigation(
                    leading: const Icon(Icons.aspect_ratio),
                    title: const Text('Display resolution'),
                    description: const Text(
                      'Adjust the resolution to fit your connected display',
                    ),
                    value: const Text('2560 × 1600 (Recommended)'),
                    onPressed: (_) {},
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
      _card(
        'Sound',
        'Volume levels, output, input, sound devices',
        Icons.volume_up_outlined,
      ),
      _card(
        'Notifications',
        'Alerts from apps and system, do not disturb',
        Icons.notifications_none,
      ),
      _card('Focus', 'Reduce distractions', Icons.center_focus_strong_outlined),
      _card(
        'Power & battery',
        'Sleep, battery usage, battery saver',
        Icons.power_settings_new,
      ),
      _card(
        'Storage',
        'Storage space, drives, configuration rules',
        Icons.storage,
      ),
      _card(
        'Multitasking',
        'Snap windows, desktops, task switching',
        Icons.window_outlined,
      ),
      _card(
        'About',
        'Device specifications, rename PC, Windows specifications',
        Icons.info_outline,
      ),
    ],
  ),
]);

// GNOME Settings ------------------------------------------------------------------

SettingsTile _gnomeCategory(
  String id,
  String title,
  IconData icon,
  WidgetBuilder builder,
) => SettingsTile.navigation(
  leading: Icon(icon),
  title: Text(title),
  destination: SettingsDestination(id: id, builder: demoLive(builder)),
);

/// A GNOME combo row's value: the choice and the pan-down arrow.
SettingsTile _combo(String title, String value, {Widget? subtitle}) =>
    SettingsTile(
      title: Text(title),
      titleDescription: subtitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value),
          const SizedBox(width: 9),
          const AdwaitaPanDownIcon(),
        ],
      ),
      onPressed: (_) {},
    );

List<AbstractSettingsSection> gnomeSplitSections() => [
  SettingsSection(
    tiles: [
      _gnomeCategory(
        'network',
        'Network',
        Icons.desktop_windows_outlined,
        (_) => _page([
          SettingsSection(
            title: const Text('Wired'),
            tiles: [_switch('Connected - 1000 Mb/s', value: true)],
          ),
          SettingsSection(
            title: const Text('VPN'),
            tiles: [_nav('Not set up')],
          ),
          SettingsSection(tiles: [_nav('Proxy', value: 'Off')]),
        ]),
      ),
      _gnomeCategory(
        'bluetooth',
        'Bluetooth',
        Icons.bluetooth,
        (_) => _page([
          SettingsSection(tiles: [_switch('Bluetooth', value: true)]),
          SettingsSection(
            title: const Text('Devices'),
            tiles: [
              _nav('Keyboard', value: 'Connected'),
              _nav('Headphones', value: 'Disconnected'),
            ],
          ),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _gnomeCategory(
        'displays',
        'Displays',
        Icons.monitor_outlined,
        (_) => _page([
          SettingsSection(
            title: const Text('Built-in Display'),
            tiles: [
              _combo('Orientation', 'Landscape'),
              _combo('Resolution', '2560 × 1600 (16:10)'),
              _combo('Refresh Rate', '60.00 Hz'),
              _combo('Scale', '150 %'),
              _switch('Fractional Scaling', value: true),
            ],
          ),
          SettingsSection(tiles: [_nav('Night Light', value: 'Off')]),
        ]),
      ),
      _gnomeCategory(
        'sound',
        'Sound',
        Icons.volume_up_outlined,
        (_) => _page([
          SettingsSection(
            title: const Text('Output'),
            tiles: [
              _combo('Output Device', 'Speakers'),
              _switch('Over-Amplification'),
            ],
          ),
          SettingsSection(
            tiles: [
              SettingsTile.navigation(
                title: const Text('Volume Levels'),
                destination: SettingsDestination(
                  id: 'volume-levels',
                  builder: (_) => _page([
                    SettingsSection(
                      title: const Text('Outputs'),
                      tiles: [
                        _value('System Sounds', '100 %'),
                        _value('Music', '70 %'),
                        _value('Video Player', '85 %'),
                      ],
                    ),
                    SettingsSection(
                      title: const Text('Inputs'),
                      tiles: [_value('Sound Recorder', '60 %')],
                    ),
                  ]),
                ),
              ),
              _nav('Alert Sound', value: 'Default'),
            ],
          ),
          SettingsSection(
            title: const Text('Input'),
            tiles: [_combo('Input Device', 'Microphone')],
          ),
        ]),
      ),
      _gnomeCategory(
        'power',
        'Power',
        Icons.battery_charging_full,
        (_) => _page([
          SettingsSection(
            title: const Text('Power Mode'),
            tiles: [
              _combo('Power Mode', 'Balanced'),
              _switch(
                'Automatic Power Saver',
                value: true,
                titleDescription: const Text(
                  'Enables power saver mode when battery is low',
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Power Saving'),
            tiles: [
              _switch('Dim Screen', value: true),
              _combo('Screen Blank', '5 minutes'),
              _nav('Automatic Suspend', value: 'Off'),
            ],
          ),
        ]),
      ),
      _gnomeCategory(
        'multitasking',
        'Multitasking',
        Icons.filter_none,
        (_) => const _SwitchPage([
          ('General', [('Hot Corner', true), ('Active Screen Edges', true)]),
          (
            'App Switching',
            [('Include apps from the current workspace only', false)],
          ),
        ]),
      ),
      _gnomeCategory(
        'appearance',
        'Appearance',
        Icons.palette_outlined,
        (_) => _page([
          SettingsSection(
            title: const Text('Style'),
            tiles: [_combo('Style', 'Default'), _combo('Accent Color', 'Blue')],
          ),
          SettingsSection(tiles: [_nav('Background')]),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _gnomeCategory(
        'apps',
        'Apps',
        Icons.apps,
        (_) => _page([
          SettingsSection(tiles: [_nav('Default Apps'), _nav('Startup Apps')]),
          SettingsSection(
            title: const Text('Apps'),
            tiles: [
              _nav('Calendar'),
              _nav('Files'),
              _nav('Text Editor'),
              _nav('Web'),
            ],
          ),
        ]),
      ),
      _gnomeCategory(
        'notifications',
        'Notifications',
        Icons.notifications_none,
        (_) => const _SwitchPage([
          (
            null,
            [('Do Not Disturb', false), ('Lock Screen Notifications', true)],
          ),
          (
            'App Notifications',
            [('Calendar', true), ('Clocks', true), ('Files', false)],
          ),
        ]),
      ),
      _gnomeCategory(
        'search',
        'Search',
        Icons.search,
        (_) => const _SwitchPage([
          (null, [('App Search', true)]),
          (
            'Search Results',
            [('Files', true), ('Settings', true), ('Calculator', true)],
          ),
        ]),
      ),
      _gnomeCategory(
        'online-accounts',
        'Online Accounts',
        Icons.alternate_email,
        (_) => _page([
          SettingsSection(
            title: const Text('Connect an Account'),
            tiles: [
              _nav('Nextcloud'),
              _nav('Microsoft 365'),
              _nav('WebDAV'),
              _nav('IMAP and SMTP'),
            ],
          ),
        ]),
      ),
      _gnomeCategory(
        'sharing',
        'Sharing',
        Icons.share_outlined,
        (_) => _page([
          SettingsSection(tiles: [_nav('Device Name', value: 'Workstation')]),
          SettingsSection(
            tiles: [
              _nav('File Sharing', value: 'Off'),
              _nav('Media Sharing', value: 'Off'),
            ],
          ),
        ]),
      ),
      _gnomeCategory(
        'wellbeing',
        'Wellbeing',
        Icons.self_improvement,
        (_) => _page([
          SettingsSection(
            title: const Text('Screen Limits'),
            tiles: [
              _switch('Screen Time Limit'),
              _switch(
                'Grayscale',
                titleDescription: const Text(
                  'Black and white screen for screen limits',
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Break Reminders'),
            tiles: [
              _switch(
                'Eyesight Reminders',
                value: true,
                titleDescription: const Text(
                  'Reminders to look away from the screen',
                ),
              ),
              _switch(
                'Movement Reminders',
                value: true,
                titleDescription: const Text('Reminders to move around'),
              ),
            ],
          ),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _gnomeCategory(
        'mouse',
        'Mouse & Touchpad',
        Icons.mouse_outlined,
        (_) => _page([
          SettingsSection(
            title: const Text('General'),
            tiles: [_combo('Primary Button', 'Left')],
          ),
          SettingsSection(
            title: const Text('Mouse'),
            tiles: [_switch('Mouse Acceleration', value: true)],
          ),
        ]),
      ),
      _gnomeCategory(
        'keyboard',
        'Keyboard',
        Icons.keyboard_outlined,
        (_) => _page([
          SettingsSection(
            title: const Text('Input Sources'),
            tiles: [_nav('English (US)')],
          ),
          SettingsSection(tiles: [_nav('Keyboard Shortcuts')]),
        ]),
      ),
      _gnomeCategory(
        'color',
        'Color Management',
        Icons.color_lens_outlined,
        (_) => _page([
          SettingsSection(tiles: [_nav('Built-in Display', value: 'Default')]),
        ]),
      ),
      _gnomeCategory(
        'printers',
        'Printers',
        Icons.print_outlined,
        (_) => _page([
          SettingsSection(tiles: [_nav('Add Printer…')]),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _gnomeCategory(
        'accessibility',
        'Accessibility',
        Icons.accessibility_new,
        (_) => const _SwitchPage([
          (
            'Seeing',
            [
              ('High Contrast', false),
              ('Large Text', false),
              ('Reduce Animation', false),
            ],
          ),
        ]),
      ),
      _gnomeCategory(
        'privacy',
        'Privacy & Security',
        Icons.back_hand_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _nav('Screen Lock', value: 'On'),
              _nav('Location', value: 'Off'),
              _nav('File History & Trash'),
            ],
          ),
        ]),
      ),
      _gnomeCategory(
        'system',
        'System',
        Icons.settings_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _nav('Region & Language'),
              _nav('Date & Time'),
              _nav('Users'),
              _nav('Remote Desktop'),
              _nav('About'),
            ],
          ),
        ]),
      ),
    ],
  ),
];
