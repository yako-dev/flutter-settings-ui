import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:example/screens/gallery/cross_platform_settings_screen.dart';
import 'package:example/utils/navigation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// SettingsSplitView with the settings tree of the platform app its style
/// copies: iPad Settings, Android Settings, or Chrome's settings page.
///
/// Open it from the gallery, or directly with the launch options (see
/// `LaunchOptions`), e.g. `flutter run --route
/// '/split-view?platform=android&page=display'`.
class SplitViewScreen extends StatefulWidget {
  const SplitViewScreen({
    super.key,
    this.platform = DevicePlatform.device,
    this.initialPageId,
  });

  final DevicePlatform platform;
  final String? initialPageId;

  @override
  State<SplitViewScreen> createState() => _SplitViewScreenState();
}

class _SplitViewScreenState extends State<SplitViewScreen> {
  late DevicePlatform _platform = widget.platform;
  late final SettingsSplitController _controller = SettingsSplitController();

  static const _styles = <DevicePlatform, String>{
    DevicePlatform.device: 'Default',
    DevicePlatform.iOS: 'iOS',
    DevicePlatform.android: 'Android',
    DevicePlatform.web: 'Web',
    DevicePlatform.macOS: 'macOS',
    DevicePlatform.windows: 'Windows',
    DevicePlatform.linux: 'Linux',
  };

  @override
  void initState() {
    super.initState();
    final page = widget.initialPageId;
    // A picked page, like a deep link: it also opens in one pane.
    if (page != null) _controller.select(page);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickStyle(BuildContext context) async {
    final platform = await Navigation.navigateTo<DevicePlatform>(
      context: context,
      style: NavigationRouteStyle.material,
      screen: PlatformPickerScreen(platform: _platform, platforms: _styles),
    );
    if (platform != null && mounted) setState(() => _platform = platform);
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _platform == DevicePlatform.device
        ? PlatformUtils.detectPlatform(context)
        : _platform;

    final demo = SettingsSection(
      title: const Text('Demo'),
      tiles: [
        SettingsTile.navigation(
          leading:
              resolved == DevicePlatform.iOS ||
                  resolved == DevicePlatform.macOS ||
                  resolved == DevicePlatform.windows
              ? const _AppIcon(CupertinoIcons.paintbrush, Color(0xFF8E8E93))
              : const Icon(Icons.style_outlined),
          title: const Text('Style'),
          value: Text(_styles[_platform]!),
          onPressed: _pickStyle,
        ),
      ],
    );

    final List<AbstractSettingsSection> sections;
    switch (resolved) {
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        sections = [..._iPadSections(), demo];
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
        sections = [..._androidSections(), demo];
      case DevicePlatform.web:
      case DevicePlatform.device:
        sections = [..._chromeSections(), demo];
    }

    final view = SettingsSplitView(
      // A new style is a new settings tree.
      key: ValueKey(resolved),
      platform: _platform,
      title: const Text('Settings'),
      controller: _controller,
      sections: sections,
    );

    // The Android and web styles take their colors from the ColorScheme. Seed
    // it like the platform apps, so the demo compares well with them.
    final brightness = Theme.of(context).brightness;
    switch (resolved) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
        // Android's default Material You palette (no wallpaper colors).
        return _seeded(
          context,
          const Color(0xFF495D92),
          DynamicSchemeVariant.tonalSpot,
          brightness,
          view,
        );
      case DevicePlatform.web:
        // Chrome's blue, kept vivid.
        return _seeded(
          context,
          const Color(0xFF1A73E8),
          DynamicSchemeVariant.fidelity,
          brightness,
          view,
        );
      default:
        return view;
    }
  }

  Widget _seeded(
    BuildContext context,
    Color seed,
    DynamicSchemeVariant variant,
    Brightness brightness,
    Widget child,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          dynamicSchemeVariant: variant,
          brightness: brightness,
        ),
      ),
      child: child,
    );
  }
}

// iPad Settings ---------------------------------------------------------------

/// The rounded-square app icons of iOS Settings.
class _AppIcon extends StatelessWidget {
  const _AppIcon(this.icon, this.color);

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 29,
        height: 29,
        color: color,
        alignment: Alignment.center,
        child: Icon(icon, color: CupertinoColors.white, size: 19),
      ),
    );
  }
}

