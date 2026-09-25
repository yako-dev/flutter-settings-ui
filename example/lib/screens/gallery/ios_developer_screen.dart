import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

class IosDeveloperScreen extends StatefulWidget {
  const IosDeveloperScreen({super.key});

  @override
  State<IosDeveloperScreen> createState() => _IosDeveloperScreenState();
}

class _IosDeveloperScreenState extends State<IosDeveloperScreen> {
  bool darkTheme = true;

  /// The other switches' values, by title, so that they toggle.
  final _switches = <String, bool>{
    'Enable UI Automation': true,
    'HTTP/3': false,
    'Fast App Termination': false,
    'Unlimited Ad Presentation': false,
  };
  final ScrollController settingsListController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Developer')),
      child: SafeArea(
        bottom: false,
        child: SettingsList(
          scrollController: settingsListController,
          applicationType: ApplicationType.cupertino,
          platform: DevicePlatform.iOS,
          sections: [
            SettingsSection(
              title: Text('Appearance'),
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
              title: Text('Display zoom'),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (_) {
                    settingsListController.animateTo(
                      100,
                      duration: Duration(seconds: 1),
                      curve: Curves.linear,
                    );
                  },
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
              title: Text('UI automation'),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) =>
                      setState(() => _switches['Enable UI Automation'] = value),
                  initialValue: _switches['Enable UI Automation']!,
                  title: Text('Enable UI Automation'),
                ),
                SettingsTile.navigation(title: Text('Multipath Networking')),
                SettingsTile.switchTile(
                  onToggle: (value) =>
                      setState(() => _switches['HTTP/3'] = value),
                  initialValue: _switches['HTTP/3']!,
                  title: Text('HTTP/3'),
                ),
              ],
            ),
            SettingsSection(
              title: Text('State restoration testing'),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) =>
                      setState(() => _switches['Fast App Termination'] = value),
                  initialValue: _switches['Fast App Termination']!,
                  title: Text('Fast App Termination'),
                  description: Text(
                    'Terminate instead of suspending apps when backgrounded to '
                    'force apps to be relaunched when tray '
                    'are foregrounded.',
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('iAd developer app testing'),
              tiles: [
                SettingsTile.navigation(
                  title: Text('Downtime'),
                  titleDescription: Text('Schedule time away from the screen.'),
                  leading: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Icon(
                      CupertinoIcons.clock,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                SettingsTile.navigation(title: Text('Add Refresh Rate')),
                SettingsTile.switchTile(
                  onToggle: (value) => setState(
                    () => _switches['Unlimited Ad Presentation'] = value,
                  ),
                  initialValue: _switches['Unlimited Ad Presentation']!,
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
