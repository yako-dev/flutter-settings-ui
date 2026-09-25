# example

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Opening a screen directly

Screenshot scripts can skip the gallery, pick a style and force light or dark
mode with four options (see `lib/utils/launch_options.dart`): `screen`,
`platform`, `page` and `theme`. Each is read from the first of these that sets
it:

- The web page's query: `/?screen=split-view&platform=macOS&theme=dark`
- The initial route, whose path is the screen:
  `flutter run --route '/split-view?platform=windows&page=display'`, or
  `/#/split-view?platform=windows` on the web
- `--dart-define`s: `flutter run --dart-define=SCREEN=macos --dart-define=THEME=dark`
  (and `PLATFORM`, `PAGE`)

`screen` is one of the keys of `launchScreens` in `lib/main.dart`:
`split-view`, `showcase`, `macos`, `gnome-power`, `windows-display`,
`ios-developer`, `ios-native`, `android-settings`, `android-native`,
`android-notifications`, `web-chrome`, `web-chrome-addresses`, `material3`
or `cross-platform`. `platform` is a `DevicePlatform` name in any case
(`ios`, `macOS`, `linux`...) and sets the style of the gallery, the
cross-platform screen, the split view and the showcase. `page` is the split
view or showcase page to open (e.g. `display`, or `privacy` in the
showcase). `theme` is `light` or `dark`; without it the app follows the
system.