const _iosBlue = Color(0xFF0088FF);
const _iosGrey = Color(0xFF8E8E93);
const _iosGreen = Color(0xFF34C759);
const _iosOrange = Color(0xFFFF9500);
const _iosRed = Color(0xFFFF3B30);
const _iosPink = Color(0xFFFF2D55);
const _iosIndigo = Color(0xFF5856D6);
const _iosBlack = Color(0xFF1C1C1E);

Widget _page(List<AbstractSettingsSection> sections) =>
    SettingsList(sections: sections);

SettingsTile _nav(String title, {String? value, Widget? leading}) =>
    SettingsTile.navigation(
      leading: leading,
      title: Text(title),
      value: value == null ? null : Text(value),
      onPressed: (_) {},
    );

SettingsTile _switch(
  String title, {
  bool value = false,
  Widget? leading,
  Widget? description,
}) => SettingsTile.switchTile(
  leading: leading,
  title: Text(title),
  description: description,
  initialValue: value,
  onToggle: (_) {},
);

class _DemoSwitch extends StatefulWidget {
  const _DemoSwitch({required this.title, this.value = false});

  final String title;
  final bool value;

  @override
  State<_DemoSwitch> createState() => _DemoSwitchState();
}

class _DemoSwitchState extends State<_DemoSwitch> {
  late bool _value = widget.value;

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      sections: [
        SettingsSection(
          tiles: [
            SettingsTile.switchTile(
              title: Text(widget.title),
              initialValue: _value,
              onToggle: (value) => setState(() => _value = value),
            ),
          ],
        ),
      ],
    );
  }
}

SettingsTile _iPadCategory(
  String id,
  String title,
  IconData icon,
  Color color,
  WidgetBuilder builder, {
  String? value,
}) => SettingsTile.navigation(
  leading: _AppIcon(icon, color),
  title: Text(title),
  value: value == null ? null : Text(value),
  destination: SettingsDestination(id: id, builder: builder),
);

