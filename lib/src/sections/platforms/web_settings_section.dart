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

  Widget buildSectionBody(BuildContext context) {
    final theme = SettingsTheme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    return Padding(
      padding: margin ?? .zero,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (title != null)
            Container(
              height: textScaler.scale(65),
              padding:
                  titlePadding ??
                  .only(
                    bottom: textScaler.scale(5),
                    left: 6,
                    top: textScaler.scale(40),
                  ),
              child: DefaultTextStyle(
                style:
                    (theme.themeData.titleTextStyle ??
                            const TextStyle(fontSize: 15))
                        .copyWith(color: theme.themeData.titleTextColor),
                child: title!,
              ),
            ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: .circular(10)),
            elevation: 4,
            color: theme.themeData.settingsSectionBackground,
            child: buildTileList(),
          ),
        ],
      ),
    );
  }

  Widget buildTileList() => ListView.separated(
    shrinkWrap: true,
    itemCount: tiles.length,
    padding: .zero,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (_, index) => tiles[index],
    separatorBuilder: (_, _) => const Divider(height: 0, thickness: 1),
  );

  @override
  Widget build(BuildContext context) => buildSectionBody(context);
}
