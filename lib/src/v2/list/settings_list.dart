import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/src/v2/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/v2/utils/settings_theme.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({
    required this.sections,
    this.contentPadding,
    Key? key,
  }) : super(key: key);

  final List<AbstractSettingsSection> sections;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final themeData = buildTheme(context);

    return Material(
      color: themeData.settingsListBackground,
      child: SettingsTheme(
        themeData: themeData,
        child: ListView.builder(
          padding: contentPadding ?? EdgeInsets.symmetric(vertical: 20),
          itemCount: sections.length,
          itemBuilder: (BuildContext context, int index) {
            return sections[index];
          },
        ),
      ),
    );
  }

  SettingsThemeData buildTheme(BuildContext context) {
    final lightSettingsListBackground = Color.fromRGBO(242, 242, 247, 1);
    final darkSettingsListBackground = CupertinoColors.black;

    final lightSettingSectionColor = Color.fromRGBO(255, 255, 255, 1);
    final darkSettingSectionColor = Color.fromRGBO(28, 28, 30, 1);

    final lightSettingsTitleColor = Color.fromRGBO(109, 109, 114, 1);
    final darkSettingsTitleColor = Color.fromRGBO(142, 142, 147, 1);

    final lightSettingsTileTextColor = Colors.black;
    final darkSettingsTileTextColor = Colors.white;

    final isLight =
        MediaQuery.of(context).platformBrightness == Brightness.light;

    final listBackground =
        isLight ? lightSettingsListBackground : darkSettingsListBackground;

    final sectionBarckground =
        isLight ? lightSettingSectionColor : darkSettingSectionColor;

    final titleTextColor =
        isLight ? lightSettingsTitleColor : darkSettingsTitleColor;
    final settingsTileTextColor =
        isLight ? lightSettingsTileTextColor : darkSettingsTileTextColor;

    return SettingsThemeData(
      settingsListBackground: listBackground,
      settingsSectionBarckground: sectionBarckground,
      titleTextColor: titleTextColor,
      settingsTileTextColor: settingsTileTextColor,
    );
  }
}
