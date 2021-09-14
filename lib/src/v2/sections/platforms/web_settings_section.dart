import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui_v2.dart';
import 'package:settings_ui/src/v2/tiles/abstract_settings_tile.dart';
import 'package:settings_ui/src/v2/utils/settings_theme.dart';

class WebSettingsSection extends StatelessWidget {
  const WebSettingsSection({
    required this.tiles,
    required this.margin,
    required this.title,
    Key? key,
  }) : super(key: key);

  final List<AbstractSettingsTile> tiles;
  final EdgeInsetsDirectional? margin;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    return buildSectionBody(context);
  }

  Widget buildSectionBody(BuildContext context) {
    final theme = SettingsTheme.of(context);
    final isLastNonDescriptive = tiles.last is SettingsTile &&
        (tiles.last as SettingsTile).description == null;
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Container(
              height: 65 * scaleFactor,
              padding: EdgeInsetsDirectional.only(
                bottom: 5 * scaleFactor,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: theme.themeData.titleTextColor,
                  fontSize: 13,
                ),
                child: title!,
              ),
            ),
          Divider(
            height: 0,
            color: theme.themeData.dividerColor,
            thickness: 1,
          ),
          Container(
            color: theme.themeData.settingsSectionBackground,
            child: buildTileList(),
          ),
          if (isLastNonDescriptive)
            Divider(
              height: 0,
              color: theme.themeData.dividerColor,
              thickness: 1,
            ),
        ],
      ),
    );
  }

  Widget buildTileList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: tiles.length,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return tiles[index];
      },
    );
  }
}
