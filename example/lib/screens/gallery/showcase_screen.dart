import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:example/widgets/macos_widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// The settings of a fictional app, built once with [SettingsSplitView]: a
/// list on phones, and the list next to the selected page on tablets,
/// foldables, desktop and the web. The README's cover and gallery images are
/// screenshots of this screen.
///
/// Open it with the launch options (see `LaunchOptions`), e.g. `flutter run
/// --route '/showcase?platform=ios&page=privacy'`, or on the web
/// `/?screen=showcase&platform=windows&theme=dark`.
class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({
    super.key,
    this.platform = DevicePlatform.device,
    this.initialPageId,
  });

  final DevicePlatform platform;

  /// The page to open, like a deep link: `account`, `appearance`,
  /// `language`, `notifications`, `privacy`, `sync`, `storage`, `help` or
  /// `about`.
  final String? initialPageId;

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

/// How the leading icons look in each style.
enum _Look { ios, macos, windows, android, gnome, web }

_Look _lookOf(DevicePlatform platform) => switch (platform) {
  DevicePlatform.iOS || DevicePlatform.device => _Look.ios,
  DevicePlatform.macOS => _Look.macos,
  DevicePlatform.windows => _Look.windows,
  DevicePlatform.android || DevicePlatform.fuchsia => _Look.android,
  DevicePlatform.linux => _Look.gnome,
  DevicePlatform.web => _Look.web,
};

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  final _controller = SettingsSplitController();

  /// Bumped on every change, so the open page rebuilds.
  final _revision = ValueNotifier<int>(0);
  final _values = <String, bool>{
    'biometric-lock': true,
    'hide-previews': false,
    'analytics': false,
    'crash-reports': true,
    'notifications': true,
    'reminders': true,
    'mentions': true,
    'weekly-summary': false,
    'product-news': false,
    'badge': true,
    'sync': true,
    'cellular-sync': false,
    'wifi-only': true,
    'bold-text': false,
    'reduce-motion': false,
  };
  String _theme = 'Automatic';
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    final page = widget.initialPageId;
    if (page != null) _controller.select(page);
  }

  @override
  void dispose() {
    _controller.dispose();
    _revision.dispose();
    super.dispose();
  }

  void _update(VoidCallback change) {
    setState(change);
    _revision.value++;
  }

  /// A page that rebuilds when a value changes.
  WidgetBuilder _live(WidgetBuilder builder) =>
      (context) => ListenableBuilder(
        listenable: _revision,
        builder: (context, _) => builder(context),
      );

  @override
  Widget build(BuildContext context) {
    final platform = widget.platform == DevicePlatform.device
        ? PlatformUtils.detectPlatform(context)
        : widget.platform;
    final look = _lookOf(platform);
    final brightness = Theme.of(context).brightness;

    final view = SettingsSplitView(
      key: ValueKey(platform),
      platform: widget.platform,
      title: const Text('Settings'),
      controller: _controller,
      sections: _sections(look),
    );

    // Android and the web take their colors from the ColorScheme: give the
    // app a brand color, as a real app would.
    return switch (look) {
      _Look.android => _seeded(
        context,
        const Color(0xFF3F6FD8),
        DynamicSchemeVariant.vibrant,
        brightness,
        view,
      ),
      _Look.web => _seeded(
        context,
        const Color(0xFF1A73E8),
        DynamicSchemeVariant.fidelity,
        brightness,
        view,
      ),
      _ => view,
    };
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

  // The list ----------------------------------------------------------------

  List<AbstractSettingsSection> _sections(_Look look) {
    // Android and GNOME show a summary under each category, like their
    // Settings apps; the others show a value at the end of some rows.
    final summaries = look == _Look.android || look == _Look.gnome;

    SettingsTile category(
      _Category c,
      WidgetBuilder builder, {
      String? value,
      String? summary,
    }) => SettingsTile.navigation(
      leading: _CategoryIcon(c, look),
      title: Text(c.titleFor(look)),
      value: !summaries && value != null ? Text(value) : null,
      description: summaries && summary != null ? Text(summary) : null,
      destination: SettingsDestination(id: c.id, builder: _live(builder)),
    );

    return [
      SettingsSection(
        tiles: [
          SettingsTile.navigation(
            leading: look == _Look.web
                ? const Icon(Icons.account_circle_outlined)
                : _Avatar(size: _avatarSize(look)),
            title: Text(look == _Look.web ? 'Account' : 'Alex Morgan'),
            description: summaries
                ? const Text('Pro plan · alex@example.com')
                : null,
            titleDescription: look == _Look.ios && !summaries
                ? const Text('Pro plan · 3 devices')
                : null,
            destination: SettingsDestination(
              id: 'account',
              title: const Text('Account'),
              builder: _live((_) => _accountPage(look)),
            ),
          ),
        ],
      ),
      SettingsSection(
        title: const Text('General'),
        tiles: [
          category(
            _Category.appearance,
            (_) => _appearancePage(look),
            value: _theme,
            summary: 'Theme, text size, motion',
          ),
          category(
            _Category.language,
            (_) => _languagePage(look),
            value: _language,
            summary: _language == 'English'
                ? 'English (United States)'
                : _language,
          ),
          category(
            _Category.notifications,
            (_) => _notificationsPage(look),
            value: _values['notifications']! ? 'On' : 'Off',
            summary: 'Reminders, mentions, sounds',
          ),
        ],
      ),
      SettingsSection(
        title: const Text('Data & privacy'),
        tiles: [
          category(
            _Category.privacy,
            (_) => _privacyPage(look),
            summary: '${_biometricName(look)}, analytics',
          ),
          category(
            _Category.sync,
            (_) => _syncPage(look),
            value: _values['sync']! ? 'On' : 'Off',
            summary: 'Synced just now',
          ),
          category(
            _Category.storage,
            (_) => _storagePage(look),
            value: '2.4 GB',
            summary: '2.4 GB used · 61 GB free',
          ),
        ],
      ),
      SettingsSection(
        title: const Text('Support'),
        tiles: [
          category(
            _Category.help,
            (_) => _helpPage(look),
            summary: 'Help center, contact us',
          ),
          category(
            _Category.about,
            (_) => _aboutPage(look),
            value: '4.0.0',
            summary: 'Version 4.0.0',
          ),
        ],
      ),
    ];
  }

  double _avatarSize(_Look look) => switch (look) {
    _Look.ios => 40,
    _Look.macos => 28,
    _Look.windows => 32,
    _Look.android => 40,
    _Look.gnome => 32,
    _Look.web => 24,
  };

  // Pages -------------------------------------------------------------------

  Widget _page(List<AbstractSettingsSection> sections) =>
      SettingsList(sections: sections);

  SettingsTile _switch(String id, String title, {Widget? description}) =>
      SettingsTile.switchTile(
        title: Text(title),
        description: description,
        initialValue: _values[id]!,
        onToggle: (value) => _update(() => _values[id] = value),
      );

  SettingsTile _info(String title, String value) =>
      SettingsTile(title: Text(title), value: Text(value));

  SettingsTile _link(String title, {String? value, String? description}) =>
      SettingsTile.navigation(
        title: Text(title),
        value: value == null ? null : Text(value),
        description: description == null ? null : Text(description),
        onPressed: (_) {},
      );

  String _biometricName(_Look look) => switch (look) {
    _Look.ios => 'Face ID',
    _Look.macos => 'Touch ID',
    _Look.windows => 'Windows Hello',
    _Look.android => 'Fingerprint unlock',
    _Look.gnome => 'Fingerprint unlock',
    _Look.web => 'Passkey',
  };

  Widget _accountPage(_Look look) => _page([
    SettingsSection(
      tiles: [
        _info('Name', 'Alex Morgan'),
        _info('Email', 'alex@example.com'),
        _info('Plan', 'Pro'),
      ],
    ),
    SettingsSection(
      title: const Text('Security'),
      tiles: [
        _link('Change password'),
        _link('Two-factor authentication', value: 'On'),
        _link('Signed-in devices', value: '3'),
      ],
    ),
    SettingsSection(
      tiles: [
        SettingsTile(
          title: Text(
            'Sign out',
            style: TextStyle(
              color: look == _Look.ios || look == _Look.macos
                  ? CupertinoColors.systemRed.resolveFrom(context)
                  : Theme.of(context).colorScheme.error,
            ),
          ),
          onPressed: (_) {},
        ),
      ],
    ),
  ]);

  Widget _check(_Look look, bool selected) {
    if (!selected) return const SizedBox(width: 24);
    return switch (look) {
      _Look.ios || _Look.macos => Icon(
        CupertinoIcons.check_mark,
        size: 22,
        color: CupertinoColors.activeBlue.resolveFrom(context),
      ),
      _ => Icon(
        Icons.check,
        size: 22,
        color: Theme.of(context).colorScheme.primary,
      ),
    };
  }

  Widget _appearancePage(_Look look) {
    SettingsTile option(String name) => SettingsTile(
      title: Text(name),
      trailing: _check(look, _theme == name),
      onPressed: (_) => _update(() => _theme = name),
    );
    return _page([
      SettingsSection(
        title: const Text('Theme'),
        tiles: [option('Light'), option('Dark'), option('Automatic')],
      ),
      SettingsSection(
        title: const Text('Text'),
        tiles: [
          _link('Text size', value: 'Default'),
          _switch('bold-text', 'Bold text'),
        ],
      ),
      SettingsSection(
        tiles: [
          _switch(
            'reduce-motion',
            'Reduce motion',
            description: const Text(
              'Turn off animated backgrounds and page transitions.',
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _languagePage(_Look look) {
    SettingsTile option(String name, String native) => SettingsTile(
      title: Text(name),
      titleDescription: name == native ? null : Text(native),
      trailing: _check(look, _language == name),
      onPressed: (_) => _update(() => _language = name),
    );
    return _page([
      SettingsSection(
        title: const Text('App language'),
        tiles: [
          option('English', 'English'),
          option('Español', 'Spanish'),
          option('Deutsch', 'German'),
          option('Français', 'French'),
          option('日本語', 'Japanese'),
        ],
      ),
    ]);
  }

  Widget _notificationsPage(_Look look) => _page([
    SettingsSection(tiles: [_switch('notifications', 'Allow notifications')]),
    SettingsSection(
      title: const Text('Notify me about'),
      tiles: [
        _switch('reminders', 'Reminders'),
        _switch('mentions', 'Mentions and replies'),
        _switch('weekly-summary', 'Weekly summary'),
        _switch('product-news', 'Product news'),
      ],
    ),
    SettingsSection(
      tiles: [
        _link('Sound', value: 'Chime'),
        _switch('badge', 'Badge app icon'),
      ],
    ),
  ]);

  Widget _privacyPage(_Look look) => _page([
    SettingsSection(
      title: const Text('App lock'),
      tiles: [
        _switch('biometric-lock', switch (look) {
          _Look.ios => 'Unlock with Face ID',
          _Look.macos => 'Unlock with Touch ID',
          _Look.windows => 'Unlock with Windows Hello',
          _Look.web => 'Sign in with a passkey',
          _ => 'Fingerprint unlock',
        }),
        _link('Require unlock', value: 'Immediately'),
        _switch(
          'hide-previews',
          'Hide content in app switcher',
          description: const Text(
            'Your notes stay private when you switch apps or share your '
            'screen.',
          ),
        ),
      ],
    ),
    SettingsSection(
      title: const Text('Analytics'),
      tiles: [
        _switch('analytics', 'Share usage analytics'),
        _switch(
          'crash-reports',
          'Send crash reports',
          description: const Text(
            'Reports are anonymous and help us fix bugs faster.',
          ),
        ),
      ],
    ),
    SettingsSection(
      tiles: [
        _link('Blocked accounts', value: 'None'),
        _link('Download your data'),
      ],
    ),
  ]);

  Widget _syncPage(_Look look) => _page([
    SettingsSection(
      tiles: [
        _switch(
          'sync',
          'Sync across devices',
          description: const Text(
            'Keep notes, tags and settings the same on all your devices.',
          ),
        ),
      ],
    ),
    SettingsSection(
      tiles: [
        _info('Last synced', 'Just now'),
        _switch('cellular-sync', 'Sync over mobile data'),
        _link('Backups', value: 'Daily'),
      ],
    ),
  ]);

  Widget _storagePage(_Look look) => _page([
    SettingsSection(
      tiles: [
        _info('Notes and attachments', '1.9 GB'),
        _info('Offline copies', '380 MB'),
        _info('Cache', '112 MB'),
      ],
    ),
    SettingsSection(
      tiles: [
        _switch('wifi-only', 'Download on Wi-Fi only'),
        _link('Clear cache'),
      ],
    ),
  ]);

  Widget _helpPage(_Look look) => _page([
    SettingsSection(
      tiles: [
        _link('Help center'),
        _link('Keyboard shortcuts'),
        _link('Contact support'),
      ],
    ),
    SettingsSection(tiles: [_link('Send feedback'), _link('Report a problem')]),
  ]);

  Widget _aboutPage(_Look look) => _page([
    SettingsSection(
      tiles: [_info('Version', '4.0.0 (412)'), _link('What’s new')],
    ),
    SettingsSection(
      tiles: [
        _link('Terms of service'),
        _link('Privacy policy'),
        _link('Open-source licenses'),
      ],
    ),
  ]);
}

// Leading icons --------------------------------------------------------------

/// A category of the list, with its icon in every style.
enum _Category {
  appearance(
    'appearance',
    'Appearance',
    CupertinoIcons.textformat_size,
    Icons.palette_outlined,
    Color(0xFF0088FF),
  ),
  language(
    'language',
    'Language',
    CupertinoIcons.globe,
    Icons.language,
    Color(0xFF0088FF),
  ),
  notifications(
    'notifications',
    'Notifications',
    CupertinoIcons.bell_fill,
    Icons.notifications_outlined,
    Color(0xFFFF3B30),
  ),
  privacy(
    'privacy',
    'Privacy & Security',
    CupertinoIcons.hand_raised_fill,
    Icons.shield_outlined,
    Color(0xFF34C759),
  ),
  sync(
    'sync',
    'Sync & Backup',
    CupertinoIcons.arrow_2_circlepath,
    Icons.cloud_outlined,
    Color(0xFF00C3D0),
  ),
  storage(
    'storage',
    'Storage',
    CupertinoIcons.archivebox_fill,
    Icons.folder_outlined,
    Color(0xFF8E8E93),
  ),
  help(
    'help',
    'Help & Feedback',
    CupertinoIcons.question,
    Icons.help_outline,
    Color(0xFFFF9500),
  ),
  about(
    'about',
    'About',
    CupertinoIcons.info,
    Icons.info_outline,
    Color(0xFF5856D6),
  );

  const _Category(
    this.id,
    this.title,
    this.cupertinoIcon,
    this.materialIcon,
    this.color,
  );

  final String id;

  /// The title in Title Case, as Apple writes it.
  final String title;
  final IconData cupertinoIcon;
  final IconData materialIcon;
  final Color color;

  /// Apple's styles use Title Case; Android, the web, Windows and GNOME
  /// write titles in sentence case.
  String titleFor(_Look look) => look == _Look.ios || look == _Look.macos
      ? title
      : title.replaceAllMapped(
          RegExp(r'(?<=& )[A-Z]'),
          (m) => m[0]!.toLowerCase(),
        );
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon(this.category, this.look);

  final _Category category;
  final _Look look;

  @override
  Widget build(BuildContext context) {
    return switch (look) {
      // iOS Settings: a white glyph on a colored rounded square.
      _Look.ios => ClipRSuperellipse(
        borderRadius: BorderRadius.circular(7),
        child: Container(
          width: 29,
          height: 29,
          color: category.color,
          alignment: Alignment.center,
          child: Icon(
            category.cupertinoIcon,
            color: CupertinoColors.white,
            size: 19,
          ),
        ),
      ),
      _Look.macos => MacosIconBadge(
        icon: category.cupertinoIcon,
        color: category.color,
      ),
      // Windows Settings: colored line icons.
      _Look.windows => Icon(category.materialIcon, color: category.color),
      _ => Icon(category.materialIcon),
    };
  }
}

/// A round avatar with initials, for the account row.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5AC8FA), Color(0xFF3F6FD8)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'AM',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1,
        ),
      ),
    );
  }
}
