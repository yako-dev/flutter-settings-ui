# Settings UI for Flutter

[![Pub Version](https://img.shields.io/pub/v/settings_ui?color=blueviolet)](https://pub.dev/packages/settings_ui)

<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/flutter_settings_ui_logo.png" height="500px">
</p>


## Installing:
In your pubspec.yaml
```yaml
dependencies:
  settings_ui: ^1.0.1
```
```dart
import 'package:settings_ui/settings_ui.dart';
```


## Basic Usage:
```dart
      SettingsList(
        sections: [
          SettingsSection(
            title: Text('Section',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            tiles: [
              SettingsTile(
                title: Text('Language',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                value: Text('English',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                leading: Icon(Icons.language),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile.switchTile(
                title: Text('Use fingerprint',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                leading: Icon(Icons.fingerprint),
                onToggle: (bool value) {},
              ),
            ],
          ),
        ],
      );
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
