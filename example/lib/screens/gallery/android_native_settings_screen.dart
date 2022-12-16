import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class AndroidNativeSettingsScreen extends StatefulWidget {
  const AndroidNativeSettingsScreen({Key key}) : super(key: key);

  @override
  State<AndroidNativeSettingsScreen> createState() =>
      _AndroidNativeSettingsScreenState();
}

class _AndroidNativeSettingsScreenState
    extends State<AndroidNativeSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 240, 240, 1),
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        shrinkWrap: false,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0, right: 24),
              child: Icon(
                Icons.person_pin,
                size: 40,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              autofocus: false,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search Settings',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14.0, vertical: 13.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(25.7),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(25.7),
                ),
              ),
            ),
          ),
          SettingsList(
            platform: DevicePlatform.android,
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile(
                    title: Text('Network & internet'),
                    description: Text('Mobile, Wi-Fi, hotspot'),
                    leading: Icon(Icons.wifi),
                  ),
                  SettingsTile(
                    title: Text('Connected devices'),
                    description: Text('Bluetooth, pairing'),
                    leading: Icon(Icons.devices_other),
                  ),
                  SettingsTile(
                    title: Text('Apps'),
                    description: Text('Assistant, recent apps, default apps'),
                    leading: Icon(Icons.apps),
                  ),
                  SettingsTile(
                    title: Text('Notifications'),
                    description: Text('Notification history, conversations'),
                    leading: Icon(Icons.notifications_none),
                  ),
                  SettingsTile(
                    title: Text('Battery'),
                    description: Text('100%'),
                    leading: Icon(Icons.battery_full),
                  ),
                  SettingsTile(
                    title: Text('Storage'),
                    description: Text('30% used - 5.60 GB free'),
                    leading: Icon(Icons.storage),
                  ),
                  SettingsTile(
                    title: Text('Sound & vibration'),
                    description: Text('Volume, haptics, Do Not Disturb'),
                    leading: Icon(Icons.volume_up_outlined),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
