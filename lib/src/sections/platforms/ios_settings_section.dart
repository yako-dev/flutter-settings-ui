import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/tiles/platforms/ios_settings_tile_additional_info.dart';

class IOSSettingsSection extends StatelessWidget {
  const IOSSettingsSection({
    required this.tiles,
    required this.margin,
    required this.title,
    this.titlePadding,
    Key? key,
  }) : super(key: key);

  final List<AbstractSettingsTile> tiles;
  final EdgeInsetsDirectional? margin;
  final Widget? title;
  final EdgeInsetsGeometry? titlePadding;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context);
    final isLastNonDescriptive = tiles.last is SettingsTile &&
        (tiles.last as SettingsTile).description == null;
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Padding(
      padding: margin ??
          // TODO: move literals to file with theme constants
          EdgeInsets.only(
            top: 14.0 * scaleFactor,
            bottom: isLastNonDescriptive ? 27 * scaleFactor : 10 * scaleFactor,
            left: 16,
            right: 16,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: titlePadding ??
                  EdgeInsetsDirectional.only(
                    // TODO: move literals to file with theme constants
                    start: 18,
                    bottom: 5 * scaleFactor,
                  ),
              child: DefaultTextStyle(
                key: const Key('ios_settings_section_title_style'),
                // TODO: move literals to file with theme constants
                style: TextStyle(
                  color: theme.themeData.sectionTitleColor,
                  // TODO: is this one hardcoded?
                  fontSize: 13,
                ),
                child: title!,
              ),
            ),
          _IosTileList(tiles: tiles),
        ],
      ),
    );
  }
}

class _IosTileList extends StatelessWidget {
  final List<AbstractSettingsTile> tiles;

  const _IosTileList({
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: tiles.length,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final tile = tiles[index];

        bool enableTop = false;

        // TODO: document this large condition
        final isTopBorderRadiusRequired = index == 0 ||
            (index > 0 &&
                tiles[index - 1] is SettingsTile &&
                (tiles[index - 1] as SettingsTile).description != null);
        if (isTopBorderRadiusRequired) {
          enableTop = true;
        }

        var isBottomBorderRadiusRequired = false;
        // TODO: document this large condition
        if (index == tiles.length - 1 ||
            (index < tiles.length &&
                tile is SettingsTile &&
                (tile).description != null)) {
          isBottomBorderRadiusRequired = true;
        }

        final isDividerRequired = index != tiles.length - 1;

        return IOSSettingsTileAdditionalInfo(
          enableTopBorderRadius: enableTop,
          enableBottomBorderRadius: isBottomBorderRadiusRequired,
          needToShowDivider: isDividerRequired,
          child: tile,
        );
      },
    );
  }
}
