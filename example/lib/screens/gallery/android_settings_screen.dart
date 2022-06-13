import 'package:example/screens/gallery/android_notifications_screen.dart';
import 'package:example/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class AndroidSettingsScreen extends StatelessWidget {
  const AndroidSettingsScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SettingsList(
        platform: DevicePlatform.android,
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Network & internet'),
                description: Text('Mobile, Wi-Fi, hotspot'),
                leading: Icon(Icons.wifi),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Connected devices'),
                description: Text('Bluetooth, pairing'),
                leading: Icon(Icons.devices_other),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Apps'),
                description: Text('Assistant, recent apps, default apps'),
                leading: Icon(Icons.apps),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Notifications'),
                description: Text('Notification history, conversations'),
                leading: Icon(Icons.notifications_none),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Battery'),
                description: Text('100%'),
                leading: Icon(Icons.battery_full),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Storage'),
                description: Text('30% used - 5.60 GB free'),
                leading: Icon(Icons.storage),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Sound & vibration'),
                description: Text('Volume, haptics, Do Not Disturb'),
                leading: Icon(Icons.volume_up_outlined),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Display'),
                enabled: false,
                description: Text('Dark theme, font size, brightness'),
                leading: Icon(Icons.brightness_6_outlined),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Wallpaper & style'),
                description: Text('Colors, themed icons, app grid'),
                leading: Icon(Icons.palette_outlined),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Accessibility'),
                description: Text('Display, interaction, audio'),
                leading: Icon(Icons.accessibility),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Security'),
                description: Text('Screen lock, Find My Device, app security'),
                leading: Icon(Icons.lock_outline),
              ),
              SettingsTile(
                onPressed: (context) => toNotificationsScreen(context),
                title: Text('Location'),
                description: Text('On - 3 apps have access to location'),
                leading: Icon(Icons.location_on_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void toNotificationsScreen(BuildContext context) {
    Navigation.navigateTo(
      context: context,
      screen: AndroidNotificationsScreen(),
      style: NavigationRouteStyle.material,
    );
  }
}
