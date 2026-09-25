import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Options that open a screen, a style and a brightness directly, e.g. for
/// screenshots. On the web they come from the page URL, elsewhere from
/// `--dart-define`s (the URL wins when both are set):
///
///     /?screen=gnome-power&theme=dark
///     /?platform=linux                       (the gallery in the GNOME style)
///     /?screen=cross-platform&platform=windows
///     flutter run -d macos --dart-define=SCREEN=macos --dart-define=THEME=dark
///
/// Without them the app opens the gallery and follows the system brightness.
class LaunchOptions {
  static const _defines = {
    'screen': String.fromEnvironment('SCREEN'),
    'platform': String.fromEnvironment('PLATFORM'),
    'theme': String.fromEnvironment('THEME'),
  };

  static String? _option(String name) {
    final fromUrl = kIsWeb ? Uri.base.queryParameters[name] : null;
    if (fromUrl != null) return fromUrl;
    final defined = _defines[name];
    return defined == null || defined.isEmpty ? null : defined;
  }

  /// `theme=light` or `theme=dark` (`THEME`); the system setting otherwise.
  static ThemeMode get themeMode => switch (_option('theme')) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  /// `platform=<DevicePlatform name>` (`PLATFORM`), e.g. `linux` or
  /// `windows`: the style of the gallery and of the cross-platform screen.
  /// The replica screens keep their own style.
  static DevicePlatform? get platform =>
      DevicePlatform.values.asNameMap()[_option('platform')];

  /// `screen=<name>` (`SCREEN`): the screen to open instead of the gallery,
  /// one of the keys of `launchScreens` in `main.dart`.
  static String? get screen => _option('screen');
}
