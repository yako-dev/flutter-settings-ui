# settings_ui example

A gallery of [settings_ui](https://pub.dev/packages/settings_ui) screens:

- an abstract settings screen whose style you can switch, and a Material 3
  theme demo;
- a split view demo with the settings trees of iPad Settings, Android
  Settings, Chrome, macOS System Settings, Windows Settings and GNOME Settings;
- a showcase: the settings of a made-up app, built once and shown in every
  style;
- replicas of iOS, Android, Chrome, macOS, Windows and GNOME settings pages.

```bash
cd example
flutter run                  # iOS, Android, macOS, Windows, Linux or web
flutter run -d chrome        # then open /?screen=showcase&platform=macOS&theme=dark
```

`flutter test integration_test -d <device>` drives the gallery on a device,
simulator, emulator or desktop.

## Opening a screen directly

Screenshot scripts can skip the gallery, pick a style and force light or dark
mode with five options (see `lib/utils/launch_options.dart`): `screen`,
`platform`, `page`, `tab` and `theme`. Each is read from the first of these
that sets it:

- The web page's query: `/?screen=split-view&platform=macOS&theme=dark`
- The initial route, whose path is the screen:
  `flutter run --route '/split-view?platform=windows&page=system'`, or
  `/#/split-view?platform=windows` on the web
- `--dart-define`s: `flutter run --dart-define=SCREEN=macos --dart-define=THEME=dark`
  (and `PLATFORM`, `PAGE`, `TAB`)

`screen` is one of the keys of `launchScreens` in `lib/main.dart`:
`split-view`, `showcase`, `macos`, `gnome-power`, `windows-display`,
`ios-developer`, `ios-native`, `android-settings`, `android-native`,
`android-notifications`, `web-chrome`, `web-chrome-addresses`, `material3`
or `cross-platform`. `platform` is a `DevicePlatform` name in any case
(`ios`, `macOS`, `linux`...) and sets the style of the gallery, the
cross-platform screen, the split view and the showcase. `page` is the split
view or showcase page to open, by its top-level id (e.g. `display`,
`displays` in the macOS tree, or `privacy` in the showcase), and `tab` the
tab of the GNOME Power replica (`power-saving`). `theme` is `light` or
`dark`; without it the app follows the system.
