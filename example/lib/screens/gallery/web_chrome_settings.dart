import 'package:example/screens/gallery/web_chrome_addresses_settings.dart';
import 'package:example/utils/navigation.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class WebChromeSettings extends StatelessWidget {
  const WebChromeSettings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SettingsList(
        platform: DevicePlatform.web,
        sections: [
          SettingsSection(
            title: Text('Auto-fill'),
            tiles: [
              SettingsTile.navigation(
                onPressed: (_) {},
                leading: Icon(Icons.vpn_key),
                title: Text('Passwords'),
              ),
              SettingsTile.navigation(
                onPressed: (_) {},
                leading: Icon(Icons.credit_card_outlined),
                title: Text('Payment methods'),
              ),
              SettingsTile.navigation(
                onPressed: (_) {
                  Navigation.navigateTo(
                    context: context,
                    screen: WebChromeAddressesScreen(),
                    style: NavigationRouteStyle.material,
                  );
                },
                leading: Icon(Icons.location_on),
                title: Text('Addresses and more'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Privacy and security'),
            tiles: [
              SettingsTile.navigation(
                onPressed: (_) {},
                leading: Icon(Icons.delete),
                title: Text('Clear browsing data'),
                description: Text('Clear history, cookies, cache and more'),
              ),
              SettingsTile.navigation(
                onPressed: (_) {},
                leading: Icon(Icons.web),
                title: Text('Cookies and other site data'),
                description:
                    Text('Third-party cookies are blocked in Incognito mode'),
              ),
              SettingsTile.navigation(
                onPressed: (_) {},
                leading: Icon(Icons.security),
                title: Text('Security'),
                description: Text(
                    'Safe Browsing (protection from dangerous sites) and other security settings'),
              ),
              SettingsTile.navigation(
                onPressed: (_) {},
                leading: Icon(Icons.settings),
                title: Text('Site settings'),
                description: Text(
                    'Controls what information sites can use and show (location, camera, pop-ups and more)'),
              ),
              SettingsTile.navigation(
                onPressed: (_) {},
                leading: Icon(Icons.account_balance_outlined),
                title: Text('Privacy Sandbox'),
                description: Text('Trial features are on'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
