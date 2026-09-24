import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Options read from the page URL when the example runs on the web, so a
/// screen and a style can be opened directly, e.g. for screenshots:
///
///     ?screen=windows-display&theme=dark
///     ?screen=cross-platform&platform=windows
class LaunchOptions {
  static Map<String, String> get _query =>
      kIsWeb ? Uri.base.queryParameters : const {};

  /// `theme=light` or `theme=dark`; the system setting otherwise.
  static ThemeMode get themeMode => switch (_query['theme']) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  /// `platform=<DevicePlatform name>`, e.g. `windows`.
  static DevicePlatform? get platform =>
      DevicePlatform.values.asNameMap()[_query['platform']];

  /// `screen=<name>`: the screen to open instead of the gallery.
  static String? get screen => _query['screen'];
}
