import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';
import 'package:settings_ui/src/utils/theme_provider.dart';

enum ApplicationType {
  /// Use this parameter is you are using the MaterialApp
  material,

  /// Use this parameter is you are using the CupertinoApp
  cupertino,

  /// Use this parameter is you are using the MaterialApp for Android
  /// and the CupertinoApp for iOS.
  both,
}

class SettingsList extends StatelessWidget {
  const SettingsList({
    required this.sections,
    this.shrinkWrap = false,
    this.physics,
    this.platform,
    this.lightTheme,
    this.darkTheme,
    this.brightness,
    this.contentPadding,
    this.scrollController,
    this.applicationType = .material,
    this.crossAxisAlignment = .center,
    super.key,
  });

  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final DevicePlatform? platform;
  final SettingsThemeData? lightTheme;
  final SettingsThemeData? darkTheme;
  final Brightness? brightness;
  final EdgeInsetsGeometry? contentPadding;
  final List<AbstractSettingsSection> sections;
  final ApplicationType applicationType;
  final ScrollController? scrollController;

  /// Controls how the settings list is aligned along the cross axis.
  /// Defaults to [CrossAxisAlignment.center] (content is centered on wide
  /// screens). Use [CrossAxisAlignment.start] for left-aligned content.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    DevicePlatform platform = this.platform == null || this.platform == .device
        ? PlatformUtils.detectPlatform(context)
        : this.platform!;

    final brightness = calculateBrightness(context);
    final themeData = ThemeProvider.getTheme(
      context: context,
      platform: platform,
      brightness: brightness,
    ).merge(theme: brightness == .dark ? darkTheme : lightTheme);

    return Container(
      color: themeData.settingsListBackground,
      width: MediaQuery.of(context).size.width,
      alignment: crossAxisAlignment == .start ? .topLeft : .center,
      child: SettingsTheme(
        themeData: themeData,
        platform: platform,
        child: ListView.builder(
          controller: scrollController,
          physics: physics,
          shrinkWrap: shrinkWrap,
          itemCount: sections.length,
          padding: contentPadding ?? calculateDefaultPadding(platform, context),
          itemBuilder: (context, index) {
            return sections[index];
          },
        ),
      ),
    );
  }

  EdgeInsets calculateDefaultPadding(
    DevicePlatform platform,
    BuildContext context,
  ) {
    if (MediaQuery.of(context).size.width > 810) {
      double padding = (MediaQuery.of(context).size.width - 810) / 2;
      return switch (platform) {
        .android ||
        .linux ||
        .iOS ||
        .macOS ||
        .windows => .symmetric(horizontal: padding),
        .web => .symmetric(vertical: 20, horizontal: padding),
        .device => throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: SettingsList.calculateDefaultPadding',
        ),
      };
    } else {
      return switch (platform) {
        .android ||
        .linux ||
        .iOS ||
        .macOS ||
        .windows => const .symmetric(vertical: 0),
        .web => const .symmetric(vertical: 20),
        .device => throw Exception(
          'You can\'t use the DevicePlatform.device in this context. '
          'Incorrect platform: SettingsList.calculateDefaultPadding',
        ),
      };
    }
  }

  Brightness calculateBrightness(BuildContext context) {
    final materialBrightness = Theme.of(context).brightness;
    final cupertinoBrightness =
        CupertinoTheme.of(context).brightness ??
        MediaQuery.of(context).platformBrightness;

    return switch (applicationType) {
      .material => materialBrightness,
      .cupertino => cupertinoBrightness,
      .both => platform != .iOS ? materialBrightness : cupertinoBrightness,
    };
  }
}
