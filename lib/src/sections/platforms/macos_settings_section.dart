import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/tiles/abstract_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/macos_settings_tile.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

/// A group of a macOS 26/27 System Settings grouped form.
///
/// The header sits above the card in 13pt semibold, 10pt in from the card
/// edge.
/// The tiles share a card with 12pt continuous corners and no border or
/// shadow, split by 1pt separators inset 10pt from both card edges. A tile's
/// `description` becomes 11pt grey text under the card, and the tiles after
/// it start a new card, as SwiftUI does for a section footer.
///
/// Spacing, as measured in System Settings: cards sit 20pt from the sides of
/// the list, 10pt apart, and a header's line starts 30pt below the card
/// above it.
class MacosSettingsSection extends StatelessWidget {
  const MacosSettingsSection({
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

  /// Space above a header: with the previous section's 10pt bottom margin,
  /// the header line starts 30pt below the card or footer above it. At the
  /// top of the list it starts 20pt down.
  static const double headerTopGap = 20;

  /// Space between a header's 16pt line and the card.
  static const double headerBottomGap = 10;

  /// Space between two cards.
  static const double cardGap = 10;

  /// Side margins of the cards.
  static const double sideMargin = 20;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final textScaler = MediaQuery.textScalerOf(context);

    final children = <Widget>[];
    if (title != null) {
      final style = theme.titleTextStyle ?? kMacosHeaderStyle;
      children.add(
        Padding(
          padding:
              titlePadding ??
              EdgeInsetsDirectional.only(
                start: kMacosRowInset,
                end: kMacosRowInset,
                bottom: textScaler.scale(headerBottomGap),
              ),
          child: Semantics(
            container: true,
            header: true,
            child: DefaultTextStyle(
              style: style.copyWith(color: style.color ?? theme.titleTextColor),
              child: title!,
            ),
          ),
        ),
      );
    }

    // A tile with a description ends its card: the description goes under
    // the card and the next tile starts a new one.
    var cardStart = 0;
    for (var i = 0; i < tiles.length; i++) {
      final tile = tiles[i];
      final description = tile is SettingsTile ? tile.description : null;
      final isLastTile = i == tiles.length - 1;
      if (description == null && !isLastTile) continue;

      children.add(
        _MacosCard(theme: theme, tiles: tiles.sublist(cardStart, i + 1)),
      );
      if (description != null) {
        children.add(
          buildMacosFooter(
            context: context,
            description: description,
            padding: (tile as SettingsTile).descriptionPadding,
            isLast: isLastTile,
          ),
        );
      }
      cardStart = i + 1;
    }

    return Padding(
      padding:
          margin ??
          EdgeInsetsDirectional.only(
            start: sideMargin,
            end: sideMargin,
            top: title == null ? 0 : textScaler.scale(headerTopGap),
            bottom: textScaler.scale(cardGap),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// One card: the tiles on the card color, with separators between them.
class _MacosCard extends StatelessWidget {
  const _MacosCard({required this.theme, required this.tiles});

  final SettingsThemeData theme;
  final List<AbstractSettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    final separator = Padding(
      padding: const EdgeInsets.symmetric(horizontal: kMacosRowInset),
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: theme.dividerColor ?? const Color(0x00000000)),
      ),
    );

    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(kMacosCardRadius),
      child: ColoredBox(
        color: theme.settingsSectionBackground ?? const Color(0x00000000),
        // Lets Material widgets (InkWell, IconButton...) in custom tiles
        // work without a Scaffold, and gives custom tiles the row text style.
        child: Material(
          type: MaterialType.transparency,
          child: DefaultTextStyle(
            style: kMacosBodyStyle.copyWith(color: theme.settingsTileTextColor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) separator,
                  MacosSettingsTileScope(
                    isFirst: i == 0,
                    isLast: i == tiles.length - 1,
                    child: tiles[i],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
