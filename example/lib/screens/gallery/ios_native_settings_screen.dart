import 'package:example/widgets/leading_ios_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class IosNativeSettingsScreen extends StatefulWidget {
  const IosNativeSettingsScreen({Key key}) : super(key: key);

  @override
  State<IosNativeSettingsScreen> createState() =>
      _IosNativeSettingsScreenState();
}

class _IosNativeSettingsScreenState extends State<IosNativeSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Settings')),
      child: SafeArea(
        bottom: false,
        child: SettingsList(
          platform: DevicePlatform.iOS,
          sections: [
            /// Person Settings Section
            SettingsSection(
              title: Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
              tiles: [
                SettingsTile(
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CircleAvatar(
                      child: Icon(
                        CupertinoIcons.person_alt_circle,
                        size: 45,
                        color: Colors.white,
                      ),
                      radius: 25,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  title: Text(
                    'Sign in to your iPhone',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                  titleDescription: Text(
                    'Set up iCloud, the App Store, and more.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            /// Screen Time Section
            SettingsSection(
              tiles: [
                SettingsTile.navigation(
                  leading: LeadingIosWidget(
                    backgroundColor: Colors.deepPurple,
                    iconColor: Colors.white,
                    iconData: CupertinoIcons.hourglass,
                  ),
                  title: Text('Screen time'),
                )
              ],
            ),

            /// Settings General Section
            SettingsSection(
              tiles: [
                SettingsTile.navigation(
                  leading: LeadingIosWidget(
                    backgroundColor: Colors.grey,
                    iconColor: Colors.white,
                    iconData: CupertinoIcons.settings,
                  ),
                  title: Text('General'),
                ),
                SettingsTile.navigation(
                  leading: LeadingIosWidget(
                    backgroundColor: Colors.blue,
                    iconColor: Colors.white,
                    iconData: CupertinoIcons.person_alt_circle,
                  ),
                  title: Text('Accessibility'),
                ),
                SettingsTile.navigation(
                  leading: LeadingIosWidget(
                    backgroundColor: Colors.blue,
                    iconColor: Colors.white,
                    iconData: CupertinoIcons.hand_raised_fill,
                  ),
                  title: Text('Privacy'),
                ),
              ],
            ),
            SettingsSection(
              tiles: [
                SettingsTile.navigation(
                  leading: LeadingIosWidget(
                    backgroundColor: Colors.grey,
                    iconColor: Colors.white,
                    iconData: Icons.key,
                  ),
                  title: Text('Passwords'),
                )
              ],
            ),
            SettingsSection(
              tiles: [
                SettingsTile.navigation(
                  leading: LeadingIosWidget(
                    backgroundColor: Colors.red,
                    iconColor: Colors.white,
                    iconData: CupertinoIcons.news,
                  ),
                  title: Text('News'),
                ),
                SettingsTile.navigation(
                  leading: LeadingIosWidget(
                    backgroundColor: Colors.black,
                    iconColor: Colors.white,
                    iconData: CupertinoIcons.paperplane,
                  ),
                  title: Text('Maps'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
