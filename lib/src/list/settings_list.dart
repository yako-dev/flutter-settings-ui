import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/src/sections/abstract_settings_section.dart';
import 'package:settings_ui/src/utils/exceptions.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';
import 'package:settings_ui/src/utils/theme_providers/theme_provider.dart';

class SettingsList extends StatefulWidget {
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
    this.wideScreenBreakpoint = 810,
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

  /// Width of the screen from [MediaQuery]'s [Size]
  /// at which the wide screen padding will be applied
  final double wideScreenBreakpoint;

  /// If true, some parameters will be applied from the system theme
  /// instead of default values of package or values from [SettingsThemeData]
  /// that is: backgroundColor, tileBackgroundColor
  /// TODO add more
  final bool useSystemTheme;

  @override
  State<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  late DevicePlatform platform;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.platform == null || widget.platform == DevicePlatform.device) {
      platform = PlatformUtils.detectPlatform(context);
    } else {
      platform = widget.platform!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBrightness = _getThemeBrightness(context, platform);
    final userDefinedTheme = themeBrightness == Brightness.dark
        ? widget.darkTheme
        : widget.lightTheme;

    final themeData = ThemeProvider.getTheme(
      context: context,
      platform: platform,
      brightness: themeBrightness,
      useSystemTheme: widget.useSystemTheme,
    ).merge(
      userDefinedSettingsTheme: userDefinedTheme,
      useSystemTheme: widget.useSystemTheme,
    );

    return Container(
      color: themeData.settingsListBackground,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: SettingsTheme(
        themeData: themeData,
        platform: platform,
        child: ListView.builder(
          controller: widget.scrollController,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          itemCount: widget.sections.length,
          padding:
              widget.contentPadding ?? _getDefaultPadding(platform, context),
          itemBuilder: (BuildContext context, int index) {
            return widget.sections[index];
          },
        ),
      ),
    );
  }

  EdgeInsets _getDefaultPadding(
    DevicePlatform platform,
    BuildContext context,
  ) {
    final mqSizeWidth = MediaQuery.sizeOf(context).width;
    final isWideScreen = mqSizeWidth > widget.wideScreenBreakpoint;
    double horizontalPaddingValue =
        (mqSizeWidth - widget.wideScreenBreakpoint) / 2;

    switch (platform) {
      case DevicePlatform.android:
      case DevicePlatform.fuchsia:
      case DevicePlatform.linux:
      case DevicePlatform.iOS:
      case DevicePlatform.macOS:
      case DevicePlatform.windows:
        return isWideScreen
            ? EdgeInsets.symmetric(
                horizontal: horizontalPaddingValue,
              )
            : EdgeInsets.zero;
      case DevicePlatform.web:
        return isWideScreen
            ? EdgeInsets.symmetric(
                vertical: 20,
                horizontal: horizontalPaddingValue,
              )
            : const EdgeInsets.symmetric(
                vertical: 20,
              );
      case DevicePlatform.device:
        throw InvalidDevicePlatformDeviceUsage(
          'SettingsList._getDefaultPadding',
        );
    }
  }

  Brightness _getThemeBrightness(
    BuildContext context,
    DevicePlatform platform,
  ) {
    // final platformBrightness =
    //     View.of(context).platformDispatcher.platformBrightness;
    // TODO: remove this deprecated Window usage whenever min dark SDK constraint is 3.0
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
