import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/sections/platforms/android_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/ios_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/web_settings_section.dart';

import '../test_widget_screen.dart';

void settingsSectionsTests(DevicePlatform? platform) {
  testWidgets('Settings Section should render correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TestWidgetScreen(
          platform: platform,
          applicationType: ApplicationType.material,
          settingsTiles: [
            SettingsTile.navigation(
              title: const Text('Abstract settings screen'),
              leading: const Icon(CupertinoIcons.wrench),
              description:
                  const Text('UI created to show plugin\'s possibilities'),
              onPressed: (context) {},
            ),
            SettingsTile.navigation(
              title: const Text('Abstract settings screen'),
              leading: const Icon(CupertinoIcons.wrench),
              description:
                  const Text('UI created to show plugin\'s possibilities'),
              onPressed: (context) {},
            ),
          ],
        ),
      ),
    );
    expect(find.text('General'), findsOneWidget);
    if (platform == DevicePlatform.android ||
        platform == DevicePlatform.fuchsia ||
        platform == DevicePlatform.linux) {
      expect(find.byType(AndroidSettingsSection), findsOneWidget);
      expect(find.byType(IOSSettingsSection), findsNothing);
      expect(find.byType(WebSettingsSection), findsNothing);
    }
    if (platform == DevicePlatform.iOS ||
        platform == DevicePlatform.macOS ||
        platform == DevicePlatform.windows) {
      expect(find.byType(IOSSettingsSection), findsOneWidget);
      expect(find.byType(AndroidSettingsSection), findsNothing);
      expect(find.byType(WebSettingsSection), findsNothing);
    }
    if (platform == DevicePlatform.web) {
      expect(find.byType(WebSettingsSection), findsOneWidget);
      expect(find.byType(IOSSettingsSection), findsNothing);
      expect(find.byType(AndroidSettingsSection), findsNothing);
    }
  });

  testWidgets('Custom Settings Section should render correctly',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TestWidgetScreen(
          platform: platform,
          applicationType: ApplicationType.material,
          settingsTiles: [
            SettingsTile.navigation(
              title: const Text('Abstract settings screen'),
              leading: const Icon(CupertinoIcons.wrench),
              description:
                  const Text('UI created to show plugin\'s possibilities'),
              onPressed: (context) {},
            ),
            SettingsTile.navigation(
              title: const Text('Abstract settings screen'),
              leading: const Icon(CupertinoIcons.wrench),
              description:
                  const Text('UI created to show plugin\'s possibilities'),
              onPressed: (context) {},
            ),
          ],
        ),
      ),
    );
    expect(find.byType(SettingsSection), findsWidgets);
    expect(find.text('Custom settings section'), findsOneWidget);
    expect(find.byType(CustomSettingsSection), findsOneWidget);
  });
}
