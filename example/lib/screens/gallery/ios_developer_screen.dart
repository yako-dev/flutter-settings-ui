import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class IosDeveloperScreen extends StatefulWidget {
  const IosDeveloperScreen({Key key}) : super(key: key);

  @override
  _IosDeveloperScreen createState() => _IosDeveloperScreen();
}

class _IosDeveloperScreen extends State<IosDeveloperScreen> {
  bool darkTheme = true;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Developer')),
      child: SafeArea(
        bottom: false,
        child: SettingsList(
          applicationType: ApplicationType.cupertino,
          platform: DevicePlatform.iOS,
          sections: [
            SettingsSection(
              title: Text('APPEARANCE'),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) {
                    setState(() {
                      darkTheme = value;
                    });
                  },
                  initialValue: darkTheme,
                  title: Text('Dark Appearance'),
                ),
              ],
            ),
            SettingsSection(
              title: Text('DISPLAY ZOOM'),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {},
                  title: Text('View'),
                  value: Text('Standard'),
                  description: Text(
                    'Choose a view for iPhone. '
                    'Zoomed shadows larger controls. '
                    'Standart shows more content.',
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('UI AUTOMATION'),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (_) {},
                  initialValue: true,
                  title: Text('Enable UI Automation'),
                ),
                SettingsTile.navigation(
                  title: Text('Multipath Networking'),
                ),
                SettingsTile.switchTile(
                  onToggle: (_) {},
                  initialValue: false,
                  title: Text('HTTP/3'),
                ),
              ],
            ),
            SettingsSection(
              title: Text('STATE RESTORATION TESTING'),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (_) {},
                  initialValue: false,
                  title: Text(
                    'Fast App Termination',
                  ),
                  description: Text(
                    'Terminate instead of suspending apps when backgrounded to '
                    'force apps to be relaunched when tray '
                    'are foregrounded.',
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('IAD DEVELOPER APP TESTING'),
              tiles: [
                SettingsTile.navigation(
                  title: Text('Fill Rate'),
                ),
                SettingsTile.navigation(
                  title: Text('Add Refresh Rate'),
                ),
                SettingsTile.switchTile(
                  onToggle: (_) {},
                  initialValue: false,
                  title: Text('Unlimited Ad Presentation'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
