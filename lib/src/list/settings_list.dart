import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/adwaita_settings_section.dart';
import 'package:settings_ui/src/sections/settings_section.dart';
import 'package:settings_ui/src/utils/content_column.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_style.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

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

    // A list in a page opened from a settings tile takes the style inputs it
    // leaves unset from the list that opened the page.
    final config = SettingsStyleConfig(
      platform: this.platform,
      brightness: brightness,
      lightTheme: lightTheme,
      darkTheme: darkTheme,
      applicationType: applicationType,
    ).inheritFrom(SettingsStyleScope.inheritedConfigOf(context));
    final style = config.resolve(context);
    final platform = style.platform;
    final themeData = style.themeData;

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
          child: SettingsStyleScope(
            config: style.resolvedConfig,
            child: SettingsTheme(
              themeData: themeData,
              platform: platform,
              child: ListView.builder(
                controller: scrollController,
                physics: physics,
                shrinkWrap: shrinkWrap,
                itemCount: sections.length,
                padding:
                    contentPadding ?? _defaultPadding(context, platform, width),
                itemBuilder: (BuildContext context, int index) {
                  return sections[index];
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// [calculateDefaultPadding], adjusted for a split view's detail pane
  /// (see [SettingsContentColumnHint]).
  EdgeInsets _defaultPadding(
    BuildContext context,
    DevicePlatform platform,
    double width,
  ) {
    final hint = SettingsContentColumnHint.of(context, width);
    if (hint != null && hint.fillWidth && _fillsDetailPane(platform)) {
      // A page in the detail pane of iPad or Android Settings fills the
      // pane: no spare width to turn into side padding. (These styles have
      // no minimum side padding, so a zero width gives just that.)
      return calculateDefaultPadding(platform, context, width: 0);
    }
    final reserve = hint?.endReserve ?? 0;
    final padding = calculateDefaultPadding(
      platform,
      context,
      width: width - reserve,
    );
    if (reserve == 0) return padding;
    final isRtl = Directionality.maybeOf(context) == TextDirection.rtl;
    return padding.copyWith(
      left: isRtl ? padding.left + reserve : null,
      right: isRtl ? null : padding.right + reserve,
    );
  }

  /// Whether a list in this style fills a split view's detail pane.
  ///
  /// iPad and Android Settings pages use the whole detail pane. The content
  /// panes of macOS System Settings, Windows Settings and GNOME Settings are
  /// what these styles' own columns and margins model, so they keep them
  /// there; the web style keeps Chrome's 680px column.
  static bool _fillsDetailPane(DevicePlatform platform) {
    switch (platform) {
      case DevicePlatform.iOS:
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
        return true;
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
      case DevicePlatform.linux:
      case DevicePlatform.web:
      case DevicePlatform.device:
        return false;
    }
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
        contentWidth = math.min(availableWidth, 810);
        minSidePadding = 0;
        topPadding = 0;
        bottomPadding = 0;
      case DevicePlatform.macOS:
        // System Settings has a fixed-width window, so its cards are never
        // wider than about 470pt. A 640pt column (600pt cards) keeps each
        // label close to its control in wide windows.
        contentWidth = math.min(availableWidth, 640);
        minSidePadding = 0;
        // The first card starts 12pt down, and a first header 20pt down
        // (its section's own top margin), like in System Settings.
        topPadding = _startsWithHeader ? 0 : 12;
        // With the last section's 10pt bottom margin: 20pt below the last
        // card, like System Settings.
        bottomPadding = 10;
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

  /// Whether the first section that shows anything is a [SettingsSection]
  /// with a title.
  bool get _startsWithHeader {
    for (final section in sections) {
      if (section is SettingsSection) {
        if (section.tiles.isEmpty) continue;
        return section.title != null;
      }
      return false;
    }
    return false;
  }

  Brightness calculateBrightness(BuildContext context) {
    return SettingsStyleConfig(
      brightness: brightness,
      applicationType: applicationType,
    ).resolveBrightness(context);
  }
}
