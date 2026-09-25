import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/adwaita_settings_section.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';
import 'package:settings_ui/src/utils/theme_provider.dart';

enum ApplicationType {
  /// Use this parameter is you are using the MaterialApp
  material,

  /// Use this parameter is you are using the CupertinoApp
  cupertino,

  /// Use this parameter if you are using the MaterialApp for Android
  /// and the CupertinoApp for iOS. On iOS and macOS the brightness comes from
  /// the CupertinoTheme, which follows the Material theme in a MaterialApp.
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

  /// Forces light or dark colors. When null, the brightness comes from the
  /// app theme, as set by [applicationType].
  final Brightness? brightness;
  final EdgeInsetsGeometry? contentPadding;
  final List<AbstractSettingsSection> sections;
  final ApplicationType applicationType;
  final ScrollController? scrollController;

  /// Controls how the settings list is aligned along the cross axis.
  /// Defaults to [CrossAxisAlignment.center] (content is centered on wide
  /// screens). Use [CrossAxisAlignment.start] to align the content with the
  /// start edge (left in LTR, right in RTL). Has no effect when
  /// [contentPadding] is set.
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the width the parent gives the list, not the screen width, so
        // a list in a narrow pane of a wide window fits the pane. Fall back to
        // the screen width when the width is unbounded.
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        return Container(
          color: themeData.settingsListBackground,
          width: width,
          alignment: crossAxisAlignment == CrossAxisAlignment.start
              ? AlignmentDirectional.topStart
              : Alignment.center,
          child: SettingsTheme(
            themeData: themeData,
            platform: platform,
            child: ListView.builder(
              controller: scrollController,
              physics: physics,
              shrinkWrap: shrinkWrap,
              itemCount: sections.length,
              padding:
                  contentPadding ??
                  calculateDefaultPadding(platform, context, width: width),
              itemBuilder: (BuildContext context, int index) {
                return sections[index];
              },
            ),
          ),
        );
      },
    );
  }

  /// The list padding used when [contentPadding] is null.
  ///
  /// When [width] (the list's width, the screen width by default) is wider
  /// than the content column, the spare width becomes side padding. It is
  /// split evenly, or all put at the end with [CrossAxisAlignment.start].
  EdgeInsets calculateDefaultPadding(
    DevicePlatform platform,
    BuildContext context, {
    double? width,
  }) {
    final availableWidth = width ?? MediaQuery.sizeOf(context).width;
    final double contentWidth;
    final double minSidePadding;
    final double topPadding;
    final double bottomPadding;
    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
        contentWidth = math.min(availableWidth, 810);
        minSidePadding = 0;
        topPadding = 0;
        bottomPadding = 0;
      case DevicePlatform.linux:
        // A GNOME preferences page clamps its content like AdwClamp: at most
        // 600sp wide, easing in from 400sp. The groups keep their own 12px
        // side margins and 24px gap below; the page adds 24px on top.
        final textScaler = MediaQuery.textScalerOf(context);
        contentWidth = adwaitaClampWidth(
          availableWidth,
          maximumSize: textScaler.scale(600),
          tighteningThreshold: textScaler.scale(400),
        );
        minSidePadding = 0;
        topPadding = kAdwaitaPageTopMargin;
        bottomPadding = 0;
      case DevicePlatform.windows:
        // Windows 11 Settings pages: 36 margins, down to 16 below the
        // NavigationView's minimal-mode width (641), a column of at most
        // 1000, and 36 at the bottom (the last section adds 4). Section
        // headers bring their own 30 at the top.
        contentWidth = math.min(availableWidth, 1000);
        minSidePadding = availableWidth < 641 ? 16 : 36;
        topPadding = 0;
        bottomPadding = 32;
      case DevicePlatform.web:
        // Chrome's settings page uses a 680px column and keeps the cards off
        // the edges of narrow browser windows.
        contentWidth = math.min(availableWidth, 680);
        minSidePadding = 16;
        topPadding = 20;
        bottomPadding = 20;
      case DevicePlatform.device:
        throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: SettingsList.calculateDefaultPadding',
        );
    }

    final centeredSidePadding = (availableWidth - contentWidth) / 2;
    final sidePadding = centeredSidePadding > minSidePadding
        ? centeredSidePadding
        : minSidePadding;

    if (crossAxisAlignment == CrossAxisAlignment.start) {
      // Same column width as when centered, at the start edge.
      return EdgeInsetsDirectional.only(
        start: minSidePadding,
        end: 2 * sidePadding - minSidePadding,
        top: topPadding,
        bottom: bottomPadding,
      ).resolve(Directionality.maybeOf(context) ?? TextDirection.ltr);
    }
    return EdgeInsets.only(
      left: sidePadding,
      right: sidePadding,
      top: topPadding,
      bottom: bottomPadding,
    );
  }

  Brightness calculateBrightness(BuildContext context) {
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
}
