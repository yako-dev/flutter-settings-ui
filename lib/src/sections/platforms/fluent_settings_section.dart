import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/tiles/abstract_settings_tile.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/utils/fluent_tokens.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

/// Space between cards in Windows Settings (the Toolkit sample uses 4).
const double _kCardSpacing = 3;

/// A group of cards like a Windows 11 Settings page: a BodyStrong header
/// (margin 1,30,0,6) over one card per setting, 3 apart.
class FluentSettingsSection extends StatelessWidget {
  const FluentSettingsSection({
    required this.tiles,
    required this.margin,
    required this.title,
    this.titlePadding,
    super.key,
  });

  final List<AbstractSettingsTile> tiles;
  final EdgeInsetsDirectional? margin;
  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;

  @override
  Widget build(BuildContext context) {
    final SettingsThemeData theme = SettingsTheme.of(context).themeData;

    // As in Windows Settings, a header's text box is 30 + 3 below the
    // previous card and 6 above its first card (its capitals about 37 and
    // 22), and 19 below a page title right above the list. An untitled
    // section starts 24 below the previous one.
    final afterPageTitle = FluentSectionContext.afterPageTitleOf(context);
    return Padding(
      padding:
          margin ??
          EdgeInsetsDirectional.only(
            top: title == null ? 24 - _kCardSpacing : 0,
            bottom: _kCardSpacing,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding:
                  titlePadding ??
                  EdgeInsetsDirectional.only(
                    start: 1,
                    top: afterPageTitle ? 19 : 30,
                    bottom: 6,
                  ),
              child: Semantics(
                header: true,
                child: DefaultTextStyle(
                  style: (theme.titleTextStyle ?? FluentTypography.bodyStrong)
                      .copyWith(color: theme.titleTextColor),
                  child: title!,
                ),
              ),
            ),
          for (var i = 0; i < tiles.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : _kCardSpacing),
              child: tiles[i] is SettingsTile
                  ? tiles[i]
                  : _FluentCard(child: tiles[i]),
            ),
        ],
      ),
    );
  }
}

/// Tells the first [FluentSettingsSection] of a list whether a Windows
/// page title sits right above the list (the page header of a
/// `SettingsDestinationPage`), which Windows Settings keeps closer to its
/// first group header.
class FluentSectionContext extends InheritedWidget {
  const FluentSectionContext({
    super.key,
    required this.afterPageTitle,
    required super.child,
  });

  final bool afterPageTitle;

  static bool afterPageTitleOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<FluentSectionContext>()
          ?.afterPageTitle ??
      false;

  @override
  bool updateShouldNotify(FluentSectionContext oldWidget) =>
      afterPageTitle != oldWidget.afterPageTitle;
}

/// Put by a Windows style page header above the page body: a Fluent
/// [SettingsList] right below it starts closer to the title. The list
/// resets it for anything nested in it.
class FluentPageTitleAbove extends InheritedWidget {
  const FluentPageTitleAbove({
    super.key,
    this.above = true,
    required super.child,
  });

  final bool above;

  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<FluentPageTitleAbove>()
          ?.above ??
      false;

  @override
  bool updateShouldNotify(FluentPageTitleAbove oldWidget) =>
      above != oldWidget.above;
}

/// The card around a [CustomSettingsTile] or another custom tile: the
/// SettingsCard background, border and corners, without padding.
class _FluentCard extends StatelessWidget {
  const _FluentCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final SettingsThemeData theme = SettingsTheme.of(context).themeData;
    final FluentTokens tokens = FluentTokens.of(
      FluentTokens.brightnessOf(context),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.settingsSectionBackground ?? tokens.card,
        border: Border.all(color: theme.dividerColor ?? tokens.cardStroke),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: ClipRRect(borderRadius: BorderRadius.circular(3), child: child),
      ),
    );
  }
}
