import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class TestWidgetScreen extends StatefulWidget {
  final DevicePlatform? platform;
  final ApplicationType applicationType;
  final List<AbstractSettingsTile> settingsTiles;

  const TestWidgetScreen({
    Key? key,
    this.platform,
    this.applicationType = ApplicationType.material,
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
          dividerColor: Colors.pink,
          tileDescriptionTextColor: Colors.blue,
          leadingIconsColor: Colors.red,
          settingsListBackground: Colors.grey,
          settingsSectionBackground: Colors.tealAccent,
          settingsTileTextColor: Colors.green,
          tileHighlightColor: Colors.yellow,
          titleTextColor: Colors.cyan,
          trailingTextColor: Colors.orange,
        ),
        lightTheme: const SettingsThemeData(),
        platform: widget.platform,
        applicationType: widget.applicationType,
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
