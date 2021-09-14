import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui_v2.dart';

class CrossPlatformSettingsScreen extends StatefulWidget {
  const CrossPlatformSettingsScreen({
    Key key,
  }) : super(key: key);

  @override
  State<CrossPlatformSettingsScreen> createState() =>
      _CrossPlatformSettingsScreenState();
}

class _CrossPlatformSettingsScreenState
    extends State<CrossPlatformSettingsScreen> {
  bool useCustomTheme = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings UI'),
      ),
      body: SettingsList(
        platform: DevicePlatform.android,
        theme: !useCustomTheme
            ? null
            : SettingsThemeData(
                dividerColor: Colors.red,
                tileDescriptionTextColor: Colors.yellow,
                leadingIconsColor: Colors.pink,
                settingsListBackground: Colors.white,
                settingsSectionBackground: Colors.green,
                settingsTileTextColor: Colors.tealAccent,
                tileHighlightColor: Colors.blue,
                titleTextColor: Colors.cyan,
                trailingTextColor: Colors.deepOrangeAccent,
              ),
        sections: [
          SettingsSection(
            title: Text('Common'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text('Language'),
                value: Text('English'),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.cloud_outlined),
                title: Text('Environment'),
                value: Text('Production'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    useCustomTheme = value;
                  });
                },
                initialValue: useCustomTheme,
                leading: Icon(Icons.format_paint),
                title: Text('Enable custom theme'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Account'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.phone),
                title: Text('Phone number'),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.mail),
                title: Text('Email'),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.logout),
                title: Text('Sign out'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Security'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (_) {},
                initialValue: true,
                leading: Icon(Icons.phonelink_lock),
                title: Text('Lock app in background'),
              ),
              SettingsTile.switchTile(
                onToggle: (_) {},
                initialValue: true,
                leading: Icon(Icons.fingerprint),
                title: Text('Use fingerprint'),
                description: Text(
                  'Allow application to access stored fingerprint IDs',
                ),
              ),
              SettingsTile.switchTile(
                onToggle: (_) {},
                initialValue: true,
                leading: Icon(Icons.lock),
                title: Text('Change password'),
              ),
              SettingsTile.switchTile(
                onToggle: (_) {},
                initialValue: true,
                leading: Icon(Icons.notifications_active),
                title: Text('Enable notifications'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Misc'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.description),
                title: Text('Terms of Service'),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.collections_bookmark),
                title: Text('Open source license'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
