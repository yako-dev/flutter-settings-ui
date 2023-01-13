import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/sections/platforms/android_settings_section.dart';
import 'package:settings_ui/src/tiles/platforms/android_settings_tile.dart';

import 'settings_tests/setting_tile_tests.dart';
import 'settings_tests/settings_list_tests.dart';
import 'settings_tests/settings_sections_tests.dart';
import 'settings_tests/settings_tile_on_tap_tests.dart';
import 'utils_tests/device_platform_tests.dart';

void main() {
  group('Settings Tile constructor tests ', () {
    final settingsTile = SettingsTile(
      title: const Text('Network & internet'),
      description: const Text('Mobile, Wi-Fi, hotspot'),
      leading: const Icon(Icons.wifi),
    );

    testWidgets('Widget should render correctly', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.android,
      ));

      expect(find.byType(AndroidSettingsSection), findsOneWidget);
      expect(find.byType(AndroidSettingsTile), findsOneWidget);
    });

    testWidgets('Title content should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.android,
      ));

      expect(find.text('Network & internet'), findsOneWidget);
    });

    testWidgets('Title style should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.android,
      ));

      final defaultTextFinder = find.ancestor(
          of: find.text('Network & internet'),
          matching: find.byType(DefaultTextStyle));

      final DefaultTextStyle titleWidget =
          tester.firstWidget(defaultTextFinder);

      expect(titleWidget.style.color, const Color(0xff1b1b1b));
      expect(titleWidget.style.fontSize, 18);
      expect(titleWidget.style.fontWeight, FontWeight.w400);
    });

    testWidgets('Description content should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.android,
      ));

      expect(find.text('Mobile, Wi-Fi, hotspot'), findsOneWidget);
    });

    testWidgets('Description style should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.android,
      ));

      final defaultTextFinder = find.ancestor(
          of: find.text('Mobile, Wi-Fi, hotspot'),
          matching: find.byType(DefaultTextStyle));

      final DefaultTextStyle descriptionWidget =
          tester.firstWidget(defaultTextFinder);

      expect(descriptionWidget.style.color, const Color(0xff464646));
      expect(descriptionWidget.style.fontSize, null);
      expect(descriptionWidget.style.fontWeight, null);
    });

    testWidgets('Leading content should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.android,
      ));

      expect(find.byIcon(Icons.wifi), findsOneWidget);
    });

    testWidgets('Leading color should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.android,
      ));

      final iconThemeFinder = find.ancestor(
        of: find.byIcon(Icons.wifi),
        matching: find.byType(IconTheme),
      );

      final IconTheme iconWidget = tester.firstWidget(iconThemeFinder);

      expect(iconWidget.data.color, const Color(0xff464646));
    });
  });

  group('Settings Lists tests for different platforms', () {
    settingsListTests(DevicePlatform.android);
    settingsListTests(DevicePlatform.web);
    settingsListTests(DevicePlatform.macOS);
    settingsListTests(DevicePlatform.iOS);
    settingsListTests(DevicePlatform.fuchsia);
    settingsListTests(DevicePlatform.linux);
    settingsListTests(DevicePlatform.windows);
    settingsListTests(DevicePlatform.device);
    settingsListTests(null);
  });

  group('Settings sections tests for different platforms', () {
    settingsSectionsTests(DevicePlatform.android);
    settingsSectionsTests(DevicePlatform.web);
    settingsSectionsTests(DevicePlatform.macOS);
    settingsSectionsTests(DevicePlatform.iOS);
    settingsSectionsTests(DevicePlatform.fuchsia);
    settingsSectionsTests(DevicePlatform.linux);
    settingsSectionsTests(DevicePlatform.windows);
    settingsSectionsTests(DevicePlatform.device);
  });

  group('Device platform utils tests', () {
    devicePlatformTest(TargetPlatform.android);
    devicePlatformTest(TargetPlatform.fuchsia);
    devicePlatformTest(TargetPlatform.linux);
    devicePlatformTest(TargetPlatform.iOS);
    devicePlatformTest(TargetPlatform.macOS);
    devicePlatformTest(TargetPlatform.windows);
  });

  group('Settings tile tests for different platforms', () {
    settingsTileTests(DevicePlatform.android);
    settingsTileTests(DevicePlatform.fuchsia);
    settingsTileTests(DevicePlatform.linux);
    settingsTileTests(DevicePlatform.iOS);
    settingsTileTests(DevicePlatform.macOS);
    settingsTileTests(DevicePlatform.windows);
    settingsTileTests(DevicePlatform.web);
  });

  group('Settings tile on Tap tests for different platforms', () {
    settingsTileOnTapTests(DevicePlatform.android);
    settingsTileOnTapTests(DevicePlatform.fuchsia);
    settingsTileOnTapTests(DevicePlatform.linux);
    settingsTileOnTapTests(DevicePlatform.iOS);
    settingsTileOnTapTests(DevicePlatform.macOS);
    settingsTileOnTapTests(DevicePlatform.windows);
    settingsTileOnTapTests(DevicePlatform.web);
  });
}

Widget _wrapWithMaterialApp(
  AbstractSettingsTile testWidget,
  DevicePlatform platform,
) {
  return MaterialApp(
    theme: ThemeData.light(),
    home: Scaffold(
      body: SettingsList(
        platform: platform,
        sections: [
          SettingsSection(
            tiles: [testWidget],
          )
        ],
      ),
    ),
  );
}
