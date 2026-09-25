import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/list/settings_list.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';
import 'package:settings_ui/src/utils/theme_provider.dart';

/// The style inputs of a [SettingsList] or `SettingsSplitView`: platform,
/// brightness override, themes and application type. Internal.
@immutable
class SettingsStyleConfig {
  const SettingsStyleConfig({
    this.platform,
    this.brightness,
    this.lightTheme,
    this.darkTheme,
    this.applicationType = ApplicationType.material,
  });

  /// Null or [DevicePlatform.device] means "detect".
  final DevicePlatform? platform;
  final Brightness? brightness;
  final SettingsThemeData? lightTheme;
  final SettingsThemeData? darkTheme;
  final ApplicationType applicationType;

  bool get _detectsPlatform =>
      platform == null || platform == DevicePlatform.device;

  /// Fills what this config leaves unset from [parent]: a list in a page
  /// opened from another list looks like the list that opened it.
  ///
  /// [ApplicationType.material] is the default, so it counts as unset.
  SettingsStyleConfig inheritFrom(SettingsStyleConfig? parent) {
    if (parent == null) return this;
    return SettingsStyleConfig(
      platform: _detectsPlatform ? parent.platform : platform,
      brightness: brightness ?? parent.brightness,
      lightTheme: lightTheme ?? parent.lightTheme,
      darkTheme: darkTheme ?? parent.darkTheme,
      applicationType: applicationType == ApplicationType.material
          ? parent.applicationType
          : applicationType,
    );
  }

  DevicePlatform resolvePlatform(BuildContext context) =>
      _detectsPlatform ? PlatformUtils.detectPlatform(context) : platform!;

  Brightness resolveBrightness(BuildContext context) {
    final brightness = this.brightness;
    if (brightness != null) return brightness;

    final materialBrightness = Theme.of(context).brightness;
    final cupertinoBrightness =
        CupertinoTheme.of(context).brightness ??
        MediaQuery.of(context).platformBrightness;

    switch (applicationType) {
      case ApplicationType.material:
        return materialBrightness;
      case ApplicationType.cupertino:
        return cupertinoBrightness;
      case ApplicationType.both:
        // Decide by the platform the app runs on, which picks the app widget,
        // not by the tile style set in [platform]. Inside a MaterialApp the
        // CupertinoTheme follows the Material theme, so the Cupertino
        // brightness is also right for a MaterialApp on iOS or macOS.
        final hostPlatform = PlatformUtils.detectPlatform(context);
        return hostPlatform == DevicePlatform.iOS ||
                hostPlatform == DevicePlatform.macOS
            ? cupertinoBrightness
            : materialBrightness;
    }
  }

  ResolvedSettingsStyle resolve(BuildContext context) {
    final platform = resolvePlatform(context);
    final brightness = resolveBrightness(context);
    final themeData = ThemeProvider.getTheme(
      context: context,
      platform: platform,
      brightness: brightness,
    ).merge(theme: brightness == Brightness.dark ? darkTheme : lightTheme);
    return ResolvedSettingsStyle(
      config: this,
      platform: platform,
      brightness: brightness,
      themeData: themeData,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SettingsStyleConfig &&
      other.platform == platform &&
      other.brightness == brightness &&
      other.lightTheme == lightTheme &&
      other.darkTheme == darkTheme &&
      other.applicationType == applicationType;

  @override
  int get hashCode =>
      Object.hash(platform, brightness, lightTheme, darkTheme, applicationType);
}

/// A [SettingsStyleConfig] resolved against a [BuildContext].
@immutable
class ResolvedSettingsStyle {
  const ResolvedSettingsStyle({
    required this.config,
    required this.platform,
    required this.brightness,
    required this.themeData,
  });

  final SettingsStyleConfig config;

  /// Never [DevicePlatform.device].
  final DevicePlatform platform;
  final Brightness brightness;
  final SettingsThemeData themeData;

  /// [config] with the detected platform filled in, for pages that this
  /// screen opens.
  SettingsStyleConfig get resolvedConfig => SettingsStyleConfig(
    platform: platform,
    brightness: config.brightness,
    lightTheme: config.lightTheme,
    darkTheme: config.darkTheme,
    applicationType: config.applicationType,
  );
}

/// Which of the three looks a [DevicePlatform] uses.
enum SettingsStyleFamily { cupertino, material, web }

SettingsStyleFamily settingsStyleFamily(DevicePlatform platform) {
  switch (platform) {
    case DevicePlatform.iOS:
    case DevicePlatform.macOS:
    case DevicePlatform.windows:
      return SettingsStyleFamily.cupertino;
    case DevicePlatform.android:
    case DevicePlatform.fuchsia:
    case DevicePlatform.linux:
      return SettingsStyleFamily.material;
    case DevicePlatform.web:
      return SettingsStyleFamily.web;
    case DevicePlatform.device:
      throw Exception(
        'You can\'t use the DevicePlatform.device in this context. '
        'Incorrect platform: settingsStyleFamily',
      );
  }
}

/// Puts a [SettingsStyleConfig] in the tree. Internal.
///
/// Every [SettingsList] puts its own config here (with [inherit] false) so
/// its tiles can hand it to the pages they open. Those pages put it back
/// with [inherit] true, and a [SettingsList] in the page fills its unset
/// style inputs from it.
class SettingsStyleScope extends InheritedWidget {
  const SettingsStyleScope({
    super.key,
    required this.config,
    this.inherit = false,
    required super.child,
  });

  final SettingsStyleConfig config;

  /// Whether a [SettingsList] below takes its unset style inputs from
  /// [config]. False for a list's own scope, so nested lists keep
  /// detecting their style as before.
  final bool inherit;

  static SettingsStyleScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsStyleScope>();

  /// The config a [SettingsList] at [context] should inherit, if any.
  static SettingsStyleConfig? inheritedConfigOf(BuildContext context) {
    final scope = maybeOf(context);
    return scope != null && scope.inherit ? scope.config : null;
  }

  @override
  bool updateShouldNotify(SettingsStyleScope oldWidget) =>
      config != oldWidget.config || inherit != oldWidget.inherit;
}
