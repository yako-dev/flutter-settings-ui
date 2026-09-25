import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/split/split_geometry.dart';
import 'package:settings_ui/src/utils/content_column.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_style.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

/// "Back", from the app's localizations when it has them.
String settingsBackLabel(BuildContext context) =>
    Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    )?.backButtonTooltip ??
    'Back';

/// Whether the device is an iPad-size tablet or a desktop, where the
/// Cupertino bars are taller and their buttons sit closer to the edge.
bool _isRegularWidthDevice(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide >= 600 ||
    isDesktopPlatform(Theme.of(context).platform);

/// The bar at the top of a settings page: back button, title and actions,
/// drawn in the style of [platform]. Internal.
///
/// - Cupertino: iOS 26+ navigation bar, inline 17pt semibold title centered
///   on the page, 44pt round glass back button.
/// - Material: 64dp top app bar with an arrow back button and a 22sp title.
/// - Web: the page title as a heading over the content column, with an arrow
///   back button before it when there is somewhere to go back to.
class SettingsPageBar extends StatelessWidget {
  const SettingsPageBar({
    super.key,
    required this.platform,
    required this.title,
    this.actions,
    this.onBack,
    this.showTitle = true,
  });

  final DevicePlatform platform;
  final Widget? title;
  final List<Widget>? actions;

  /// Shows a back button that calls this.
  final VoidCallback? onBack;

  /// False hides the title but keeps the bar (a list page whose large title
  /// is still on screen).
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    switch (settingsStyleFamily(platform)) {
      case SettingsStyleFamily.cupertino:
        return _buildCupertino(context, theme);
      case SettingsStyleFamily.material:
        return _buildMaterial(context, theme);
      case SettingsStyleFamily.web:
        return _buildWeb(context, theme);
    }
  }

  Widget _buildCupertino(BuildContext context, SettingsThemeData theme) {
    final regular = _isRegularWidthDevice(context);
    final edge = regular ? 10.0 : 16.0;
    final title = this.title;
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: regular ? 60 : 44,
        child: NavigationToolbar(
          leading: onBack == null
              ? null
              : Padding(
                  padding: EdgeInsetsDirectional.only(start: edge),
                  child: SettingsGlassBackButton(onPressed: onBack!),
                ),
          middle: title == null
              ? null
              : AnimatedOpacity(
                  opacity: showTitle ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: theme.settingsTileTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: Semantics(header: true, child: title),
                  ),
                ),
          trailing: _actions(edge),
          middleSpacing: 8,
        ),
      ),
    );
  }

  Widget _buildMaterial(BuildContext context, SettingsThemeData theme) {
    final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final backStart = tablet ? 12.0 : 4.0;
    final title = this.title;
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            if (onBack != null)
              Padding(
                padding: EdgeInsetsDirectional.only(start: backStart, end: 8),
                child: IconButton(
                  onPressed: onBack,
                  tooltip: null,
                  icon: Icon(
                    Icons.arrow_back,
                    semanticLabel: settingsBackLabel(context),
                  ),
                  color: theme.settingsTileTextColor,
                ),
              )
            else
              const SizedBox(width: 24),
            Expanded(
              child: title == null
                  ? const SizedBox.shrink()
                  : AnimatedOpacity(
                      opacity: showTitle ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: theme.settingsTileTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: Semantics(header: true, child: title),
                      ),
                    ),
            ),
            ?_actions(4),
          ],
        ),
      ),
    );
  }

  Widget _buildWeb(BuildContext context, SettingsThemeData theme) {
    final title = this.title;
    return LayoutBuilder(
      builder: (context, constraints) {
        final column = webContentColumn(context, constraints.maxWidth);
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: isRtl ? column.right : column.left,
              end: isRtl ? column.left : column.right,
            ),
            // Chrome's 56px toolbar row, level with the menu's "Settings".
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  if (onBack != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: Transform.translate(
                        // Line the arrow up with the column edge.
                        offset: Offset(isRtl ? 8 : -8, 0),
                        child: IconButton(
                          onPressed: onBack,
                          iconSize: 20,
                          icon: Icon(
                            Icons.arrow_back,
                            semanticLabel: settingsBackLabel(context),
                          ),
                          color: theme.leadingIconsColor,
                        ),
                      ),
                    ),
                  Expanded(
                    child: title == null
                        ? const SizedBox.shrink()
                        : DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: theme.settingsTileTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: Semantics(header: true, child: title),
                          ),
                  ),
                  ?_actions(0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget? _actions(double end) {
    final actions = this.actions;
    if (actions == null || actions.isEmpty) return null;
    return Padding(
      padding: EdgeInsetsDirectional.only(end: end),
      child: Row(mainAxisSize: MainAxisSize.min, children: actions),
    );
  }
}

/// The horizontal extent of the web content column in a pane [width] wide:
/// Chrome's 680px column, centered, with 16px margins in narrow windows. In
/// a split view's web detail pane, the column moves toward the menu like
/// Chrome's (see [SettingsContentColumnHint]).
({double left, double right}) webContentColumn(
  BuildContext context,
  double width,
) {
  final reserve = SettingsContentColumnHint.endReserveFor(context, width);
  final available = width - reserve;
  final side = math.max(16.0, (available - 680) / 2);
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  return isRtl
      ? (left: side + reserve, right: side)
      : (left: side, right: side + reserve);
}

/// The iOS 26+ round back button: a 44pt glass circle with a chevron.
class SettingsGlassBackButton extends StatefulWidget {
  const SettingsGlassBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<SettingsGlassBackButton> createState() =>
      _SettingsGlassBackButtonState();
}

class _SettingsGlassBackButtonState extends State<SettingsGlassBackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final isDark =
        (theme.settingsListBackground?.computeLuminance() ?? 1) < 0.2;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    // Measured on iPadOS 27: #F4F4F8 over #F2F2F7 with a faint rim.
    final fill = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF7F7FA);
    final rim = isDark ? const Color(0x33FFFFFF) : const Color(0x14000000);

    return Semantics(
      container: true,
      button: true,
      label: settingsBackLabel(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 1.08 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: Border.all(color: rim, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Color(isDark ? 0x40000000 : 0x0F000000),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Padding(
              // The chevron's ink sits left of the glyph center.
              padding: EdgeInsetsDirectional.only(end: isRtl ? 0 : 2),
              child: Icon(
                isRtl
                    ? CupertinoIcons.chevron_forward
                    : CupertinoIcons.chevron_back,
                size: 22,
                color: theme.settingsTileTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The large title at the top of an iOS list's scroll content: 34pt bold,
/// like the Settings root on iPhone and the sidebar title on iPadOS 18. The
/// bar above shows the inline title once it scrolls away.
class SettingsLargeTitle extends StatelessWidget {
  const SettingsLargeTitle({super.key, required this.title});

  final Widget title;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 20,
          end: 20,
          top: 3,
          bottom: 8,
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            height: 41 / 34,
            color: theme.settingsTileTextColor,
          ),
          child: title,
        ),
      ),
    );
  }
}

