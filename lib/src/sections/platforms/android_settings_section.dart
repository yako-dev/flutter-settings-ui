import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/tiles/abstract_settings_tile.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

class AndroidSettingsSection extends StatelessWidget {
  const AndroidSettingsSection({
    required this.tiles,
    required this.margin,
    this.title,
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
    final tileList = buildTileList();

    return title == null
        ? tileList
        : buildTitle(context: context, child: tileList);
  }

  Widget buildTileList() => ListView.builder(
    shrinkWrap: true,
    itemCount: tiles.length,
    padding: .zero,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (_, index) => tiles[index],
  );

  Widget buildTitle({required BuildContext context, required Widget child}) {
    final theme = SettingsTheme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    return Padding(
      padding: margin ?? .zero,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding:
                titlePadding ??
                .only(
                  top: textScaler.scale(24),
                  bottom: textScaler.scale(10),
                  left: 24,
                  right: 24,
                ),
            child: DefaultTextStyle(
              style: (theme.themeData.titleTextStyle ?? const TextStyle())
                  .copyWith(color: theme.themeData.titleTextColor),
              child: title!,
            ),
          ),
          Container(
            color: theme.themeData.settingsSectionBackground,
            child: child,
          ),
        ],
      ),
    );
  }
}
