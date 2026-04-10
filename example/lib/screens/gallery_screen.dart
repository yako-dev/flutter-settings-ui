import 'package:example/screens/gallery/android_native_settings_screen.dart';
import 'package:example/screens/gallery/android_settings_screen.dart';
import 'package:example/screens/gallery/cross_platform_settings_screen.dart';
import 'package:example/screens/gallery/ios_developer_screen.dart';
import 'package:example/screens/gallery/ios_native_settings_screen.dart';
import 'package:example/screens/gallery/material3_demo_screen.dart';
import 'package:example/screens/gallery/web_chrome_settings.dart';
import 'package:example/utils/navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('General'),
            tiles: [
              SettingsTile.navigation(
                title: const Text('Abstract settings screen'),
                leading: const Icon(CupertinoIcons.wrench),
                description:
                    const Text('UI created to show plugin\'s possibilities'),
                onPressed: (context) {
                  Navigation.navigateTo(
                    context: context,
                    screen: const CrossPlatformSettingsScreen(),
                    style: NavigationRouteStyle.material,
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('New in v3'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.color_lens),
                title: const Text('Material 3 Theme Demo'),
                description: const Text('Colors derived from your ColorScheme'),
                onPressed: (context) {
                  Navigation.navigateTo(
                    context: context,
                    screen: const Material3DemoScreen(),
                    style: NavigationRouteStyle.material,
                  );
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Replications'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(CupertinoIcons.settings),
                title: const Text('iOS Developer Screen'),
                onPressed: (context) {
                  Navigation.navigateTo(
                    context: context,
                    screen: const IosDeveloperScreen(),
                    style: NavigationRouteStyle.cupertino,
                  );
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.settings),
                title: const Text('Android Settings Screen'),
                onPressed: (context) {
                  Navigation.navigateTo(
                    context: context,
                    screen: const AndroidSettingsScreen(),
                    style: NavigationRouteStyle.material,
                  );
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.web),
                title: const Text('Web Settings'),
                onPressed: (context) {
                  Navigation.navigateTo(
                    context: context,
                    screen: const WebChromeSettings(),
                    style: NavigationRouteStyle.material,
                  );
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(CupertinoIcons.device_phone_portrait),
                title: const Text('iOS Native Settings Screen'),
                onPressed: (context) {
                  Navigation.navigateTo(
                    context: context,
                    screen: const IosNativeSettingsScreen(),
                    style: NavigationRouteStyle.cupertino,
                  );
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.adb),
                title: const Text('Android Native Settings Screen'),
                onPressed: (context) {
                  Navigation.navigateTo(
                    context: context,
                    screen: const AndroidNativeSettingsScreen(),
                    style: NavigationRouteStyle.cupertino,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
