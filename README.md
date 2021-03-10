# Settings UI for Flutter

[![Pub Version](https://img.shields.io/pub/v/settings_ui?color=blueviolet)](https://pub.dev/packages/settings_ui)

<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/flutter_settings_ui_logo.png" height="500px">
</p>


## Installing:
In your pubspec.yaml
```yaml
dependencies:
  settings_ui: ^0.7.0
```
```dart
import 'package:settings_ui/settings_ui.dart';
```


## Basic Usage:
```dart
      SettingsList(
        sections: [
          SettingsSection(
            title: 'Section',
            tiles: [
              SettingsTile(
                title: 'Language',
                subtitle: 'English',
                leading: Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile.switchTile(
                title: 'Use fingerprint',
                leading: Icon(Icons.fingerprint),
                switchValue: value,
                onToggle: (bool value) {},
              ),
            ],
          ),
        ],
      )
```
<br>
<br>

## Settings UI supports dark mode:
<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/dark_mode_animation.gif" height="600px">
</p>
<br>


## License
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details
