import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

enum DevicePlatform {
  android,
  iOS,
  linux,
  macOS,
  windows,
  web,

  /// Use this to specify you want to use the default device platform
  device,
}

abstract class PlatformUtils {
  static DevicePlatform detectPlatform(BuildContext context) {
    if (kIsWeb) return .web;

    final platform = Theme.of(context).platform;
    return switch (platform) {
      .android || .fuchsia => .android,
      .iOS => .iOS,
      .linux => .linux,
      .macOS => .macOS,
      .windows => .windows,
    };
  }
}
