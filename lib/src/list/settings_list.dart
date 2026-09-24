import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';
import 'package:settings_ui/src/utils/theme_provider.dart';

enum ApplicationType {
  /// Use this parameter is you are using the MaterialApp
  material,

  /// Use this parameter is you are using the CupertinoApp
  cupertino,

  /// Use this parameter is you are using the MaterialApp for Android
  /// and the CupertinoApp for iOS.
  both,
}

class SettingsList extends StatelessWidget {
  const SettingsList({
    required this.sections,
    this.shrinkWrap = false,
    this.physics,
    this.platform,
    this.lightTheme,
    this.darkTheme,
    this.brightness,
    this.contentPadding,
    this.scrollController,
    this.applicationType = ApplicationType.material,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  });

  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final DevicePlatform? platform;
  final SettingsThemeData? lightTheme;
  final SettingsThemeData? darkTheme;
  final Brightness? brightness;
  final EdgeInsetsGeometry? contentPadding;
  final List<AbstractSettingsSection> sections;
  final ApplicationType applicationType;
  final ScrollController? scrollController;

  /// Controls how the settings list is aligned along the cross axis.
  /// Defaults to [CrossAxisAlignment.center] (content is centered on wide
  /// screens). Use [CrossAxisAlignment.start] for left-aligned content.
  final CrossAxisAlignment crossAxisAlignment;

  static bool _debugDidWarnMissingTheme = false;

  /// Lets tests see the missing-theme warning again after it was printed.
  @visibleForTesting
  static void debugResetMissingThemeWarning() {
    _debugDidWarnMissingTheme = false;
  }

  /// Since v4, colors and brightness come from `package:material_ui` and
  /// `package:cupertino_ui`. An app still built on `package:flutter/material`
  /// has neither theme above this widget, so it silently gets default colors.
  /// Say so once in debug builds.
  void _debugWarnIfMissingTheme(BuildContext context) {
    if (_debugDidWarnMissingTheme) return;
    if (context.findAncestorWidgetOfExactType<Theme>() != null ||
        context.findAncestorWidgetOfExactType<CupertinoTheme>() != null) {
      return;
    }
    _debugDidWarnMissingTheme = true;
    debugPrint(
      'settings_ui: SettingsList found no Theme from package:material_ui or '
      'CupertinoTheme from package:cupertino_ui above it, so it uses default '
      'colors and brightness. Since settings_ui 4.0.0 the app must use '
      'MaterialApp/CupertinoApp from those packages. Apps still on '
      'package:flutter/material.dart should stay on settings_ui ^3.0.1.',
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      _debugWarnIfMissingTheme(context);
      return true;
    }());

    DevicePlatform platform;
    if (this.platform == null || this.platform == DevicePlatform.device) {
      platform = PlatformUtils.detectPlatform(context);
    } else {
      platform = this.platform!;
    }

    final brightness = calculateBrightness(context);

    final themeData = ThemeProvider.getTheme(
      context: context,
      platform: platform,
      brightness: brightness,
    ).merge(theme: brightness == Brightness.dark ? darkTheme : lightTheme);

    return Container(
      color: themeData.settingsListBackground,
      width: MediaQuery.of(context).size.width,
      alignment: crossAxisAlignment == CrossAxisAlignment.start
          ? Alignment.topLeft
          : Alignment.center,
      child: SettingsTheme(
        themeData: themeData,
        platform: platform,
        child: ListView.builder(
          controller: scrollController,
          physics: physics,
          shrinkWrap: shrinkWrap,
          itemCount: sections.length,
          padding: contentPadding ?? calculateDefaultPadding(platform, context),
          itemBuilder: (BuildContext context, int index) {
            return sections[index];
          },
        ),
      ),
    );
  }

  EdgeInsets calculateDefaultPadding(
    DevicePlatform platform,
    BuildContext context,
  ) {
    // Chrome's settings page uses a narrower 680px column than the other
    // platforms' 810px.
    final maxContentWidth = platform == DevicePlatform.web ? 680.0 : 810.0;
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > maxContentWidth) {
      double padding = (screenWidth - maxContentWidth) / 2;
      switch (platform) {
        case DevicePlatform.android:
        case DevicePlatform.fuchsia:
        case DevicePlatform.linux:
        case DevicePlatform.iOS:
        case DevicePlatform.macOS:
        case DevicePlatform.windows:
          return EdgeInsets.symmetric(horizontal: padding);
        case DevicePlatform.web:
          return EdgeInsets.symmetric(
            vertical: 20,
            horizontal: padding < 16 ? 16 : padding,
          );
        case DevicePlatform.device:
          throw Exception(
            'You can\'t use the DevicePlatform.device in this context. '
            'Incorrect platform: SettingsList.calculateDefaultPadding',
          );
      }
    }
    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        return const EdgeInsets.symmetric(vertical: 0);
      case DevicePlatform.web:
        // Keep the cards off the screen edges in narrow browser windows.
        return const EdgeInsets.symmetric(vertical: 20, horizontal: 16);
      case DevicePlatform.device:
        throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: SettingsList.calculateDefaultPadding',
        );
    }
  }

  Brightness calculateBrightness(BuildContext context) {
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
        return platform != DevicePlatform.iOS
            ? materialBrightness
            : cupertinoBrightness;
    }
  }
}
