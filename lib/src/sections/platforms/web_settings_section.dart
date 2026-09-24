import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

class WebSettingsSection extends StatelessWidget {
  const WebSettingsSection({
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
    return buildSectionBody(context);
  }

  Widget buildSectionBody(BuildContext context) {
    final theme = SettingsTheme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding:
                  titlePadding ??
                  EdgeInsetsDirectional.only(
                    top: textScaler.scale(24),
                    bottom: textScaler.scale(12),
                  ),
              child: DefaultTextStyle(
                style:
                    (theme.themeData.titleTextStyle ??
                            const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ))
                        .copyWith(color: theme.themeData.titleTextColor),
                child: title!,
              ),
            )
          else
            // Card no longer has a margin, so keep untitled sections apart.
            SizedBox(height: textScaler.scale(8)),
          Card(
            // No margin, so the card's left edge lines up with the title.
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
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
        return Divider(
          height: 0,
          thickness: 1,
          color: SettingsTheme.of(context).themeData.dividerColor,
        );
      },
    );
  }
}
