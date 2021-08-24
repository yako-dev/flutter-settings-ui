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

    final lightSettingSectionColor = CupertinoColors.white;
    final darkSettingSectionColor = Color.fromARGB(255, 28, 28, 30);

    final lightSettingsTitleColor = Color.fromRGBO(109, 109, 114, 1);
    final darkSettingsTitleColor = CupertinoColors.systemGrey;

    final lightDividerColor = Color.fromARGB(255, 238, 238, 238);
    final darkDividerColor = Color.fromARGB(255, 40, 40, 42);

    final lightTrailingTextColor = Color.fromARGB(255, 138, 138, 142);
    final darkTrailingTextColor = Color.fromARGB(255, 152, 152, 159);

    final lightSettingsTileTextColor = CupertinoColors.black;
    final darkSettingsTileTextColor = CupertinoColors.white;

    final isLight =
        MediaQuery.of(context).platformBrightness == Brightness.light;

    final listBackground =
        isLight ? lightSettingsListBackground : darkSettingsListBackground;

    final sectionBackground =
        isLight ? lightSettingSectionColor : darkSettingSectionColor;

    final titleTextColor =
        isLight ? lightSettingsTitleColor : darkSettingsTitleColor;

    final settingsTileTextColor =
        isLight ? lightSettingsTileTextColor : darkSettingsTileTextColor;

    final dividerColor = isLight ? lightDividerColor : darkDividerColor;

    final trailingTextColor =
        isLight ? lightTrailingTextColor : darkTrailingTextColor;

    return SettingsThemeData(
      settingsListBackground: listBackground,
      settingsSectionBackground: sectionBackground,
      titleTextColor: titleTextColor,
      dividerColor: dividerColor,
      trailingTextColor: trailingTextColor,
      settingsTileTextColor: settingsTileTextColor,
    );
  }
}
