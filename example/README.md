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
mode (see `lib/utils/launch_options.dart`):

- Web: `?screen=macos&theme=dark`, `?platform=linux`
- Other platforms: `flutter run --dart-define=SCREEN=macos --dart-define=THEME=dark`
  (and `--dart-define=PLATFORM=linux`)

`screen` is one of the keys of `launchScreens` in `lib/main.dart`: `macos`,
`gnome-power`, `windows-display`, `ios-developer`, `ios-native`,
`android-settings`, `android-native`, `android-notifications`, `web-chrome`,
`web-chrome-addresses`, `material3` or `cross-platform`. `platform` is a
`DevicePlatform` name and sets the style of the gallery and the cross-platform
screen. `theme` is `light` or `dark`; without it the app follows the system.
