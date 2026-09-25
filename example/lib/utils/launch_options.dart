import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Options that open a screen in a given style and brightness directly, e.g.
/// for screenshots: `screen`, `platform`, `page` and `theme`.
///
/// Each option is read from the first of these that sets it:
///
/// 1. The web page's query: `/?screen=gnome-power&theme=dark`.
/// 2. The initial route, whose path names the screen:
///    `flutter run --route '/split-view?platform=macOS&page=display'`, or
///    `/#/split-view?platform=macOS` on the web.
/// 3. `--dart-define`s: `--dart-define=SCREEN=macos --dart-define=THEME=dark`
///    (and `PLATFORM`, `PAGE`).
///
/// Without any, the app opens the gallery and follows the system brightness.
class LaunchOptions {
  static const _defines = {
    'screen': String.fromEnvironment('SCREEN'),
    'platform': String.fromEnvironment('PLATFORM'),
    'page': String.fromEnvironment('PAGE'),
    'theme': String.fromEnvironment('THEME'),
  };

  static Uri get _initialRoute =>
      Uri.parse(WidgetsBinding.instance.platformDispatcher.defaultRouteName);

  static String? _option(String name) {
    final fromUrl = kIsWeb ? Uri.base.queryParameters[name] : null;
    if (fromUrl != null) return fromUrl;

    final route = _initialRoute;
    if (name == 'screen') {
      final path = route.path.replaceFirst('/', '');
      if (path.isNotEmpty) return path;
    } else if (route.queryParameters[name] case final value?) {
      return value;
    }

    final defined = _defines[name];
    return defined == null || defined.isEmpty ? null : defined;
  }

  /// `theme=light` or `theme=dark`; the system setting otherwise.
  static ThemeMode get themeMode => switch (_option('theme')) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  /// `platform=<DevicePlatform name>`, in any case (`linux`, `macOS`,
  /// `ios`): the style of the gallery, the cross-platform screen and the
  /// split view. The replica screens keep their own style.
  static DevicePlatform? get platform {
    final name = _option('platform')?.toLowerCase();
    if (name == null) return null;
    for (final platform in DevicePlatform.values) {
      if (platform.name.toLowerCase() == name) return platform;
    }
    return null;
  }

  /// `page=<destination id>`: the page the split view opens, e.g. `display`.
  static String? get page => _option('page');

  /// `screen=<name>`: the screen to open instead of the gallery, one of the
  /// keys of `launchScreens` in `main.dart`.
  static String? get screen => _option('screen');
}