/// Android 16 Settings pages: a 64dp action bar with a 36sp title under it
/// that collapses into the bar as the page scrolls. The [body] should be a
/// scroll view that uses the [PrimaryScrollController], as a [SettingsList]
/// without a scrollController does.
class SettingsCollapsingTitleView extends StatelessWidget {
  const SettingsCollapsingTitleView({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.onBack,
    this.background,
  });

  final Widget title;
  final Widget body;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  /// Defaults to the page background.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final delegate = _CollapsingTitleDelegate(
      topPadding: MediaQuery.paddingOf(context).top,
      tablet: MediaQuery.sizeOf(context).shortestSide >= 600,
      title: title,
      actions: actions,
      onBack: onBack,
      backLabel: settingsBackLabel(context),
      background:
          background ?? theme.settingsListBackground ?? const Color(0x00000000),
      foreground: theme.settingsTileTextColor,
    );
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverPersistentHeader(pinned: true, delegate: delegate),
      ],
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: body,
      ),
    );
  }
}

class _CollapsingTitleDelegate extends SliverPersistentHeaderDelegate {
  _CollapsingTitleDelegate({
    required this.topPadding,
    required this.tablet,
    required this.title,
    required this.actions,
    required this.onBack,
    required this.backLabel,
    required this.background,
    required this.foreground,
  });

  // Measured on Android 16: a 64dp action bar and a 179dp app bar.
  static const double _toolbarHeight = 64;
  static const double _titleAreaHeight = 115;

  final double topPadding;
  final bool tablet;
  final Widget title;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final String backLabel;
  final Color background;
  final Color? foreground;

  @override
  double get minExtent => topPadding + _toolbarHeight;

  @override
  double get maxExtent => minExtent + _titleAreaHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = (shrinkOffset / _titleAreaHeight).clamp(0.0, 1.0);
    final actions = this.actions;
    return ColoredBox(
      color: background,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            PositionedDirectional(
              start: 24,
              end: 24,
              bottom: 22,
              child: Opacity(
                opacity: (1 - t * 1.6).clamp(0.0, 1.0),
                child: Semantics(
                  header: true,
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      height: 44 / 36,
                      color: foreground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    child: title,
                  ),
                ),
              ),
            ),
            Positioned(
              top: topPadding,
              left: 0,
              right: 0,
              height: _toolbarHeight,
              child: Row(
                children: [
                  if (onBack != null)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: tablet ? 12 : 4,
                        end: 8,
                      ),
                      child: IconButton(
                        onPressed: onBack,
                        icon: Icon(Icons.arrow_back, semanticLabel: backLabel),
                        color: foreground,
                      ),
                    )
                  else
                    const SizedBox(width: 24),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Opacity(
                        opacity: ((t - 0.7) / 0.3).clamp(0.0, 1.0),
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          child: title,
                        ),
                      ),
                    ),
                  ),
                  if (actions != null && actions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_CollapsingTitleDelegate oldDelegate) =>
      topPadding != oldDelegate.topPadding ||
      tablet != oldDelegate.tablet ||
      title != oldDelegate.title ||
      actions != oldDelegate.actions ||
      onBack != oldDelegate.onBack ||
      backLabel != oldDelegate.backLabel ||
      background != oldDelegate.background ||
      foreground != oldDelegate.foreground;
}
