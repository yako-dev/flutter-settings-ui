# Settings UI for Flutter

[![pub package](https://img.shields.io/badge/pub-0.1.0-blueviolet.svg)](https://pub.dev/packages/settings_ui)

<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/flutter_settings_ui_logo.png" height="400px">
</p>


## Installing:
In your pubspec.yaml
```yaml
dependencies:
  settings_ui: ^0.1.0
```
```dart
import 'package:settings_ui/settings_ui.dart';
```


## Basic Usage:
```dart
    StatusAlert.show(
      context,
      duration: Duration(seconds: 2),
      title: 'Title',
      subtitle: 'Subtitle',
      configuration: IconConfiguration(icon: Icons.done),
    )
```
<br>
<br>

## Settings UI supports dark mode:
<img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/dark_mode_animation.gif" height="400px">
<br>


## License
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details
