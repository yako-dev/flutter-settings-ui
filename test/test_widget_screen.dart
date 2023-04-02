import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class TestWidgetScreen extends StatefulWidget {
  final DevicePlatform? platform;
  final List<AbstractSettingsTile> settingsTiles;

  const TestWidgetScreen({
    Key? key,
    this.platform,
    required this.settingsTiles,
  }) : super(key: key);

  @override
  State<TestWidgetScreen> createState() => _TestWidgetScreenState();
}

class _TestWidgetScreenState extends State<TestWidgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: SettingsList(
        darkTheme: const SettingsThemeData(
          tilesDividerColor: Colors.pink,
          tileDescriptionTextColor: Colors.blue,
          tileLeadingIconsColor: Colors.red,
          settingsListBackground: Colors.grey,
          settingsSectionBackground: Colors.tealAccent,
          tileTitleTextColor: Colors.green,
          tileHighlightColor: Colors.yellow,
          titleTextColor: Colors.cyan,
          tileTrailingTextColor: Colors.orange,
        ),
        lightTheme: const SettingsThemeData(),
        platform: widget.platform,
        sections: [
          SettingsSection(
            title: const Text('General'),
            tiles: widget.settingsTiles,
          ),
          CustomSettingsSection(
            child: Container(
              height: 50,
              color: Colors.red,
              child: const Text('Custom settings section'),
            ),
          )
        ],
      ),
    );
  }
}
