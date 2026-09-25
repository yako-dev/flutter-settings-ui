import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/tiles/platforms/adwaita_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/android_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/fluent_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/ios_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/web_settings_tile.dart';

import '../test_widget_screen.dart';

void settingsTileTests(DevicePlatform platform) {
  testWidgets('Settings Tile should render correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TestWidgetScreen(
          platform: platform,
          settingsTiles: [
            SettingsTile(
              title: const Text('Abstract settings tile'),
              value: const Text('Tile Value'),
              trailing: const Icon(Icons.ac_unit, size: 24),
            ),
            SettingsTile(title: const Text('UI settings screen')),
          ],
        ),
      ),
    );

    expect(find.text('Abstract settings tile'), findsOneWidget);
    expect(find.text('UI settings screen'), findsOneWidget);
    expect(find.byIcon(Icons.ac_unit), findsOneWidget);

    if (platform == DevicePlatform.android ||
        platform == DevicePlatform.fuchsia) {
      expect(find.byType(AndroidSettingsTile), findsWidgets);
      expect(find.byType(IOSSettingsTile), findsNothing);
      expect(find.byType(WebSettingsTile), findsNothing);
      expect(find.text('Tile Value'), findsOneWidget);
    }
    if (platform == DevicePlatform.linux) {
      expect(find.byType(AdwaitaSettingsTile), findsWidgets);
      expect(find.byType(AndroidSettingsTile), findsNothing);
      expect(find.byType(IOSSettingsTile), findsNothing);
      expect(find.byType(FluentSettingsTile), findsNothing);
      expect(find.byType(WebSettingsTile), findsNothing);
      expect(find.text('Tile Value'), findsOneWidget);
    }
    if (platform == DevicePlatform.iOS || platform == DevicePlatform.macOS) {
      expect(find.byType(IOSSettingsTile), findsWidgets);
      expect(find.byType(AndroidSettingsTile), findsNothing);
      expect(find.byType(WebSettingsTile), findsNothing);
    }
    if (platform == DevicePlatform.windows) {
      expect(find.byType(FluentSettingsTile), findsWidgets);
      expect(find.byType(AdwaitaSettingsTile), findsNothing);
      expect(find.byType(IOSSettingsTile), findsNothing);
      expect(find.byType(AndroidSettingsTile), findsNothing);
      expect(find.byType(WebSettingsTile), findsNothing);
      expect(find.text('Tile Value'), findsOneWidget);
    }
    if (platform == DevicePlatform.web) {
      expect(find.byType(WebSettingsTile), findsWidgets);
      expect(find.byType(IOSSettingsTile), findsNothing);
      expect(find.byType(AndroidSettingsTile), findsNothing);
      expect(find.text('Tile Value'), findsOneWidget);
    }
  });

  testWidgets('Settings Switch Tile should render correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TestWidgetScreen(
          platform: platform,
          settingsTiles: [
            SettingsTile.switchTile(
              title: const Text('Switch tile with null toggle value'),
              initialValue: true,
              onToggle: null,
              trailing: const Icon(Icons.ac_unit, size: 24),
            ),
            SettingsTile.switchTile(
              title: const Text('Switch tile without null toggle value'),
              onToggle: (bool value) {},
              initialValue: false,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Switch tile with null toggle value'), findsOneWidget);
    expect(find.text('Switch tile without null toggle value'), findsOneWidget);
    expect(find.byIcon(Icons.ac_unit), findsOneWidget);

    if (platform == DevicePlatform.android ||
        platform == DevicePlatform.fuchsia ||
        platform == DevicePlatform.web) {
      expect(find.byType(Switch), findsWidgets);
      expect(find.byType(CupertinoSettingsSwitch), findsNothing);
    }
    if (platform == DevicePlatform.linux) {
      expect(find.byType(AdwaitaSettingsSwitch), findsNWidgets(2));
      expect(find.byType(Switch), findsNothing);
      expect(find.byType(CupertinoSettingsSwitch), findsNothing);
      expect(find.byType(FluentSettingsSwitch), findsNothing);
    }
    if (platform == DevicePlatform.iOS || platform == DevicePlatform.macOS) {
      expect(find.byType(Switch), findsNothing);
      expect(find.byType(CupertinoSettingsSwitch), findsWidgets);
    }
    if (platform == DevicePlatform.windows) {
      expect(find.byType(Switch), findsNothing);
      expect(find.byType(CupertinoSettingsSwitch), findsNothing);
      expect(find.byType(AdwaitaSettingsSwitch), findsNothing);
      expect(find.byType(FluentSettingsSwitch), findsNWidgets(2));
    }
  });

  testWidgets('Settings IOS Navigation Tile should render correctly', (
    tester,
  ) async {
    if (platform == DevicePlatform.iOS || platform == DevicePlatform.macOS) {
      await tester.pumpWidget(
        MaterialApp(
          home: TestWidgetScreen(
            platform: platform,
            settingsTiles: [
              SettingsTile.navigation(
                title: const Text('Navigation tile with value'),
                onPressed: (context) {},
                value: const Text('Settings Tile Value'),
              ),
              SettingsTile.navigation(
                title: const Text('Navigation tile without value'),
                onPressed: (context) {},
                titleDescription: const Text('Title description value'),
                trailing: const Icon(Icons.ac_unit, size: 24),
              ),
            ],
          ),
        ),
      );
      expect(find.text('Navigation tile with value'), findsOneWidget);
      expect(find.text('Navigation tile without value'), findsOneWidget);
      expect(find.text('Settings Tile Value'), findsOneWidget);
      expect(find.text('Title description value'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.chevron_forward), findsWidgets);
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
      expect(find.byType(IOSSettingsTile), findsWidgets);
    }
  });

  testWidgets('Settings Fluent Navigation Tile should render correctly', (
    tester,
  ) async {
    if (platform != DevicePlatform.windows) return;
    await tester.pumpWidget(
      MaterialApp(
        home: TestWidgetScreen(
          platform: platform,
          settingsTiles: [
            SettingsTile.navigation(
              title: const Text('Navigation tile with value'),
              onPressed: (context) {},
              value: const Text('Settings Tile Value'),
            ),
            SettingsTile.navigation(
              title: const Text('Navigation tile without value'),
              onPressed: (context) {},
              titleDescription: const Text('Title description value'),
              trailing: const Icon(Icons.ac_unit, size: 24),
            ),
          ],
        ),
      ),
    );
    expect(find.text('Navigation tile with value'), findsOneWidget);
    expect(find.text('Navigation tile without value'), findsOneWidget);
    expect(find.text('Settings Tile Value'), findsOneWidget);
    expect(find.text('Title description value'), findsOneWidget);
    expect(find.byIcon(Icons.ac_unit), findsOneWidget);
    expect(find.byType(FluentSettingsTile), findsNWidgets(2));
    // The Fluent chevron is painted, not an icon.
    expect(find.byIcon(CupertinoIcons.chevron_forward), findsNothing);
  });
}
