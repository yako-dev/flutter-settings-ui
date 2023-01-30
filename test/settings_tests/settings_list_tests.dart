import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';

import '../test_widget_screen.dart';

void settingsListTests(DevicePlatform? platform) {
  group('Settings List tests in Material App ', () {
    testWidgets(
        'Settings list with material application type should render correctly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidgetScreen(
            platform: platform,
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

      expect(find.byType(SettingsList), findsOneWidget);
      expect(find.byType(SettingsSection), findsOneWidget);
    });

    testWidgets(
        'Settings list with both application type should render correctly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidgetScreen(
            platform: platform,
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

      expect(find.byType(SettingsList), findsOneWidget);
      expect(find.byType(SettingsSection), findsOneWidget);
    });

    testWidgets('Settings list with big size screen should render correctly',
        (tester) async {
      tester.binding.window.devicePixelRatioTestValue = (2.625);
      final dpi = tester.binding.window.devicePixelRatio;
      tester.binding.window.physicalSizeTestValue = Size(900 * dpi, 1200 * dpi);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(
            home: TestWidgetScreen(
              platform: platform,
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
        ),
      );

      expect(find.byType(SettingsList), findsOneWidget);
      expect(find.byType(SettingsSection), findsOneWidget);
      tester.binding.window.clearAllTestValues();
    });
  });

  group('Settings List tests in Cupertino App with different platforms', () {
    testWidgets('Settings list should render correctly', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          home: TestWidgetScreen(
            platform: platform,
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

      expect(find.byType(SettingsList), findsOneWidget);
      expect(find.byType(SettingsSection), findsOneWidget);
    });
  });
}
