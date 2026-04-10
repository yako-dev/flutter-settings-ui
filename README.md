# Settings UI for Flutter

[![Pub Version](https://img.shields.io/pub/v/settings_ui?color=blueviolet)](https://pub.dev/packages/settings_ui)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web-lightgrey)](https://pub.dev/packages/settings_ui)

A Flutter package for building settings screens that look native on **Android**, **iOS**, and **Web** — all from a single API. The UI automatically adapts to each platform's visual style: Material for Android, Cupertino for iOS, and a card-based Web layout. Also runs on macOS, Windows, Linux, and Fuchsia (macOS/Windows use the Cupertino style; Linux uses Material).

<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/v2/settings_ui_cover.png" height="400px">
</p>

---

## Contents

- [Installing](#installing)
- [Quick start](#quick-start)
- [Tile types](#tile-types)
- [Platform styles](#platform-styles)
- [Theming](#theming)
- [Advanced usage](#advanced-usage)
- [API reference](#api-reference)

---

## Installing

Add to your `pubspec.yaml`:

```yaml
dependencies:
  settings_ui: ^3.0.0
```

Then import:

```dart
import 'package:settings_ui/settings_ui.dart';
```

---

## Quick start

```dart
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('General'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                value: const Text('English'),
                onPressed: (context) { /* navigate */ },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Appearance'),
            tiles: [
              SettingsTile.switchTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark mode'),
                initialValue: _darkMode,
                onToggle: (value) => setState(() => _darkMode = value),
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                description: const Text('Alerts, sounds, badges'),
                initialValue: _notificationsEnabled,
                onToggle: (value) =>
                    setState(() => _notificationsEnabled = value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## Tile types

### `SettingsTile` — basic tile

A tappable tile with optional leading icon, description, and trailing widget.

```dart
SettingsTile(
  leading: const Icon(Icons.storage),
  title: const Text('Storage'),
  description: const Text('30% used — 5.60 GB free'),
  onPressed: (context) { /* ... */ },
)
```

### `SettingsTile.navigation` — navigation tile

Adds a platform-appropriate trailing chevron. Right arrow in LTR, left arrow in RTL.

```dart
SettingsTile.navigation(
  leading: const Icon(Icons.language),
  title: const Text('Language'),
  value: const Text('English'),
  titleDescription: const Text('Choose your preferred language'),
  onPressed: (context) {
    Navigator.of(context).push(/* language screen */);
  },
)
```

### `SettingsTile.switchTile` — switch tile

Renders a `Switch` on Material platforms and a `CupertinoSwitch` on iOS/macOS.

```dart
SettingsTile.switchTile(
  leading: const Icon(Icons.fingerprint),
  title: const Text('Use biometrics'),
  description: const Text('Unlock with fingerprint or Face ID'),
  initialValue: _biometricsEnabled,
  onToggle: (value) => setState(() => _biometricsEnabled = value),
)
```

### `CustomSettingsTile` — any widget as a tile

```dart
CustomSettingsTile(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: LinearProgressIndicator(value: 0.3),
  ),
)
```

### `CustomSettingsSection` — any widget as a section

```dart
CustomSettingsSection(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      'Signed in as Danny Yako',
      style: Theme.of(context).textTheme.bodySmall,
    ),
  ),
)
```

---

## Platform styles

`SettingsList` detects the platform automatically. You can override it:

```dart
SettingsList(
  platform: DevicePlatform.iOS,  // force Cupertino style
  sections: [ /* ... */ ],
)
```

<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/v3/android_settings.png" width="30%">
  &nbsp;
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/v3/ios_cupertino.png" width="30%">
  &nbsp;
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/v3/web_chrome.png" width="30%">
</p>
<p align="center"><em>Android (Material) &nbsp;•&nbsp; iOS (Cupertino) &nbsp;•&nbsp; Web</em></p>

| `DevicePlatform` | Style |
|---|---|
| `device` *(default)* | Auto-detected at runtime |
| `android`, `fuchsia`, `linux` | Material |
| `iOS`, `macOS`, `windows` | Cupertino |
| `web` | Web (card layout) |

---

## Theming

### Material 3 (v3.0.0+)

On Android and Web, colors are automatically derived from your app's `ColorScheme`. No extra configuration needed — seed colors, light/dark mode, and custom `ColorScheme` all work out of the box.

<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/v3/android_material3.png" width="45%">
</p>

```dart
MaterialApp(
  theme: ThemeData(
    colorSchemeSeed: Colors.indigo,
    useMaterial3: true,
  ),
  home: const SettingsScreen(),
)
```

### Custom theme overrides

Any field left `null` falls back to the platform default derived from your `ColorScheme`.

```dart
SettingsList(
  lightTheme: const SettingsThemeData(
    settingsListBackground: Color(0xFFF2F2F7),
    settingsSectionBackground: Colors.white,
    titleTextColor: Colors.indigo,
  ),
  darkTheme: const SettingsThemeData(
    settingsListBackground: Color(0xFF1C1C1E),
    settingsSectionBackground: Color(0xFF2C2C2E),
    titleTextColor: Colors.indigoAccent,
  ),
  sections: [ /* ... */ ],
)
```

### Custom text styles

```dart
SettingsList(
  lightTheme: SettingsThemeData(
    tileTextStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 16),
    tileDescriptionTextStyle: const TextStyle(fontSize: 12),
    titleTextStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
      letterSpacing: 0.5,
    ),
  ),
  sections: [ /* ... */ ],
)
```

### Disabled tiles

```dart
SettingsTile.switchTile(
  title: const Text('Feature'),
  initialValue: false,
  onToggle: null,   // null disables interaction
  enabled: false,
)

// Control the disabled switch color:
SettingsList(
  lightTheme: const SettingsThemeData(
    inactiveSwitchColor: Colors.grey,
  ),
  sections: [ /* ... */ ],
)
```

---

## Advanced usage

### Scroll controller

```dart
final _controller = ScrollController();

SettingsList(
  scrollController: _controller,
  sections: [
    SettingsSection(
      tiles: [
        SettingsTile(
          title: const Text('Jump to bottom'),
          onPressed: (_) => _controller.animateTo(
            _controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        ),
      ],
    ),
  ],
)
```

### Compact tiles

```dart
SettingsTile(
  title: const Text('Option'),
  compact: true,  // halves the vertical padding
)
```

### Embedding inside another scroll view

```dart
SettingsList(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  sections: [ /* ... */ ],
)
```

### Wide screen alignment

On screens wider than 810 dp, the list auto-centers. To left-align:

```dart
SettingsList(
  crossAxisAlignment: CrossAxisAlignment.start,
  sections: [ /* ... */ ],
)
```

### CupertinoApp support

```dart
// Pure CupertinoApp:
SettingsList(
  applicationType: ApplicationType.cupertino,
  sections: [ /* ... */ ],
)

// MaterialApp on Android, CupertinoApp on iOS:
SettingsList(
  applicationType: ApplicationType.both,
  sections: [ /* ... */ ],
)
```

---

## API reference

### `SettingsList`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `sections` | `List<AbstractSettingsSection>` | required | Sections to display |
| `platform` | `DevicePlatform?` | `device` | Force a specific platform style |
| `lightTheme` | `SettingsThemeData?` | — | Overrides for light mode |
| `darkTheme` | `SettingsThemeData?` | — | Overrides for dark mode |
| `brightness` | `Brightness?` | — | Override brightness detection |
| `applicationType` | `ApplicationType` | `material` | `material`, `cupertino`, or `both` |
| `scrollController` | `ScrollController?` | — | Programmatic scroll control |
| `shrinkWrap` | `bool` | `false` | Shrink-wrap to content height |
| `physics` | `ScrollPhysics?` | — | Custom scroll physics |
| `contentPadding` | `EdgeInsetsGeometry?` | — | Override list padding |
| `crossAxisAlignment` | `CrossAxisAlignment` | `center` | Horizontal alignment on wide screens |

### `SettingsSection`

| Parameter | Type | Description |
|---|---|---|
| `tiles` | `List<AbstractSettingsTile>` | The tiles in this section |
| `title` | `Widget?` | Section header |
| `margin` | `EdgeInsetsDirectional?` | Override section margin |

### `SettingsTile`

| Parameter | Type | Applies to | Description |
|---|---|---|---|
| `title` | `Widget` | all | Tile label |
| `description` | `Widget?` | all | Secondary text below the title |
| `leading` | `Widget?` | all | Icon or widget at the start |
| `trailing` | `Widget?` | all | Widget at the end |
| `enabled` | `bool` | all | Grays out and disables interaction |
| `compact` | `bool` | all | Halves the vertical padding |
| `onPressed` | `Function(BuildContext)?` | all | Tap callback |
| `value` | `Widget?` | simple, navigation | Widget shown before the chevron |
| `titleDescription` | `Widget?` | navigation | Text below title (iOS/macOS/Windows) |
| `initialValue` | `bool?` | switchTile | Initial switch state |
| `onToggle` | `Function(bool)?` | switchTile | Toggle callback; `null` disables the switch |
| `activeSwitchColor` | `Color?` | switchTile | Active switch color override |

### `SettingsThemeData`

| Field | Type | Description |
|---|---|---|
| `settingsListBackground` | `Color?` | Background of the whole list |
| `settingsSectionBackground` | `Color?` | Background of each section card |
| `dividerColor` | `Color?` | Divider color between tiles |
| `tileHighlightColor` | `Color?` | Tile press highlight color |
| `titleTextColor` | `Color?` | Section header text color |
| `titleTextStyle` | `TextStyle?` | Section header text style |
| `settingsTileTextColor` | `Color?` | Tile title text color |
| `tileTextStyle` | `TextStyle?` | Tile title text style |
| `tileDescriptionTextColor` | `Color?` | Description/value text color |
| `tileDescriptionTextStyle` | `TextStyle?` | Description/value text style |
| `leadingIconsColor` | `Color?` | Leading icon color |
| `trailingTextColor` | `Color?` | Trailing text color |
| `inactiveTitleColor` | `Color?` | Tile title color when disabled |
| `inactiveSubtitleColor` | `Color?` | Description color when disabled |
| `inactiveSwitchColor` | `Color?` | Switch color when disabled |

---

## License

Apache License 2.0 — see the [LICENSE](LICENSE) file for details.
