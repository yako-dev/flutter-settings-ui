# Settings UI for Flutter

[![Pub Version](https://img.shields.io/pub/v/settings_ui?color=blueviolet)](https://pub.dev/packages/settings_ui)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20macos%20%7C%20windows%20%7C%20linux%20%7C%20web-lightgrey)](https://pub.dev/packages/settings_ui)

A Flutter package for building settings screens that look native on **iOS**, **Android** and the **web**, from a single API. The style is picked at runtime: iOS 26-style grouped cards on iOS, macOS and Windows, Android 16-style cards on Android, Linux and Fuchsia, and Chrome-style cards on the web.

<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/v2/settings_ui_cover.png" height="560px">
</p>

---

## Build it with an AI agent

A coding agent such as Claude Code, Codex or Cursor can build your settings screen with this package. Paste the prompt below into the agent from your app's root folder. It looks at your app first, asks before big changes, and connects every row to real, saved state.

```text
Build a store-ready Settings screen for this Flutter app with the settings_ui package.
First read https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/llms.txt (API,
platform differences and mistakes to avoid). If you can't fetch it, read the package source after
`flutter pub get`.

1. Inspect the app before changing anything, and tell me what you found:
   - Flutter version and UI imports. package:material_ui / package:cupertino_ui -> settings_ui: ^4.0.0.
     package:flutter/material.dart -> settings_ui: ^3.0.1. Don't migrate the app unless I ask.
   - State management, persistence (shared_preferences, Hive, secure storage...), localization,
     routing, and whether the app supports light/dark/system theme modes.
   - Existing preferences and feature flags, sign-up/sign-in, in-app purchases, permissions in
     ios/Runner/Info.plist and android/app/src/main/AndroidManifest.xml, and any existing settings UI.
2. Propose grouped sections that follow Apple HIG and Material conventions (for example: account,
   appearance, notifications, privacy, support, about; destructive actions last). For each row give
   the tile type, the state behind it and where it is stored. Wait for my OK before adding
   dependencies, adding screens or moving existing code.
3. Build it with settings_ui, following the app's existing patterns:
   - SettingsTile.switchTile for on/off, SettingsTile.navigation for rows that open a screen or
     picker, plain SettingsTile for values and actions (no chevron). Section titles in sentence case.
   - Wire every row to real state that survives a restart. No placeholder rows, empty handlers or
     TODOs. Permission rows show the real OS status and open system settings when denied.
   - Use the app's localization for strings and its router for sub-screens. Leave `platform` unset.
4. Add these rows when they apply. Ask me for URLs and emails; never invent them.
   - Version and build number (package_info_plus). Open-source licenses (showLicensePage).
   - Privacy policy, terms of use and contact support (url_launcher).
   - Restore purchases, if the app sells subscriptions or non-consumable purchases.
   - Sign out and Delete account, if users can create accounts. Deletion starts in the app, asks for
     confirmation and calls the real backend (App Store Review Guideline 5.1.1(v); Google Play has a
     similar rule).
5. Add widget tests: the screen renders in iOS and Android style (TargetPlatformVariant), every
   toggle persists, and links and actions fire.
6. Run `flutter analyze` and `flutter test`. Then run the app on an iOS simulator and an Android
   emulator, in light and dark mode (`xcrun simctl ui booted appearance dark`,
   `adb shell cmd uimode night yes`), and screenshot the settings screen each time
   (`xcrun simctl io booted screenshot`, `adb exec-out screencap -p`). Fix anything clipped,
   misaligned or hard to read. If you can't launch a device, tell me what to run.
7. Summarize: files changed, dependencies added, each row with its state and storage key, tests
   added, screenshot paths, and anything I still need to provide.
```

### Smaller tasks

<details>
<summary>Upgrade settings_ui 3.x to 4.0 (move the app to material_ui / cupertino_ui)</summary>

```text
Upgrade this Flutter app from settings_ui 3.x to 4.0.0. Reference:
https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/llms.txt

1. Check `flutter --version`. 4.0.0 needs Flutter 3.44+ and Dart 3.12+. If the app can't move to
   that, stop and tell me: staying on settings_ui ^3.0.1 is fine.
2. Move the app off package:flutter/material.dart and package:flutter/cupertino.dart:
   - Run the import migration from the material_ui README
     (`dart fix --apply --code=migrate_design_widgets`). If your SDK doesn't have it, change the
     imports by hand. Cover lib/, test/ and integration_test/.
   - Add material_ui and cupertino_ui to pubspec.yaml if the fix didn't.
   - If the app uses GlobalMaterialLocalizations or GlobalCupertinoLocalizations from
     flutter_localizations, switch to the versions in material_ui and cupertino_ui.
   - List dependencies that still import package:flutter/material.dart. Wrap only their widgets in
     MaterialUiCompatibilityBridge or CupertinoUiCompatibilityBridge, and tell me which ones.
3. Set `settings_ui: ^4.0.0` and run `flutter pub get`. The settings_ui API didn't change, so don't
   rewrite settings screens. Only:
   - In tests, look for CupertinoSettingsSwitch instead of CupertinoSwitch on iOS-style switch tiles.
   - Change ALL-CAPS section titles to sentence case; the iOS style now uses iOS 26 headers.
   - Remove 3.x workarounds that 4.0 makes unnecessary, such as a `trailing: Text(...)` added
     because iOS simple tiles didn't show `value`.
4. Verify: `flutter analyze` and `flutter test` pass. Run the app in debug and confirm the log never
   prints "settings_ui: SettingsList found no Theme". If it does, that screen still sits under a
   flutter/material app or theme. Screenshot every settings screen on iOS and Android, in light
   and dark mode, and check that colors and dark mode follow the app theme and that custom
   margins, paddings and SettingsThemeData overrides still look right with the new sizes.
5. Summarize: SDK constraint changes, files touched, bridged dependencies, and any visual
   differences from before.
```

</details>

<details>
<summary>Replace my hand-built settings screen with settings_ui</summary>

```text
Replace my hand-built settings screen with settings_ui. Reference:
https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/llms.txt

1. Find the current settings screen(s). List every row: label, control, the state it reads and
   writes, its storage key, and side effects (navigation, dialogs, permission prompts, analytics).
2. Pick the version from the app's imports: package:material_ui / package:cupertino_ui -> ^4.0.0,
   package:flutter/material.dart -> ^3.0.1.
3. Map each row: on/off -> SettingsTile.switchTile; opens a screen or picker ->
   SettingsTile.navigation with the current choice as `value`; shows a value or runs an action ->
   SettingsTile; anything else -> CustomSettingsTile. Group rows into SettingsSections.
   Show me the mapping before editing.
4. Rebuild the screen with SettingsList. Keep the same state, storage keys, callbacks, routes and
   strings: no saved value may be lost and nothing may stop working. Keep the app bar.
5. Delete old widgets and helpers that nothing uses anymore.
6. Make sure tests still cover every original row, updating finders for the new widgets. Run
   `flutter analyze` and `flutter test`.
7. Screenshot old and new on iOS and Android, in light and dark mode. List every visible or
   behavioral difference, and anything you couldn't map.
```

</details>

<details>
<summary>Add one new setting end to end (UI, storage and test)</summary>

```text
Add this setting to my settings_ui screen, end to end:
[NAME, TYPE AND DEFAULT, e.g. "Autoplay videos: on/off, default on"]
Reference: https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/llms.txt

1. Find the settings screen, how existing settings are stored and read (state management and
   persistence), and how strings are localized. Follow those patterns exactly.
2. Choose the tile: on/off -> SettingsTile.switchTile; one of several options ->
   SettingsTile.navigation that shows the current choice as `value` and opens a picker;
   read-only value or action -> SettingsTile. Put it in the section where users would look.
3. Add the storage key with its default, the state that exposes it, and the row. Changing it must
   update the UI right away and survive an app restart.
4. Make the app honor the setting wherever it applies, and tell me where you wired it.
5. Add the strings for every language the app ships.
6. Tests: the default value, a change persists, the behavior it controls changes, and the row
   renders in iOS and Android style (TargetPlatformVariant). Run `flutter analyze` and
   `flutter test`.
7. Summarize: files changed, storage key and default, and where the setting is read.
```

</details>

<details>
<summary>Audit my settings screen against iOS and Android conventions</summary>

```text
Audit my settings screen(s) against Apple HIG and Material Design conventions. Report only; don't
change code until I pick what to fix. Reference:
https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/llms.txt

For each finding give file:line, why it matters, and a fix. Check:
- Tile types: chevrons (SettingsTile.navigation) only on rows that open another screen; values and
  actions use SettingsTile; on/off uses switchTile; no switch that runs a one-off action.
- Dead rows: no handler, a handler that does nothing, toggles that don't persist or don't change
  the app, hardcoded values.
- Structure: related rows grouped, short section titles in sentence case, destructive rows (sign
  out, delete account) last, in red, behind a confirmation.
- Store basics: version and build, open-source licenses, privacy policy, terms, support contact,
  restore purchases (if the app has in-app purchases), in-app account deletion if users can
  create accounts (App Store Review Guideline 5.1.1(v)). Check that every link opens.
- Permissions: rows show the real OS status and link to system settings when denied.
- Platform fit: `platform` left on auto-detect unless intended; the settings_ui version matches
  the app's imports (4.x needs material_ui / cupertino_ui, otherwise ^3.0.1); dark mode renders
  correctly; no hardcoded colors; no tile relies on text that one platform hides (see llms.txt).
- Accessibility and localization: all strings localized, the largest text size doesn't clip,
  right-to-left works, icon-only controls have semantics labels.
- Tests: does anything cover this screen?
Run the app on iOS and Android, in light and dark mode and at the largest text size, and attach
screenshots. End with a prioritized list: blocks store review / should fix / nice to have.
```

</details>

Agents (and people) can read [`llms.txt`](https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/llms.txt): a short API reference with the platform differences and the mistakes to avoid.

---

## Contents

- [Build it with an AI agent](#build-it-with-an-ai-agent)
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
  settings_ui: ^4.0.0
```

Then import:

```dart
import 'package:settings_ui/settings_ui.dart';
```

### Requirements

Version 4 needs **Flutter 3.44+** (Dart 3.12+) and an app built on the
[`material_ui`](https://pub.dev/packages/material_ui) and
[`cupertino_ui`](https://pub.dev/packages/cupertino_ui) packages:

```dart
import 'package:material_ui/material_ui.dart'; // not package:flutter/material.dart
import 'package:cupertino_ui/cupertino_ui.dart'; // not package:flutter/cupertino.dart
```

settings_ui depends on both packages, but if your code imports them, add them to your own
`pubspec.yaml` as well (`flutter pub add material_ui cupertino_ui`), or the
`depend_on_referenced_packages` lint fails.

`SettingsList` reads colors, dark mode and platform from the `Theme` and
`CupertinoTheme` of those packages. In an app still built on
`package:flutter/material.dart` it can't see your theme, so it falls back to
default colors and light mode (a debug build prints a warning). If your app
hasn't switched yet, stay on version 3:

```yaml
dependencies:
  settings_ui: ^3.0.1
```

---

## Quick start

```dart
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

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

Section titles are plain widgets. Write them in sentence case ("Appearance"), as iOS 26 and Android 16 do.

---

## Tile types

### `SettingsTile`: basic tile

A tappable tile with an optional leading icon, value, description and trailing widget. It never shows a chevron, so use it to show a value or run an action (version number, sign out).

```dart
SettingsTile(
  leading: const Icon(Icons.storage),
  title: const Text('Storage'),
  value: const Text('5.60 GB free'),
  onPressed: (context) { /* ... */ },
)
```

### `SettingsTile.navigation`: navigation tile

For rows that open another screen or a picker. In the iOS and web styles it adds a chevron after the value (it points left in right-to-left layouts). The Android style shows no chevron, like Android's own settings.

```dart
SettingsTile.navigation(
  leading: const Icon(Icons.language),
  title: const Text('Language'),
  value: const Text('English'),
  onPressed: (context) {
    Navigator.of(context).push(/* language screen */);
  },
)
```

### `SettingsTile.switchTile`: switch tile

In the iOS style it shows `CupertinoSettingsSwitch`, the iOS 26 switch. In the Android style it shows a Material `Switch` with a check or a cross on the thumb, and on the web a Material `Switch`.

```dart
SettingsTile.switchTile(
  leading: const Icon(Icons.fingerprint),
  title: const Text('Use biometrics'),
  description: const Text('Unlock with fingerprint or Face ID'),
  initialValue: _biometricsEnabled,
  onToggle: (value) => setState(() => _biometricsEnabled = value),
)
```

The tile is controlled: `initialValue` is the current value, and `onToggle` gets the new one. Passing `onToggle: null` disables the switch.

Tapping the row works like each platform's settings app. In the Android and web styles, tapping anywhere on the row toggles the switch, and `onPressed` isn't called. In the iOS style only the switch itself toggles; tapping the rest of the row calls `onPressed`, if you set one.

### `value`, `description` and `titleDescription`

The same tile shows its secondary text in different places, following each platform:

| Parameter | iOS style | Android and web styles |
|---|---|---|
| `value` | Grey text at the end of the row, one line, at most half the row | Second line under the title |
| `description` | Footer text under the card; the tiles after it start a new card | Second line under the title, only when `value` is not set |
| `titleDescription` | Second line inside the row, under the title | Not shown |

So on Android and the web, a tile with both `value` and `description` shows only `value`. `value` exists on `SettingsTile` and `SettingsTile.navigation`; `description` and `titleDescription` exist on all three constructors.

### `CustomSettingsTile`: any widget as a tile

```dart
CustomSettingsTile(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: LinearProgressIndicator(value: 0.3),
  ),
)
```

### `CustomSettingsSection`: any widget as a section

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

Inside a `SettingsList`, `SettingsTheme.of(context)` gives custom tiles and sections the resolved colors (`themeData`) and style (`platform`).

---

## Platform styles

`SettingsList` detects the platform automatically. You can override it:

```dart
SettingsList(
  platform: DevicePlatform.iOS,  // use the iOS style everywhere
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
<p align="center"><em>Android &nbsp;•&nbsp; iOS &nbsp;•&nbsp; Web</em></p>

| `DevicePlatform` | Style |
|---|---|
| `device` *(default)* | Auto-detected at runtime |
| `iOS`, `macOS`, `windows` | iOS |
| `android`, `fuchsia`, `linux` | Android |
| `web` | Web |

- **iOS** matches iOS 26 Settings: cards with 26pt continuous corners and 20pt side margins, 52pt rows with 17pt text, 17pt semibold section headers, grey footers, the `CupertinoSettingsSwitch`, and a chevron on navigation tiles.
- **Android** matches Android 16 Settings: every tile sits on its own card, 2dp apart, with 20dp corners at the ends of a group, on a tinted page. 16sp titles and switches with a check or a cross.
- **Web** matches Chrome's settings page: cards with 8px corners and a light shadow, 14px titles, 13px descriptions, a chevron on navigation tiles, and a 680px column on wide windows.

In a browser, the web style is used on every device, phones included. Elsewhere the style follows `Theme.of(context).platform`, so `ThemeData(platform: ...)` changes it too. Platforms that only exist in forks of Flutter, such as OpenHarmony, get the iOS style.

---

## Theming

### Colors

The Android and web styles derive their colors from your app's Material 3 `ColorScheme`. Seed colors, light and dark mode, and custom color schemes work without extra setup.

<p align="center">
  <img src="https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/assets/v3/android_material3.png" width="45%">
</p>

```dart
MaterialApp(
  theme: ThemeData(colorSchemeSeed: Colors.indigo),
  home: const SettingsScreen(),
)
```

The iOS style uses fixed iOS system colors, like the Settings app: a grey grouped background, white cards (`#1C1C1E` in dark mode) and grey headers and values. It doesn't read your `ColorScheme`. Light or dark mode follows your app theme in every style.

### Custom theme overrides

Pass a `SettingsThemeData` for light mode, dark mode or both. Any field left `null` keeps the style's default.

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

See [`SettingsThemeData`](#settingsthemedata) for what each field changes.

### Custom text styles

```dart
SettingsList(
  lightTheme: const SettingsThemeData(
    tileTextStyle: TextStyle(fontFamily: 'Roboto', fontSize: 16),
    tileDescriptionTextStyle: TextStyle(fontSize: 12),
    titleTextStyle: TextStyle(
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
  onToggle: null,   // null disables the switch
  enabled: false,   // greys out the row and ignores taps
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

### Dark mode and `CupertinoApp`

By default, light or dark mode comes from the Material `Theme`. In a `CupertinoApp`, tell the list to read the `CupertinoTheme` instead:

```dart
// Pure CupertinoApp:
SettingsList(
  applicationType: ApplicationType.cupertino,
  sections: [ /* ... */ ],
)

// MaterialApp on Android, CupertinoApp on iOS: reads the CupertinoTheme when
// the app runs on iOS or macOS, the Material Theme elsewhere.
SettingsList(
  applicationType: ApplicationType.both,
  sections: [ /* ... */ ],
)
```

To force one mode whatever the app theme says, set `brightness`:

```dart
SettingsList(
  brightness: Brightness.dark,
  sections: [ /* ... */ ],
)
```

### Wide screens and split views

When the list is wider than 810 (680 on the web), the tiles sit in a centered column of that width. The width is the list's own, not the screen's, so a list in a split view or side panel is laid out for that pane. To put the column at the start edge (left, or right in right-to-left layouts) instead of centering it:

```dart
SettingsList(
  crossAxisAlignment: CrossAxisAlignment.start,
  sections: [ /* ... */ ],
)
```

Setting `contentPadding` replaces the default padding altogether, and `crossAxisAlignment` then has no effect.

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

### The iOS 26 switch on its own

`CupertinoSettingsSwitch` is the switch the iOS style uses. It is drawn entirely in Flutter: a 63x28 track with a pill-shaped thumb that turns into a Liquid Glass-style lens while you press or drag it. You can use it anywhere:

```dart
CupertinoSettingsSwitch(
  value: _wifi,
  onChanged: (value) => setState(() => _wifi = value),
)
```

The lens paints a little outside the switch (about 12.5pt past each end and 6pt above and below), so don't clip it tightly.

---

## API reference

### `SettingsList`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `sections` | `List<AbstractSettingsSection>` | required | Sections to display |
| `platform` | `DevicePlatform?` | `device` | Force a specific platform style |
| `applicationType` | `ApplicationType` | `material` | Where dark mode comes from: `material`, `cupertino` or `both` (Cupertino theme on iOS and macOS, Material elsewhere) |
| `brightness` | `Brightness?` | — | Force light or dark instead of following the app theme |
| `lightTheme` | `SettingsThemeData?` | — | Overrides for light mode |
| `darkTheme` | `SettingsThemeData?` | — | Overrides for dark mode |
| `contentPadding` | `EdgeInsetsGeometry?` | — | Replaces the default list padding |
| `crossAxisAlignment` | `CrossAxisAlignment` | `center` | Where the content column sits on wide lists; `start` for the start edge |
| `scrollController` | `ScrollController?` | — | Programmatic scroll control |
| `shrinkWrap` | `bool` | `false` | Shrink-wrap to content height |
| `physics` | `ScrollPhysics?` | — | Custom scroll physics |

### `SettingsSection`

| Parameter | Type | Description |
|---|---|---|
| `tiles` | `List<AbstractSettingsTile>` | The tiles in this section. A section with no tiles renders nothing |
| `title` | `Widget?` | Section header |
| `titlePadding` | `EdgeInsetsGeometry?` | Padding around the header |
| `margin` | `EdgeInsetsDirectional?` | Override section margin |

### `SettingsTile`

None of the constructors is `const`.

| Parameter | Type | Constructors | Description |
|---|---|---|---|
| `title` | `Widget` | all | Tile label (required) |
| `leading` | `Widget?` | all | Icon or widget at the start |
| `trailing` | `Widget?` | all | Widget at the end |
| `value` | `Widget?` | default, navigation | Current value; see [where it shows](#value-description-and-titledescription) |
| `description` | `Widget?` | all | Secondary text; see [where it shows](#value-description-and-titledescription) |
| `titleDescription` | `Widget?` | all | Line under the title, iOS style only |
| `onPressed` | `Function(BuildContext)?` | all | Tap callback |
| `enabled` | `bool` | all | `false` greys out the tile and ignores taps. Default `true` |
| `compact` | `bool` | all | Halves the vertical padding. Default `false` |
| `initialValue` | `bool?` | switchTile | Current switch state (required) |
| `onToggle` | `Function(bool)?` | switchTile | Toggle callback (required); `null` disables the switch |
| `activeSwitchColor` | `Color?` | switchTile | Switch color when on |
| `leadingPadding` | `EdgeInsetsGeometry?` | all | Padding around `leading` |
| `titlePadding` | `EdgeInsetsGeometry?` | all | Padding around `title` |
| `titleDescriptionPadding` | `EdgeInsetsGeometry?` | all | Padding around `titleDescription` (iOS style) |
| `trailingPadding` | `EdgeInsetsGeometry?` | all | Padding around `trailing` (Android and web styles: not on switch tiles) |
| `descriptionPadding` | `EdgeInsetsGeometry?` | all | Padding around `description` |

### `CupertinoSettingsSwitch`

| Parameter | Type | Description |
|---|---|---|
| `value` | `bool` | Whether the switch is on (required) |
| `onChanged` | `ValueChanged<bool>?` | Called with the new value (required); `null` disables the switch |
| `activeTrackColor` | `Color?` | Track color when on. Default: iOS system green |
| `inactiveTrackColor` | `Color?` | Track color when off. Default: `#C5C5C7` light, `#5A5A5E` dark |

### `SettingsThemeData`

| Field | Type | Description |
|---|---|---|
| `settingsListBackground` | `Color?` | Background of the whole list |
| `settingsSectionBackground` | `Color?` | Background of the cards |
| `dividerColor` | `Color?` | Line between tiles (iOS and web styles) |
| `tileHighlightColor` | `Color?` | Tile press highlight color |
| `titleTextColor` | `Color?` | Section header text color. In the iOS style also `titleDescription` and `description` |
| `titleTextStyle` | `TextStyle?` | Section header text style |
| `settingsTileTextColor` | `Color?` | Tile title text color |
| `tileTextStyle` | `TextStyle?` | Tile title text style |
| `tileDescriptionTextColor` | `Color?` | `description` and `value` text color (Android and web styles) |
| `tileDescriptionTextStyle` | `TextStyle?` | `description` text style, and `value` in the Android and web styles |
| `trailingTextColor` | `Color?` | `value` text color (iOS style) |
| `leadingIconsColor` | `Color?` | Leading and trailing icons, and the chevron |
| `inactiveTitleColor` | `Color?` | Title and icon color of a disabled tile |
| `inactiveSubtitleColor` | `Color?` | `description` and `value` color of a disabled tile (Android and web styles) |
| `inactiveSwitchColor` | `Color?` | Switch color of a disabled tile |

---

## License

Apache License 2.0. See the [LICENSE](LICENSE) file for details.
