import 'package:flutter/material.dart';
import 'package:settings_ui/src/tiles/abstract_settings_tile.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

class AndroidSettingsSection extends StatelessWidget {
  const AndroidSettingsSection({
    required this.tiles,
    required this.margin,
    this.title,
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

    // TODO: usage of textScaleFactor requires documentation
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    if (title == null) {
      return _IosTileList(tiles: tiles);
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: titlePadding ??
                // TODO: move literals to file with theme constants
                EdgeInsetsDirectional.only(
                  top: 24 * scaleFactor,
                  bottom: 10 * scaleFactor,
                  start: 24,
                  end: 24,
                ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: theme.themeData.titleTextColor,
              ),
              child: title!,
            ),
          ),
          Container(
            color: theme.themeData.settingsSectionBackground,
            child: _IosTileList(tiles: tiles),
          ),
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
        return tiles[index];
      },
    );
  }
}
