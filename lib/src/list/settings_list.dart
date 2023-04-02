import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/src/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';
import 'package:settings_ui/src/utils/theme_provider.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({
    required this.sections,
    this.shrinkWrap = false,
    this.physics,
    this.platform,
    this.lightTheme,
    this.darkTheme,
    this.contentPadding,
    this.scrollController,
    this.useSystemTheme = false,
    Key? key,
  }) : super(key: key);

  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final DevicePlatform? platform;
  final SettingsThemeData? lightTheme;
  final SettingsThemeData? darkTheme;
  final EdgeInsetsGeometry? contentPadding;
  final List<AbstractSettingsSection> sections;
  final ScrollController? scrollController;

  /// If true, some parameters will be applied from the system theme
  /// instead of default values of package or values from [SettingsThemeData]
  /// that is: backgroundColor, tileBackgroundColor
  /// TODO add more
  final bool useSystemTheme;

  @override
  Widget build(BuildContext context) {
    DevicePlatform platform;
    if (this.platform == null || this.platform == DevicePlatform.device) {
      platform = PlatformUtils.detectPlatform(context);
    } else {
      platform = this.platform!;
    }

    final brightness = calculateBrightness(context, platform);
    final themeData = ThemeProvider.getTheme(
      context: context,
      platform: platform,
      brightness: brightness,
      useSystemTheme: useSystemTheme,
    ).merge(
        userDefinedSettingsTheme:
            brightness == Brightness.dark ? darkTheme : lightTheme,
        useSystemTheme: useSystemTheme);

    return Container(
      color: themeData.settingsListBackground,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: SettingsTheme(
        themeData: themeData,
        platform: platform,
        child: ListView.builder(
          controller: scrollController,
          physics: physics,
          shrinkWrap: shrinkWrap,
          itemCount: sections.length,
          padding: contentPadding ?? calculateDefaultPadding(platform, context),
          itemBuilder: (BuildContext context, int index) {
            return sections[index];
          },
        ),
      ),
    );
  }

  EdgeInsets calculateDefaultPadding(
      DevicePlatform platform, BuildContext context) {
    if (MediaQuery.of(context).size.width > 810) {
      double padding = (MediaQuery.of(context).size.width - 810) / 2;
      switch (platform) {
        case DevicePlatform.android:
        case DevicePlatform.fuchsia:
        case DevicePlatform.linux:
        case DevicePlatform.iOS:
        case DevicePlatform.macOS:
        case DevicePlatform.windows:
          return EdgeInsets.symmetric(horizontal: padding);
        case DevicePlatform.web:
          return EdgeInsets.symmetric(vertical: 20, horizontal: padding);
        case DevicePlatform.device:
          throw Exception(
            'You can\'t use the DevicePlatform.device in this context. '
            'Incorrect platform: SettingsList.calculateDefaultPadding',
          );
        default:
          return EdgeInsets.symmetric(
            horizontal: padding,
          );
      }
    }
    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        return const EdgeInsets.symmetric(vertical: 0);
      case DevicePlatform.web:
        return const EdgeInsets.symmetric(vertical: 20);
      case DevicePlatform.device:
        throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: SettingsList.calculateDefaultPadding',
        );
    }
  }

  Brightness calculateBrightness(
      BuildContext context, DevicePlatform platform) {
    final Brightness platformBrightness =
        WidgetsBinding.instance.window.platformBrightness;
    final materialBrightness = Theme.of(context).brightness;
    final cupertinoBrightness = CupertinoTheme.of(context).brightness;

    switch (platform) {
      case DevicePlatform.android:
        return materialBrightness;
      case DevicePlatform.iOS:
        return cupertinoBrightness ?? platformBrightness;
      default:
        return platformBrightness;
    }
  }
}
