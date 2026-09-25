import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Options read from the page URL when the example runs on the web, so a
/// screen, a style and a brightness can be opened directly, e.g. for
/// screenshots:
///
///     ?screen=gnome-power&theme=dark
///     ?screen=windows-display&theme=light
///     ?platform=linux                        (the gallery in the GNOME style)
///     ?screen=cross-platform&platform=windows
///
/// Outside the web there is no query, so every option is null (or
/// [ThemeMode.system]) and the app opens the gallery.
class LaunchOptions {
  static Map<String, String> get _query =>
      kIsWeb ? Uri.base.queryParameters : const {};

  /// `theme=light` or `theme=dark`; the system setting otherwise.
  static ThemeMode get themeMode => switch (_query['theme']) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  /// `platform=<DevicePlatform name>`, e.g. `linux` or `windows`: the style
  /// of the gallery and of the cross-platform screen. The replica screens
  /// keep their own style.
  static DevicePlatform? get platform =>
      DevicePlatform.values.asNameMap()[_query['platform']];

  /// `screen=<name>`: the screen to open instead of the gallery, one of the
  /// keys of `launchScreens` in `main.dart`.
  static String? get screen => _query['screen'];
}
