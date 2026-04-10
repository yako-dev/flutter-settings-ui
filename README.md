# Settings UI for Flutter

[![Pub Version](https://img.shields.io/pub/v/settings_ui?color=blueviolet)](https://pub.dev/packages/settings_ui)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20windows%20%7C%20linux-lightgrey)](https://pub.dev/packages/settings_ui)

A Flutter package for building native-looking settings screens across **Android, iOS, Web, macOS, Windows, and Linux** from a single API. The UI automatically adapts to each platform's visual style — Material for Android/Web/Linux, Cupertino for iOS/macOS/Windows.

<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/v2/android/mockup_01.png" height="540px">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/v2/iOS/mockup_01.png" height="540px">
</p>

---

## Contents

- [Installing](#installing)
- [Quick start](#quick-start)
- [Tile types](#tile-types)
- [Platform rendering](#platform-rendering)
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
                onPressed: (context) {
                  // navigate to language picker
                },
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

A simple tappable tile with optional leading icon, description, and trailing widget.

```dart
SettingsTile(
  leading: const Icon(Icons.storage),
  title: const Text('Storage'),
  description: const Text('30% used — 5.60 GB free'),
  trailing: const Icon(Icons.chevron_right),
  onPressed: (context) { /* ... */ },
)
```

### `SettingsTile.navigation` — navigation tile

Adds a platform-appropriate trailing chevron (right arrow on LTR, left arrow on RTL). Use this for tiles that push a new screen.

```dart
SettingsTile.navigation(
  leading: const Icon(Icons.language),
  title: const Text('Language'),
  value: const Text('English'),     // shown next to the chevron
  titleDescription: const Text('Choose your preferred language'),
  onPressed: (context) {
    Navigator.of(context).push(/* language screen */);
  },
)
```

### `SettingsTile.switchTile` — switch tile

A tile with a `Switch` (Material) or `CupertinoSwitch` (Cupertino) depending on the active platform.

```dart
SettingsTile.switchTile(
  leading: const Icon(Icons.fingerprint),
  title: const Text('Use biometrics'),
  description: const Text('Unlock with fingerprint or Face ID'),
  initialValue: _biometricsEnabled,
  onToggle: (value) => setState(() => _biometricsEnabled = value),
)
```

### `CustomSettingsTile` — fully custom tile

Place any widget inside a section as if it were a tile.

```dart
CustomSettingsTile(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: LinearProgressIndicator(value: 0.3),
  ),
)
```

### `CustomSettingsSection` — fully custom section

Place any widget as an entire section, outside the standard section chrome.

```dart
CustomSettingsSection(
  child: Column(
    children: [
      const SizedBox(height: 16),
      CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
      const SizedBox(height: 8),
      const Text('Danny Yako', style: TextStyle(fontSize: 18)),
      const SizedBox(height: 16),
    ],
  ),
)
```

---

## Platform rendering

By default `SettingsList` detects the running platform automatically (`DevicePlatform.device`). You can override it to force a specific style:

```dart
SettingsList(
  platform: DevicePlatform.iOS,   // always render iOS style
  sections: [ /* ... */ ],
)
```

| `DevicePlatform` value | Style used |
|---|---|
| `device` *(default)* | Auto-detected at runtime |
| `android`, `fuchsia`, `linux` | Material |
| `iOS`, `macOS`, `windows` | Cupertino |
| `web` | Web (Material with card layout) |

---

## Theming

### Material 3 (v3.0.0+)

On Android and Web, colors are automatically derived from your app's `ColorScheme`. No configuration needed — if you use `ThemeData(colorSchemeSeed: ...)` or a custom `ColorScheme`, the settings list will match.

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

Pass a `SettingsThemeData` to `lightTheme` and/or `darkTheme` on `SettingsList` to override individual colors. Any field you leave `null` falls back to the platform default.

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

### Custom fonts and text styles

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

### Disabled state colors

```dart
SettingsTile.switchTile(
  title: const Text('Feature'),
  initialValue: false,
  onToggle: null,          // passing null disables the tile
  enabled: false,
)
```

To control the color of the switch when disabled:

```dart
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

Pass a `ScrollController` to programmatically scroll the list:

```dart
final _controller = ScrollController();

SettingsList(
  scrollController: _controller,
  sections: [
    SettingsSection(
      tiles: [
        SettingsTile.navigation(
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

Reduce tile height with `compact: true` for dense layouts:

```dart
SettingsTile(
  title: const Text('Option'),
  compact: true,
)
```

### Embedding inside a scroll view

When placing `SettingsList` inside another scrollable widget (e.g. a `ListView` or `CustomScrollView`), set `shrinkWrap: true` and provide non-scrolling physics:

```dart
SettingsList(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  sections: [ /* ... */ ],
)
```

### Wide screen / web alignment

On screens wider than 810 dp the list automatically adds horizontal padding to keep content centered. To left-align instead:

```dart
SettingsList(
  crossAxisAlignment: CrossAxisAlignment.start,
  sections: [ /* ... */ ],
)
```

### CupertinoApp support

If your app uses `CupertinoApp` instead of `MaterialApp`, set `applicationType` accordingly so brightness is read from the correct theme:

```dart
SettingsList(
  applicationType: ApplicationType.cupertino,
  sections: [ /* ... */ ],
)
```

For apps that use `MaterialApp` on Android and `CupertinoApp` on iOS:

```dart
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
| `sections` | `List<AbstractSettingsSection>` | required | The list of sections to display |
| `platform` | `DevicePlatform?` | `device` | Force a specific platform style |
| `lightTheme` | `SettingsThemeData?` | — | Color/style overrides for light mode |
| `darkTheme` | `SettingsThemeData?` | — | Color/style overrides for dark mode |
| `brightness` | `Brightness?` | — | Override brightness detection |
| `applicationType` | `ApplicationType` | `material` | `material`, `cupertino`, or `both` |
| `scrollController` | `ScrollController?` | — | Control scrolling programmatically |
| `shrinkWrap` | `bool` | `false` | Shrink-wrap the list to its content height |
| `physics` | `ScrollPhysics?` | — | Custom scroll physics |
| `contentPadding` | `EdgeInsetsGeometry?` | — | Override default list padding |
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
| `leading` | `Widget?` | all | Icon or widget at the start of the tile |
| `trailing` | `Widget?` | all | Widget at the end of the tile |
| `enabled` | `bool` | all | Grays out the tile and disables interaction |
| `compact` | `bool` | all | Halves the vertical padding |
| `onPressed` | `Function(BuildContext)?` | all | Tap callback |
| `value` | `Widget?` | simple, navigation | Secondary widget shown before the chevron |
| `titleDescription` | `Widget?` | navigation | Text shown below the title (iOS/macOS/Windows only) |
| `initialValue` | `bool?` | switchTile | Initial switch state |
| `onToggle` | `Function(bool)?` | switchTile | Called when the switch changes; `null` disables it |
| `activeSwitchColor` | `Color?` | switchTile | Active switch color override |

### `SettingsThemeData`

| Field | Type | Description |
|---|---|---|
| `settingsListBackground` | `Color?` | Background color of the whole list |
| `settingsSectionBackground` | `Color?` | Background color of each section card |
| `dividerColor` | `Color?` | Color of the dividers between tiles |
| `tileHighlightColor` | `Color?` | Tile press/highlight color |
| `titleTextColor` | `Color?` | Section header text color |
| `titleTextStyle` | `TextStyle?` | Section header text style |
| `settingsTileTextColor` | `Color?` | Tile title text color |
| `tileTextStyle` | `TextStyle?` | Tile title text style |
| `tileDescriptionTextColor` | `Color?` | Tile description/value text color |
| `tileDescriptionTextStyle` | `TextStyle?` | Tile description/value text style |
| `leadingIconsColor` | `Color?` | Color applied to leading icon widgets |
| `trailingTextColor` | `Color?` | Color of trailing text |
| `inactiveTitleColor` | `Color?` | Tile title color when `enabled: false` |
| `inactiveSubtitleColor` | `Color?` | Description color when `enabled: false` |
| `inactiveSwitchColor` | `Color?` | Switch color when `enabled: false` |

---

## License

Apache License 2.0 — see the [LICENSE](LICENSE) file for details.
