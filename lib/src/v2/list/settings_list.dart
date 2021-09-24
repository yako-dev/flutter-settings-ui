import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/src/v2/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/v2/utils/platform_utils.dart';
import 'package:settings_ui/src/v2/utils/settings_theme.dart';
import 'package:settings_ui/src/v2/utils/theme_provider.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({
    required this.sections,
    this.platform,
    this.theme,
    this.contentPadding,
    Key? key,
  }) : super(key: key);

  final List<AbstractSettingsSection> sections;
  final DevicePlatform? platform;
  final SettingsThemeData? theme;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    DevicePlatform platform;
    if (this.platform == null || this.platform == DevicePlatform.device) {
      platform = PlatformUtils.detectPlatform(context);
    } else {
      platform = this.platform!;
    }

    final themeData = ThemeProvider.getTheme(
      context: context,
      platform: platform,
    ).merge(theme: theme);

    return Center(
      child: Container(
        color: themeData.settingsListBackground,
        constraints: BoxConstraints(maxWidth: 810),
        child: SettingsTheme(
          themeData: themeData,
          platform: platform,
          child: ListView.builder(
            padding: contentPadding ?? calculateDefaultPadding(platform),
            itemCount: sections.length,
            itemBuilder: (BuildContext context, int index) {
              return sections[index];
            },
          ),
        ),
      ),
    );
  }

  EdgeInsets calculateDefaultPadding(DevicePlatform platform) {
    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
        return EdgeInsets.only(top: 0);
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        return EdgeInsets.symmetric(vertical: 20);
      case DevicePlatform.web:
        return EdgeInsets.zero;
      case DevicePlatform.device:
        throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: SettingsList.calculateDefaultPadding',
        );
    }
  }
}
