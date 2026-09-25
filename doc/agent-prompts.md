# Prompts for coding agents

Copy-paste prompts for Claude Code, Codex, Cursor and other coding agents working on an app that uses [settings_ui](https://pub.dev/packages/settings_ui). Run them from the app's root folder. They point the agent at [`llms.txt`](https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/llms.txt), the package's API reference for agents.

## Build a store-ready settings screen

```text
Build a store-ready Settings screen for this Flutter app with the settings_ui package.
First read https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/llms.txt (API,
platform differences and mistakes to avoid). If you can't fetch it, read the package source after
`flutter pub get`.

1. Inspect the app before changing anything, and tell me what you found:
   - Flutter version and UI imports. package:material_ui / package:cupertino_ui -> settings_ui: ^4.0.0.
     package:flutter/material.dart -> settings_ui: ^3.0.1. Don't migrate the app unless I ask.
   - The platforms it ships (ios/, android/, macos/, windows/, linux/, web/), and tablet support.
   - State management, persistence (shared_preferences, Hive, secure storage...), localization,
     routing, and whether the app supports light/dark/system theme modes.
   - Existing preferences and feature flags, sign-up/sign-in, in-app purchases, permissions in
     ios/Runner/Info.plist and android/app/src/main/AndroidManifest.xml, and any existing settings UI.
2. Propose grouped sections that follow Apple HIG and Material conventions (for example: account,
   appearance, notifications, privacy, support, about; destructive actions last). For each row give
   the tile type, the state behind it and where it is stored. If the app runs on tablets, desktop or
   the web, propose SettingsSplitView (list and page side by side). Wait for my OK before adding
   dependencies, adding screens or moving existing code.
3. Build it with settings_ui, following the app's existing patterns:
   - SettingsTile.switchTile for on/off, SettingsTile.navigation for rows that open a page or
     picker, plain SettingsTile for values and actions (no chevron). Section titles in sentence case.
   - Settings sub-pages: `destination: SettingsDestination(id: ..., builder: ...)` on the navigation
     tile. The builder returns only the body; the package draws the header and back button.
   - Wire every row to real state that survives a restart. No placeholder rows, empty handlers or
     TODOs. Permission rows show the real OS status and open system settings when denied.
   - Use the app's localization for strings and its router for other screens. Leave `platform`
     unset, so iOS, Android, macOS, Windows, Linux and the web each get their own style.
4. Add these rows when they apply. Ask me for URLs and emails; never invent them.
   - Version and build number (package_info_plus). Open-source licenses (showLicensePage).
   - Privacy policy, terms of use and contact support (url_launcher).
   - Restore purchases, if the app sells subscriptions or non-consumable purchases.
   - Sign out and Delete account, if users can create accounts. Deletion starts in the app, asks for
     confirmation and calls the real backend (App Store Review Guideline 5.1.1(v); Google Play has a
     similar rule).
5. Add widget tests: the screen renders in the style of every platform the app ships
   (TargetPlatformVariant), every toggle persists, links and actions fire, and a split view shows
   one pane at 402x874 and two at 1210x834 (tester.view.physicalSize).
6. Run `flutter analyze` and `flutter test`. Then run the app on an iOS simulator and an Android
   emulator, plus iPad, desktop or web if the app ships there, in light and dark mode
   (`xcrun simctl ui booted appearance dark`, `adb shell cmd uimode night yes`), and screenshot
   the settings screen each time (`xcrun simctl io booted screenshot`,
   `adb exec-out screencap -p`). Fix anything clipped, misaligned or hard to read. If you can't
   launch a device, tell me what to run.
7. Summarize: files changed, dependencies added, each row with its state and storage key, tests
   added, screenshot paths, and anything I still need to provide.
```

## Upgrade settings_ui 3.x to 4.0 (move the app to material_ui / cupertino_ui)

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
   - In tests, look for CupertinoSettingsSwitch instead of CupertinoSwitch on iOS switch tiles,
     MacosSettingsSwitch on macOS, FluentSettingsSwitch on Windows and AdwaitaSettingsSwitch (not
     Switch) on Linux.
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

## Replace my hand-built settings screen with settings_ui

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

## Add one new setting end to end (UI, storage and test)

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

## Show my settings as a split view on tablets, foldables, desktop and the web

```text
Make my settings_ui screen show the list and the selected page side by side on iPad, Android
tablets and foldables, desktop and the web, and keep the phone layout as it is. Reference:
https://raw.githubusercontent.com/yako-dev/flutter-settings-ui/master/llms.txt (SettingsSplitView)

1. Find the settings screen and its sub-screens. List which rows open a sub-screen and how (routes,
   router, Navigator.push), and tell me before changing the app's routing.
2. Replace the screen with SettingsSplitView (same sections, `title: Text('Settings')`, no app bar
   above it). Give every row that opens a settings sub-screen a
   `destination: SettingsDestination(id: ..., builder: ...)`, where the builder returns the
   sub-screen's body without its Scaffold and app bar. Keep rows that open pickers, dialogs or
   other parts of the app as they are.
3. If the app has URLs for settings pages, keep them in sync with `onDestinationChanged` and open
   deep links with a SettingsSplitController (`controller.select(id)`).
4. Tests: one pane on a phone size, two panes on an iPad size (tester.view.physicalSize), a tap
   shows the page, back returns to the list on a phone. Run `flutter analyze` and `flutter test`.
5. Run it on an iPad simulator and an Android tablet or foldable emulator, in both orientations,
   on the web at 1280px, and on each desktop platform the app ships (macOS, Windows and Linux
   get their Settings apps' sidebars), and attach screenshots.
```

## Audit my settings screen against iOS and Android conventions

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
  correctly; no hardcoded colors; no tile relies on text that one platform hides (see llms.txt);
  on tablets, desktop and the web, a SettingsSplitView rather than a stretched phone list.
- Accessibility and localization: all strings localized, the largest text size doesn't clip,
  right-to-left works, icon-only controls have semantics labels.
- Tests: does anything cover this screen?
Run the app on iOS and Android, in light and dark mode and at the largest text size, and attach
screenshots. End with a prioritized list: blocks store review / should fix / nice to have.
```
