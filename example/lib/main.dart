import 'package:example/screens/gallery/android_native_settings_screen.dart';
import 'package:example/screens/gallery/android_notifications_screen.dart';
import 'package:example/screens/gallery/android_settings_screen.dart';
import 'package:example/screens/gallery/cross_platform_settings_screen.dart';
import 'package:example/screens/gallery/gnome_power_settings_screen.dart';
import 'package:example/screens/gallery/ios_developer_screen.dart';
import 'package:example/screens/gallery/ios_native_settings_screen.dart';
import 'package:example/screens/gallery/macos_notifications_screen.dart';
import 'package:example/screens/gallery/material3_demo_screen.dart';
import 'package:example/screens/gallery/split_view_screen.dart';
import 'package:example/screens/gallery/web_chrome_addresses_settings.dart';
import 'package:example/screens/gallery/web_chrome_settings.dart';
import 'package:example/screens/gallery/windows_display_settings_screen.dart';
import 'package:example/screens/gallery_screen.dart';
import 'package:example/utils/launch_options.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

void main() {
  runApp(const MyApp());
}

/// The screens that the `screen` launch option opens instead of the gallery
/// (see [LaunchOptions]).
final launchScreens = <String, Widget Function()>{
  'cross-platform': CrossPlatformSettingsScreen.new,
  'material3': Material3DemoScreen.new,
  'split-view': () => SplitViewScreen(
    platform: LaunchOptions.platform ?? DevicePlatform.device,
    initialPageId: LaunchOptions.page,
  ),
  'ios-developer': IosDeveloperScreen.new,
  'ios-native': IosNativeSettingsScreen.new,
  'macos': MacosNotificationsScreen.new,
  'android-settings': AndroidSettingsScreen.new,
  'android-native': AndroidNativeSettingsScreen.new,
  'android-notifications': AndroidNotificationsScreen.new,
  'web-chrome': WebChromeSettings.new,
  'web-chrome-addresses': WebChromeAddressesScreen.new,
  'gnome-power': GnomePowerSettingsScreen.new,
  'windows-display': WindowsDisplaySettingsScreen.new,
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData(
        useMaterial3: true,
        cupertinoOverrideTheme: const CupertinoThemeData(
          barBackgroundColor: Color(0xFF1b1b1b),
          brightness: Brightness.dark,
          textTheme: CupertinoTextThemeData(primaryColor: Colors.white),
        ),
        brightness: Brightness.dark,
      ),
      themeMode: LaunchOptions.themeMode,
      title: 'Settings UI Demo',
      // LaunchOptions has already read the platform's initial route (from
      // `--route`, or the `#/...` part of the web URL); don't push it again.
      initialRoute: Navigator.defaultRouteName,
      home:
          launchScreens[LaunchOptions.screen]?.call() ?? const GalleryScreen(),
    );
  }
}
