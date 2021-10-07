# Settings UI for Flutter

[![Pub Version](https://img.shields.io/pub/v/settings_ui?color=blueviolet)](https://pub.dev/packages/settings_ui)

<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/flutter_settings_ui_logo.png" height="500px">
</p>


## Installing:
In your pubspec.yaml
```yaml
dependencies:
  settings_ui: <latest version>
```
```dart
import 'package:settings_ui/settings_ui_v2.dart';
```


## Basic Usage:
```dart
      SettingsList(
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
                        title: Text('Highlight Clipped Banners'),
                      ),
                      SettingsTile.switchTile(
                        onToggle: (_) {},
                        initialValue: false,
                        title: Text('Unlimited Ad Presentation'),
                      ),
                    ],
                  ),
                ],
              )
```
<br>
<br>

## Widgets
<br>
<b>SettingsTile:</b>
<ul>
<li>Simple tile</li>
```dart
  SettingsTile(
        onPressed: (BuildContext context) {
            //TODO: Add implementation
        },
        title: Text(
           'Clear Trusted Computers',
            style: TextStyle(color: CupertinoColors.activeBlue),
        ),
        description: Text(
            'Removing trusted computers will delete all '
            'of the records of computers that you have '
            'paired with previously',
        ),
  )
```
<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/dev/assets/simple-tile.png" with="600px">
</p>
<br>
<li>Switch tile</li>
```dart
    SettingsTile.switchTile(
        onToggle: (value) {
            setState(() {
                darkTheme = value;
            });
        },
        initialValue: darkTheme,
        title: Text('Dark Appearance'),
    )
```
<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/dev/assets/switch-tile.png" with="600px">
</p>
<br>
<li>Navigation tile</li>
```dart
    SettingsTile.navigation(
        onPressed: (_) {},
        title: Text('View'),
        value: Text('Standard'),
        description: Text(
            'Choose a view for iPhone. '
            'Zoomed shadows larger controls. '
            'Standart shows more content.',
        ),
    )
```
<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/dev/assets/navigation-tile.png" with="600px">
</p>
<br>
<b>SettingsSection:</b>
The SettingsSection makes it easy to combine setting tiles of the same category
```dart
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
                title: Text('Highlight Clipped Banners'),
            ),
            SettingsTile.switchTile(
                onToggle: (_) {},
                initialValue: false,
                title: Text('Unlimited Ad Presentation'),
            ),
        ],
    )
```
<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/dev/assets/settings-section.png" with="600px">
</p>
<br>
<b>SettingsList:</b>
The SettingsList widget allows easily combine setting sections, specify settings theme, contentPadding and platform for all widgets
```dart
    SettingsList(
          platform: DevicePlatform.iOS,
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          theme: SettingsThemeData(
              trailingTextColor: Colors.white,
              settingsListBackground: Colors.orangeAccent,
              settingsSectionBackground: Colors.red,
              dividerColor: Colors.white,
              titleTextColor: Colors.white,
              leadingIconsColor: Colors.green,
              tileDescriptionTextColor: Colors.white,
              settingsTileTextColor: Colors.white),
          sections: [ ... ],
    )
```
<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/dev/assets/settings-list.png" with="600px">
</p>
## Settings UI supports dark mode:
<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/dark_mode_animation.gif" height="600px">
</p>
<br>


## License
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details
