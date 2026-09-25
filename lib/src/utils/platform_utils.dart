import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// The style of a `SettingsList`, named after the platform whose settings
/// app it follows.
///
/// [device] (auto-detect) is only valid as the `platform` of a `SettingsList`
/// or `SettingsSplitView`.
enum DevicePlatform {
  /// Android: <https://www.android.com/>
  android,

  /// Fuchsia: <https://fuchsia.dev/fuchsia-src/concepts>
  fuchsia,

  /// iOS: <https://www.apple.com/ios/>
  iOS,

  /// Linux: <https://www.linux.org>
  linux,

  /// macOS: <https://www.apple.com/macos>
  macOS,

  /// Windows: <https://www.windows.com>
  windows,

  /// Web
  web,

  /// Use this to specify you want to use the default device platform
  device,
}

/// Detects the style of a `SettingsList` whose platform is not set.
class PlatformUtils {
  /// Returns [DevicePlatform.web] in a browser, otherwise the style for
  /// `Theme.of(context).platform`. Platforms that only exist in forks of
  /// Flutter (such as OpenHarmony) get [DevicePlatform.iOS].
  static DevicePlatform detectPlatform(BuildContext context) {
    if (kIsWeb) return DevicePlatform.web;

    final platform = Theme.of(context).platform;

    switch (platform) {
      case TargetPlatform.android:
        return DevicePlatform.android;
      case TargetPlatform.fuchsia:
        return DevicePlatform.fuchsia;
      case TargetPlatform.iOS:
        return DevicePlatform.iOS;
      case TargetPlatform.linux:
        return DevicePlatform.linux;
      case TargetPlatform.macOS:
        return DevicePlatform.macOS;
      case TargetPlatform.windows:
        return DevicePlatform.windows;
      // Forks of Flutter can add platforms, e.g. TargetPlatform.ohos on
      // OpenHarmony, which would not compile without a default (#205).
      // ignore: unreachable_switch_default
      default:
        return DevicePlatform.iOS;
    }
  }
}
