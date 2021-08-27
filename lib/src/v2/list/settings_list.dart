import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/src/v2/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/v2/utils/platform_utils.dart';
import 'package:settings_ui/src/v2/utils/settings_theme.dart';
import 'package:settings_ui/src/v2/utils/theme_provider.dart';

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
    final themeData = ThemeProvider.getTheme(context);

    return Material(
      color: themeData.settingsListBackground,
      child: SettingsTheme(
        themeData: themeData,
        child: ListView.builder(
          padding: contentPadding ?? calculateDefaultPadding(context),
          itemCount: sections.length,
          itemBuilder: (BuildContext context, int index) {
            return sections[index];
          },
        ),
      ),
    );
  }

  EdgeInsets calculateDefaultPadding(BuildContext context) {
    final platform = PlatformUtils.detectPlatform(context);

    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
        return EdgeInsets.only(top: 5);
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        return EdgeInsets.symmetric(vertical: 20);
      case DevicePlatform.web:
        return EdgeInsets.symmetric(vertical: 20);
    }
  }
}
