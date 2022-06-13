import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class WebChromeAddressesScreen extends StatefulWidget {
  WebChromeAddressesScreen({Key key}) : super(key: key);

  @override
  State<WebChromeAddressesScreen> createState() =>
      _WebChromeAddressesScreenState();
}

class _WebChromeAddressesScreenState extends State<WebChromeAddressesScreen> {
  bool _toggle = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Addresses and more')),
      body: SettingsList(
        platform: DevicePlatform.web,
        sections: [
          SettingsSection(
            margin: EdgeInsetsDirectional.only(top: 40),
            tiles: [
              SettingsTile.switchTile(
                initialValue: _toggle,
                onToggle: (_) {
                  setState(() {
                    _toggle = _;
                  });
                },
                trailing: Icon(Icons.info),
                title: Text('Save and fill addresses'),
                description: Text(
                    'Include information like phone numbers, email, and shipping addresses'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Addresses'),
            tiles: [
              SettingsTile.navigation(
                onPressed: (_) {},
                title: Text('Name, addresses'),
                trailing: Icon(Icons.more_vert),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
