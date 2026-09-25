import 'package:example/screens/gallery/android_native_settings_screen.dart';
import 'package:example/screens/gallery/android_notifications_screen.dart';
import 'package:example/screens/gallery/android_settings_screen.dart';
import 'package:example/screens/gallery/cross_platform_settings_screen.dart';
import 'package:example/screens/gallery/gnome_power_settings_screen.dart';
import 'package:example/screens/gallery/ios_developer_screen.dart';
import 'package:example/screens/gallery/ios_native_settings_screen.dart';
import 'package:example/screens/gallery/material3_demo_screen.dart';
import 'package:example/screens/gallery/web_chrome_addresses_settings.dart';
import 'package:example/screens/gallery/web_chrome_settings.dart';
import 'package:example/screens/gallery/windows_display_settings_screen.dart';
import 'package:example/screens/gallery_screen.dart';
import 'package:example/utils/launch_options.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

/// The screens that `?screen=<name>` opens instead of the gallery in the web
/// build (see [LaunchOptions]).
const launchScreens = <String, Widget>{
  'cross-platform': CrossPlatformSettingsScreen(),
  'material3': Material3DemoScreen(),
  'ios-developer': IosDeveloperScreen(),
  'ios-native': IosNativeSettingsScreen(),
  'android-settings': AndroidSettingsScreen(),
  'android-native': AndroidNativeSettingsScreen(),
  'android-notifications': AndroidNotificationsScreen(),
  'web-chrome': WebChromeSettings(),
  'web-chrome-addresses': WebChromeAddressesScreen(),
  'gnome-power': GnomePowerSettingsScreen(),
  'windows-display': WindowsDisplaySettingsScreen(),
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
      home: launchScreens[LaunchOptions.screen] ?? const GalleryScreen(),
    );
  }
}