List<AbstractSettingsSection> _iPadSections() => [
  SettingsSection(
    tiles: [
      SettingsTile.switchTile(
        leading: const _AppIcon(CupertinoIcons.airplane, _iosOrange),
        title: const Text('Airplane Mode'),
        initialValue: false,
        onToggle: (_) {},
      ),
      _iPadCategory(
        'wifi',
        'Wi-Fi',
        CupertinoIcons.wifi,
        _iosBlue,
        (_) => _page([
          SettingsSection(tiles: [_switch('Wi-Fi', value: true)]),
          SettingsSection(
            title: const Text('My Networks'),
            tiles: [_nav('Home'), _nav('Office')],
          ),
          SettingsSection(
            tiles: [_nav('Ask to Join Networks', value: 'Notify')],
          ),
        ]),
        value: 'Home',
      ),
      _iPadCategory(
        'bluetooth',
        'Bluetooth',
        CupertinoIcons.bluetooth,
        _iosBlue,
        (_) => _page([
          SettingsSection(
            tiles: [
              _switch(
                'Bluetooth',
                value: true,
                description: const Text(
                  'This iPad is discoverable as "iPad" while Bluetooth '
                  'Settings is open.',
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('My Devices'),
            tiles: [
              _nav('AirPods Pro', value: 'Not Connected'),
              _nav('Magic Keyboard', value: 'Connected'),
            ],
          ),
        ]),
        value: 'On',
      ),
      _iPadCategory(
        'battery',
        'Battery',
        CupertinoIcons.battery_full,
        _iosGreen,
        (_) => _page([
          SettingsSection(
            tiles: [
              _switch('Battery Percentage', value: true),
              _switch('Low Power Mode'),
            ],
          ),
          SettingsSection(tiles: [_nav('Battery Health', value: 'Normal')]),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _iPadCategory(
        'general',
        'General',
        CupertinoIcons.gear_alt_fill,
        _iosGrey,
        (_) => _generalPage(),
      ),
      _iPadCategory(
        'accessibility',
        'Accessibility',
        CupertinoIcons.person_crop_circle,
        _iosBlue,
        (_) => _accessibilityPage(),
      ),
      _iPadCategory(
        'display',
        'Display & Brightness',
        CupertinoIcons.sun_max_fill,
        _iosBlue,
        (_) => _page([
          SettingsSection(
            title: const Text('Appearance'),
            tiles: [
              SettingsTile(
                title: const Text('Light'),
                trailing: const Icon(CupertinoIcons.check_mark),
                onPressed: (_) {},
              ),
              SettingsTile(title: const Text('Dark'), onPressed: (_) {}),
              _switch('Automatic'),
            ],
          ),
          SettingsSection(
            title: const Text('Text'),
            tiles: [_nav('Text Size'), _switch('Bold Text')],
          ),
          SettingsSection(
            title: const Text('Brightness'),
            tiles: [
              _switch(
                'True Tone',
                value: true,
                description: const Text(
                  'Automatically adapt iPad display based on ambient '
                  'lighting conditions to make colors appear consistent in '
                  'different environments.',
                ),
              ),
            ],
          ),
          SettingsSection(
            tiles: [
              _nav('Night Shift', value: 'Off'),
              _nav('Auto-Lock', value: '2 Minutes'),
              _switch('Lock / Unlock', value: true),
            ],
          ),
        ]),
      ),
      _iPadCategory(
        'camera',
        'Camera',
        CupertinoIcons.camera_fill,
        _iosGrey,
        (_) => _page([
          SettingsSection(
            tiles: [
              _nav('Formats'),
              _nav('Record Video', value: '1080p at 30 fps'),
              _nav('Record Slo-mo', value: '720p at 240 fps'),
            ],
          ),
          SettingsSection(
            title: const Text('Composition'),
            tiles: [_switch('Grid'), _switch('Mirror Front Camera')],
          ),
          SettingsSection(tiles: [_switch('Scan QR Codes', value: true)]),
        ]),
      ),
      _iPadCategory(
        'home-screen',
        'Home Screen & App Library',
        CupertinoIcons.square_grid_2x2_fill,
        _iosBlue,
        (_) => _page([
          SettingsSection(
            title: const Text('Newly Downloaded Apps'),
            tiles: [_switch('Add to Home Screen', value: true)],
          ),
          SettingsSection(tiles: [_switch('Show in Dock', value: true)]),
        ]),
      ),
      _iPadCategory(
        'multitasking',
        'Multitasking & Gestures',
        CupertinoIcons.rectangle_split_3x1_fill,
        _iosBlue,
        (_) => _page([
          SettingsSection(
            tiles: [
              _nav('Windowed Apps'),
              _nav('Full Screen Apps'),
              _nav('Stage Manager'),
            ],
          ),
          SettingsSection(
            title: const Text('Gestures'),
            tiles: [
              _switch('Shake to Undo', value: true),
              _switch('Swipe Finger from Corner', value: true),
            ],
          ),
        ]),
      ),
      _iPadCategory(
        'search',
        'Search',
        CupertinoIcons.search,
        _iosGrey,
        (_) => const _DemoSwitch(title: 'Show Suggestions', value: true),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _iPadCategory(
        'notifications',
        'Notifications',
        CupertinoIcons.bell_fill,
        _iosRed,
        (_) => _page([
          SettingsSection(
            tiles: [
              _nav('Display As', value: 'Stack'),
              _nav('Scheduled Summary', value: 'Off'),
              _nav('Show Previews', value: 'Always'),
            ],
          ),
        ]),
      ),
      _iPadCategory(
        'sounds',
        'Sounds',
        CupertinoIcons.speaker_3_fill,
        _iosPink,
        (_) => _page([
          SettingsSection(tiles: [_switch('Change with Buttons', value: true)]),
          SettingsSection(
            tiles: [
              _nav('Ringtone', value: 'Reflection'),
              _nav('Text Tone', value: 'Note'),
            ],
          ),
        ]),
      ),
      _iPadCategory(
        'focus',
        'Focus',
        CupertinoIcons.moon_fill,
        _iosIndigo,
        (_) => _page([
          SettingsSection(
            tiles: [_nav('Do Not Disturb'), _nav('Sleep'), _nav('Work')],
          ),
        ]),
      ),
      _iPadCategory(
        'screen-time',
        'Screen Time',
        CupertinoIcons.hourglass,
        _iosIndigo,
        (_) => _page([
          SettingsSection(
            tiles: [_nav('App & Website Activity'), _nav('Downtime')],
          ),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _iPadCategory(
        'passcode',
        'Face ID & Passcode',
        CupertinoIcons.lock_fill,
        _iosGreen,
        (_) => _page([
          SettingsSection(
            title: const Text('Use Face ID For'),
            tiles: [
              _switch('iPad Unlock', value: true),
              _switch('Apple Pay', value: true),
            ],
          ),
        ]),
      ),
      _iPadCategory(
        'privacy',
        'Privacy & Security',
        CupertinoIcons.hand_raised_fill,
        _iosBlue,
        (_) => _page([
          SettingsSection(
            tiles: [
              _nav('Location Services', value: 'On'),
              _nav('Tracking'),
            ],
          ),
          SettingsSection(
            tiles: [
              _nav('Calendars'),
              _nav('Contacts'),
              _nav('Photos'),
              _nav('Camera'),
              _nav('Microphone'),
            ],
          ),
        ]),
      ),
    ],
  ),
];

Widget _generalPage() => _page([
  SettingsSection(
    tiles: [
      SettingsTile.navigation(
        leading: const _AppIcon(CupertinoIcons.info, _iosGrey),
        title: const Text('About'),
        destination: SettingsDestination(
          id: 'about',
          builder: (_) => _page([
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: const Text('Name'),
                  value: const Text('iPad'),
                ),
                SettingsTile(
                  title: const Text('iPadOS Version'),
                  value: const Text('27.0'),
                ),
                SettingsTile(
                  title: const Text('Model Name'),
                  value: const Text('iPad Pro 11-inch (M5)'),
                ),
              ],
            ),
            SettingsSection(
              tiles: [
                SettingsTile(
                  title: const Text('Applications'),
                  value: const Text('58'),
                ),
                SettingsTile(
                  title: const Text('Capacity'),
                  value: const Text('256 GB'),
                ),
                SettingsTile(
                  title: const Text('Available'),
                  value: const Text('180.4 GB'),
                ),
              ],
            ),
          ]),
        ),
      ),
      _nav(
        'Software Update',
        leading: const _AppIcon(CupertinoIcons.gear_alt_fill, _iosGrey),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _nav(
        'AirDrop',
        leading: const _AppIcon(
          CupertinoIcons.antenna_radiowaves_left_right,
          _iosBlue,
        ),
      ),
      _nav(
        'AirPlay & Continuity',
        leading: const _AppIcon(CupertinoIcons.tv, _iosBlue),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _nav(
        'AutoFill & Passwords',
        leading: const _AppIcon(CupertinoIcons.lock_shield_fill, _iosGrey),
      ),
      _nav(
        'Date & Time',
        leading: const _AppIcon(CupertinoIcons.calendar, _iosBlue),
      ),
      _nav(
        'Dictionary',
        leading: const _AppIcon(CupertinoIcons.book_fill, _iosBlue),
      ),
      _nav(
        'Fonts',
        leading: const _AppIcon(CupertinoIcons.textformat, _iosGrey),
      ),
      _nav(
        'Keyboard',
        leading: const _AppIcon(CupertinoIcons.keyboard, _iosGrey),
      ),
      _nav(
        'Language & Region',
        leading: const _AppIcon(CupertinoIcons.globe, _iosBlue),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _nav(
        'Transfer or Reset iPad',
        leading: const _AppIcon(
          CupertinoIcons.arrow_counterclockwise,
          _iosGrey,
        ),
      ),
    ],
  ),
]);

Widget _accessibilityPage() => _page([
  SettingsSection(
    title: const Text('Vision'),
    tiles: [
      _nav(
        'VoiceOver',
        value: 'Off',
        leading: const _AppIcon(CupertinoIcons.speaker_2_fill, _iosBlack),
      ),
      _nav(
        'Zoom',
        value: 'Off',
        leading: const _AppIcon(CupertinoIcons.zoom_in, _iosBlack),
      ),
      SettingsTile.navigation(
        leading: const _AppIcon(CupertinoIcons.textformat_size, _iosBlue),
        title: const Text('Display & Text Size'),
        destination: SettingsDestination(
          id: 'display-text-size',
          builder: (_) => _page([
            SettingsSection(
              tiles: [
                _switch('Bold Text'),
                _nav('Larger Text', value: 'Off'),
                _switch('Show Borders'),
                _switch('On/Off Labels'),
              ],
            ),
            SettingsSection(
              tiles: [
                _switch(
                  'Reduce Transparency',
                  description: const Text(
                    'Improve contrast by reducing transparency and blurs on '
                    'some backgrounds to increase legibility.',
                  ),
                ),
              ],
            ),
            SettingsSection(
              tiles: [
                _switch(
                  'Increase Contrast',
                  description: const Text(
                    'Increase color contrast between app foreground and '
                    'background colors.',
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
      _nav(
        'Motion',
        leading: const _AppIcon(CupertinoIcons.circle_grid_hex_fill, _iosGreen),
      ),
      _nav(
        'Spoken Content',
        leading: const _AppIcon(CupertinoIcons.text_bubble_fill, _iosBlack),
      ),
    ],
  ),
  SettingsSection(
    title: const Text('Physical and Motor'),
    tiles: [
      _nav(
        'Touch',
        leading: const _AppIcon(CupertinoIcons.hand_point_right_fill, _iosBlue),
      ),
      _nav(
        'Keyboards & Typing',
        leading: const _AppIcon(CupertinoIcons.keyboard, _iosGrey),
      ),
    ],
  ),
  SettingsSection(
    title: const Text('General'),
    tiles: [
      _nav(
        'Guided Access',
        value: 'Off',
        leading: const _AppIcon(CupertinoIcons.lock_circle_fill, _iosBlack),
      ),
      _nav(
        'Accessibility Shortcut',
        value: 'Off',
        leading: const _AppIcon(CupertinoIcons.person_crop_circle, _iosBlue),
      ),
    ],
  ),
]);

// Android Settings -------------------------------------------------------------

SettingsTile _androidCategory(
  String id,
  String title,
  String summary,
  IconData icon,
  WidgetBuilder builder,
) => SettingsTile.navigation(
  leading: Icon(icon),
  title: Text(title),
  description: Text(summary),
  destination: SettingsDestination(id: id, builder: builder),
);

SettingsTile _androidNav(String title, {String? summary, IconData? icon}) =>
    SettingsTile.navigation(
      leading: icon == null ? null : Icon(icon),
      title: Text(title),
      description: summary == null ? null : Text(summary),
      onPressed: (_) {},
    );

List<AbstractSettingsSection> _androidSections() => [
  SettingsSection(
    tiles: [
      _androidCategory(
        'google',
        'Google',
        'Services & preferences',
        Icons.account_circle_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _androidNav('Autofill with Google'),
              _androidNav('Backup'),
              _androidNav('Devices & sharing'),
            ],
          ),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _androidCategory(
        'network',
        'Network & internet',
        'Mobile, Wi-Fi, hotspot',
        Icons.wifi,
        (_) => _page([
          SettingsSection(
            tiles: [
              _androidNav('Internet', summary: 'Home', icon: Icons.wifi),
              _androidNav(
                'SIMs',
                summary: 'T-Mobile',
                icon: Icons.sim_card_outlined,
              ),
              _switch(
                'Airplane mode',
                leading: const Icon(Icons.airplanemode_active),
              ),
              _androidNav(
                'Hotspot & tethering',
                summary: 'Off',
                icon: Icons.wifi_tethering,
              ),
              _androidNav(
                'Data Saver',
                summary: 'Off',
                icon: Icons.data_saver_off,
              ),
            ],
          ),
          SettingsSection(
            tiles: [
              _androidNav('VPN', summary: 'None', icon: Icons.vpn_key_outlined),
              _androidNav(
                'Private DNS',
                summary: 'Automatic',
                icon: Icons.dns_outlined,
              ),
            ],
          ),
        ]),
      ),
      _androidCategory(
        'devices',
        'Connected devices',
        'Bluetooth, pairing',
        Icons.devices_other_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _androidNav('Pair new device', icon: Icons.add),
              _androidNav(
                'Pixel Buds Pro 2',
                summary: 'Saved',
                icon: Icons.headphones,
              ),
            ],
          ),
          SettingsSection(
            tiles: [
              _androidNav(
                'Connection preferences',
                summary: 'Bluetooth, Android Auto, NFC',
                icon: Icons.bluetooth,
              ),
            ],
          ),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _androidCategory(
        'apps',
        'Apps',
        'Assistant, recent apps, default apps',
        Icons.apps,
        (_) => _page([
          SettingsSection(
            title: const Text('Recently opened apps'),
            tiles: [
              _androidNav('Chrome', summary: '2 min. ago'),
              _androidNav('Messages', summary: '1 hr. ago'),
            ],
          ),
          SettingsSection(
            tiles: [
              _androidNav('Default apps', summary: 'Chrome and Messages'),
              _androidNav('Screen time', summary: '1 hr. 12 min. today'),
            ],
          ),
        ]),
      ),
      _androidCategory(
        'notifications',
        'Notifications',
        'Notification history, conversations',
        Icons.notifications_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _androidNav('App notifications'),
              _androidNav('Notification history'),
              _androidNav('Conversations'),
            ],
          ),
        ]),
      ),
      _androidCategory(
        'sound',
        'Sound & vibration',
        'Volume and haptics',
        Icons.volume_up_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _androidNav('Media volume', summary: '60%'),
              _androidNav('Ring & notification volume', summary: '80%'),
              _androidNav('Alarm volume', summary: '70%'),
            ],
          ),
          SettingsSection(
            tiles: [
              _androidNav('Vibration & haptics', summary: 'On'),
              _androidNav('Phone ringtone', summary: 'Your New Adventure'),
            ],
          ),
        ]),
      ),
      _androidCategory(
        'display',
        'Display & touch',
        'Dark theme, font size, touch',
        Icons.brightness_medium_outlined,
        (_) => _page([
          SettingsSection(
            title: const Text('Brightness'),
            tiles: [
              _androidNav('Brightness level', summary: '83%'),
              _switch('Adaptive brightness', value: true),
            ],
          ),
          SettingsSection(
            title: const Text('Lock display'),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Lock screen'),
                description: const Text('Show all notification content'),
                destination: SettingsDestination(
                  id: 'lock-screen',
                  builder: (_) => _page([
                    SettingsSection(
                      tiles: [
                        _androidNav(
                          'Privacy',
                          summary: 'Show all notification content',
                        ),
                        _switch('Show wallet', value: true),
                        _switch('Use device controls', value: true),
                        _switch('Always show time and info'),
                      ],
                    ),
                  ]),
                ),
              ),
              _androidNav('Screen timeout', summary: 'After 30 seconds'),
            ],
          ),
          SettingsSection(
            title: const Text('Appearance'),
            tiles: [
              _switch(
                'Dark theme',
                description: const Text('Will turn on when Bedtime starts'),
              ),
              _androidNav('Screen saver', summary: 'On / Clock'),
              _androidNav('Display size and text'),
            ],
          ),
        ]),
      ),
      _androidCategory(
        'wallpaper',
        'Wallpaper & style',
        'Colors, themed icons, app grid',
        Icons.palette_outlined,
        (_) => const _DemoSwitch(title: 'Themed icons'),
      ),
      _androidCategory(
        'accessibility',
        'Accessibility',
        'Display, interaction, audio',
        Icons.accessibility_new,
        (_) => _page([
          SettingsSection(
            tiles: [
              _androidNav('TalkBack', summary: 'Off'),
              _androidNav('Select to Speak', summary: 'Off'),
            ],
          ),
          SettingsSection(
            title: const Text('Display'),
            tiles: [
              _androidNav('Display size and text'),
              _androidNav('Color and motion'),
            ],
          ),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _androidCategory(
        'security',
        'Security & privacy',
        'App security, device lock, permissions',
        Icons.security_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _androidNav('App security', summary: 'No apps scanned'),
              _androidNav('Device unlock', summary: 'Screen lock is set'),
              _androidNav(
                'Privacy controls',
                summary: 'Permissions, account activity',
              ),
            ],
          ),
        ]),
      ),
      _androidCategory(
        'location',
        'Location',
        'On · 3 apps have access to location',
        Icons.location_on_outlined,
        (_) => const _DemoSwitch(title: 'Use location', value: true),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _androidCategory(
        'battery',
        'Battery',
        '100%',
        Icons.battery_full,
        (_) => _page([
          SettingsSection(
            tiles: [
              _androidNav('Battery usage'),
              _switch('Battery Saver'),
              _switch('Adaptive Battery', value: true),
            ],
          ),
        ]),
      ),
      _androidCategory(
        'storage',
        'Storage',
        '34% used - 84.3 GB free',
        Icons.storage_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _androidNav('Apps', summary: '21 GB'),
              _androidNav('Images', summary: '8.1 GB'),
              _androidNav('System', summary: '14 GB'),
            ],
          ),
        ]),
      ),
      _androidCategory(
        'system',
        'System',
        'Languages, gestures, time, backup',
        Icons.info_outline,
        (_) => _page([
          SettingsSection(
            tiles: [
              _androidNav('Languages', summary: 'English (United States)'),
              _androidNav('Gestures'),
              _androidNav(
                'Date & time',
                summary: 'GMT-07:00 Pacific Daylight Time',
              ),
            ],
          ),
        ]),
      ),
    ],
  ),
];

// Chrome settings ---------------------------------------------------------------

SettingsTile _chromePage(
  String id,
  String title,
  IconData icon,
  WidgetBuilder builder,
) => SettingsTile.navigation(
  leading: Icon(icon),
  title: Text(title),
  destination: SettingsDestination(id: id, builder: builder),
);

SettingsTile _chromeNav(String title, {String? description}) =>
    SettingsTile.navigation(
      title: Text(title),
      description: description == null ? null : Text(description),
      onPressed: (_) {},
    );

List<AbstractSettingsSection> _chromeSections() => [
  SettingsSection(
    tiles: [
      _chromePage(
        'you-and-google',
        'You and Google',
        Icons.account_circle_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _chromeNav('Google services'),
              _chromeNav('Customize profile'),
              _chromeNav('Import bookmarks and settings'),
            ],
          ),
        ]),
      ),
      _chromePage(
        'autofill',
        'Autofill and passwords',
        Icons.vpn_key_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _chromeNav('Google Password Manager'),
              _chromeNav('Payment methods'),
              _chromeNav('Addresses and more'),
            ],
          ),
        ]),
      ),
      _chromePage(
        'privacy',
        'Privacy and security',
        Icons.shield_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _chromeNav(
                'Delete browsing data',
                description: 'Delete history, cookies, cache, and more',
              ),
              _chromeNav(
                'Privacy Guide',
                description: 'Review key privacy and security controls',
              ),
              _chromeNav(
                'Third-party cookies',
                description: 'Third-party cookies are allowed',
              ),
              SettingsTile.navigation(
                title: const Text('Security'),
                description: const Text(
                  'Safe Browsing (protection from dangerous sites) and other '
                  'security settings',
                ),
                destination: SettingsDestination(
                  id: 'security',
                  builder: (_) => _page([
                    SettingsSection(
                      title: const Text('Safe Browsing'),
                      tiles: [
                        _chromeNav(
                          'Enhanced protection',
                          description:
                              'Faster, proactive protection against '
                              'dangerous websites, downloads, and extensions',
                        ),
                        _chromeNav(
                          'Standard protection',
                          description:
                              'Protects against sites, downloads, and '
                              'extensions that are known to be dangerous',
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: const Text('Advanced'),
                      tiles: [
                        _switch('Always use secure connections', value: true),
                        _chromeNav('Manage certificates'),
                      ],
                    ),
                  ]),
                ),
              ),
              _chromeNav(
                'Site settings',
                description:
                    'Controls what information sites can use and show '
                    '(location, camera, pop-ups, and more)',
              ),
            ],
          ),
        ]),
      ),
      _chromePage(
        'performance',
        'Performance',
        Icons.speed,
        (_) => _page([
          SettingsSection(
            title: const Text('General'),
            tiles: [
              _switch(
                'Performance issue alerts',
                value: true,
                description: const Text(
                  'Get notifications that suggest ways to improve detected '
                  'performance issues',
                ),
              ),
              _switch(
                'Inactive tabs appearance',
                value: true,
                description: const Text(
                  'A dotted circle appears around site icons',
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Memory'),
            tiles: [
              _switch(
                'Memory Saver',
                description: const Text(
                  'Chrome frees up memory from inactive tabs.',
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Power'),
            tiles: [_switch('Energy Saver', value: true)],
          ),
        ]),
      ),
      _chromePage(
        'ai',
        'AI innovations',
        Icons.auto_awesome_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _chromeNav('Tab organizer'),
              _chromeNav('Help me write'),
              _chromeNav('History search, powered by AI'),
            ],
          ),
        ]),
      ),
      _chromePage(
        'appearance',
        'Appearance',
        Icons.palette_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _chromeNav('Theme'),
              _chromeNav('Customize your toolbar'),
              SettingsTile.navigation(
                title: const Text('Mode'),
                value: const Text('Device'),
                onPressed: (_) {},
              ),
              _switch('Show home button', description: const Text('Disabled')),
              _switch('Show tab search button', value: true),
              SettingsTile.navigation(
                title: const Text('Font size'),
                value: const Text('Medium (Recommended)'),
                onPressed: (_) {},
              ),
              _chromeNav('Customize fonts'),
            ],
          ),
        ]),
      ),
      _chromePage(
        'search-engine',
        'Search engine',
        Icons.search,
        (_) => _page([
          SettingsSection(
            tiles: [
              SettingsTile.navigation(
                title: const Text('Search engine used in the address bar'),
                value: const Text('Google'),
                onPressed: (_) {},
              ),
              _chromeNav('Manage search engines and site search'),
            ],
          ),
        ]),
      ),
      _chromePage(
        'default-browser',
        'Default browser',
        Icons.web_asset,
        (_) => _page([
          SettingsSection(
            tiles: [
              _chromeNav(
                'Default browser',
                description: 'Make Google Chrome the default browser',
              ),
            ],
          ),
        ]),
      ),
      _chromePage(
        'on-startup',
        'On startup',
        Icons.power_settings_new,
        (_) => _page([
          SettingsSection(
            tiles: [
              SettingsTile(
                title: const Text('Open the New Tab page'),
                trailing: const Icon(Icons.radio_button_checked),
                onPressed: (_) {},
              ),
              SettingsTile(
                title: const Text('Continue where you left off'),
                trailing: const Icon(Icons.radio_button_off),
                onPressed: (_) {},
              ),
            ],
          ),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      _chromePage(
        'languages',
        'Languages',
        Icons.translate,
        (_) => _page([
          SettingsSection(
            title: const Text('Preferred languages'),
            tiles: [_chromeNav('English (United States)')],
          ),
          SettingsSection(
            title: const Text('Google Translate'),
            tiles: [_switch('Use Google Translate', value: true)],
          ),
        ]),
      ),
      _chromePage(
        'downloads',
        'Downloads',
        Icons.download,
        (_) => _page([
          SettingsSection(
            tiles: [
              SettingsTile(
                title: const Text('Location'),
                description: const Text('/Users/you/Downloads'),
              ),
              _switch('Ask where to save each file before downloading'),
              _switch('Show downloads when they\'re done', value: true),
            ],
          ),
        ]),
      ),
      _chromePage(
        'accessibility',
        'Accessibility',
        Icons.accessibility_new,
        (_) => _page([
          SettingsSection(
            tiles: [
              _switch('Live Caption'),
              _switch('Show a quick highlight on the focused object'),
              _switch('Navigate pages with a text cursor'),
            ],
          ),
        ]),
      ),
      _chromePage(
        'system',
        'System',
        Icons.build_outlined,
        (_) => _page([
          SettingsSection(
            tiles: [
              _switch(
                'Continue running background apps when Google Chrome is '
                'closed',
              ),
              _switch('Use graphics acceleration when available', value: true),
              _chromeNav('Open your computer\'s proxy settings'),
            ],
          ),
        ]),
      ),
      _chromePage(
        'reset',
        'Reset settings',
        Icons.restart_alt,
        (_) => _page([
          SettingsSection(
            tiles: [_chromeNav('Restore settings to their original defaults')],
          ),
        ]),
      ),
    ],
  ),
  SettingsSection(
    tiles: [
      SettingsTile(
        leading: const Icon(Icons.extension_outlined),
        title: const Text('Extensions'),
        trailing: const Icon(Icons.open_in_new, size: 20),
        onPressed: (_) {},
      ),
      _chromePage(
        'about',
        'About Chrome',
        Icons.info_outline,
        (_) => _page([
          SettingsSection(
            tiles: [
              SettingsTile(
                title: const Text('Google Chrome is up to date'),
                description: const Text(
                  'Version 142.0.7444.60 (Official Build)',
                ),
              ),
              _chromeNav('Get help with Chrome'),
            ],
          ),
        ]),
      ),
    ],
  ),
];
