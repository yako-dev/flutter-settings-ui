import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class WebSettingsSection extends StatelessWidget {
  const WebSettingsSection({
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
    return buildSectionBody(context);
  }

  Widget buildSectionBody(BuildContext context) {
    final theme = SettingsTheme.of(context);
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Container(
              height: 65 * scaleFactor,
              padding: titlePadding ??
                  EdgeInsetsDirectional.only(
                    bottom: 5 * scaleFactor,
                    start: 6,
                    top: 40 * scaleFactor,
                  ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: theme.themeData.titleTextColor,
                  fontSize: 15,
                ),
                child: title!,
              ),
            ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 4,
            color: theme.themeData.settingsSectionBackground,
            child: buildTileList(),
          ),
        ],
      ),
    );
  }

  Widget buildTileList() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: tiles.length,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return tiles[index];
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(
          height: 0,
          thickness: 1,
        );
      },
    );
  }
}
