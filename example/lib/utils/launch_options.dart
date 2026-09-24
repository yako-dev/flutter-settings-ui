import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Options read from the page URL of the web build, so a screenshot can open
/// a given style, screen and brightness directly, e.g.
/// `/?platform=linux&screen=gnome-power&theme=dark`.
///
/// Outside the web there is no query, so every option is null.
class LaunchOptions {
  static final Map<String, String> _query = Uri.base.queryParameters;

  /// `?platform=<DevicePlatform name>`: the style of the gallery and of the
  /// cross-platform screen.
  static DevicePlatform? get platform =>
      DevicePlatform.values.asNameMap()[_query['platform']];

  /// `?screen=gnome-power` or `?screen=cross-platform`: the first screen.
  static String? get screen => _query['screen'];

  /// `?theme=light` or `?theme=dark`. Follows the system otherwise.
  static ThemeMode get themeMode => switch (_query['theme']) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
