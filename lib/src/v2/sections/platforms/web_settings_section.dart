import 'package:flutter/material.dart';
import 'package:settings_ui/src/v2/tiles/abstract_settings_tile.dart';

class WebSettingsSection extends StatelessWidget {
  const WebSettingsSection({
    required this.tiles,
    this.title,
    Key? key,
  }) : super(key: key);

  final List<AbstractSettingsTile> tiles;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    return buildSectionBody();
  }

  Widget buildSectionBody() {
    final tileList = buildTileList();

    if (title == null) {
      return tileList;
    }

    return Column(
      children: [
        title!,
        tileList,
      ],
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
