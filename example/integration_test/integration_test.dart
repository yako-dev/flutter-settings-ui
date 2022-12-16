import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart' as app;
import 'package:settings_ui/settings_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const duration = Duration(seconds: 2);

  group('Integration tests for Setting UI', () {
    testWidgets('Integration tests for Setting UI', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pump(duration);

      /// Abstract iOS screen
      final abstractFinder =
          find.widgetWithText(SettingsTile, 'Abstract settings screen');
      final abstractTile = tester.widget<SettingsTile>(abstractFinder);
      expect(find.widgetWithText(SettingsTile, 'Abstract settings screen'),
          findsOneWidget);
      expect(abstractTile.tileType, SettingsTileType.navigationTile);

      await tester.tap(abstractFinder);
      await tester.pumpAndSettle();
      await tester.pump(duration);

      final switchFinder = find.descendant(
          of: find.widgetWithText(SettingsTile, 'Enable custom theme'),
          matching: find.byType(CupertinoSwitch));

      expect(switchFinder, findsOneWidget);
      expect(tester.widget<CupertinoSwitch>(switchFinder).value, false);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      await tester.pump(duration);

      expect(tester.widget<CupertinoSwitch>(switchFinder).value, true);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      await tester.pump(duration);

      final platformFinder = find.widgetWithText(SettingsTile, 'Platform');
      final platformTileTrailing =
          tester.widget<SettingsTile>(platformFinder).value as Text;

      expect(platformTileTrailing.data, 'Default');

      await tester.tap(platformFinder);
      await tester.pumpAndSettle();
      await tester.pump(duration);

      expect(find.text('Platforms'), findsOneWidget);

      /// Android Screen

      await tester.tap(find.text('Android'));
      await tester.pumpAndSettle();
      await tester.pump(duration);

      final androidPlatformFinder =
          find.widgetWithText(SettingsTile, 'Platform');
      final androidPlatformTileValue =
          tester.widget<SettingsTile>(androidPlatformFinder).value as Text;

      expect(androidPlatformTileValue.data, 'Android');

      final androidSwitchFinder = find.descendant(
          of: find.widgetWithText(SettingsTile, 'Enable custom theme'),
          matching: find.byType(Switch));

      expect(androidSwitchFinder, findsOneWidget);
      expect(tester.widget<Switch>(androidSwitchFinder).value, false);

      await tester.tap(androidSwitchFinder);
      await tester.pumpAndSettle();
      await tester.pump(duration);

      expect(tester.widget<Switch>(androidSwitchFinder).value, true);

      await tester.tap(androidSwitchFinder);
      await tester.pumpAndSettle();
      await tester.pump(duration);

      await tester.tap(androidPlatformFinder);
      await tester.pumpAndSettle();
      await tester.pump(duration);

      expect(find.text('Platforms'), findsOneWidget);

      /// Web Screen

      await tester.tap(find.text('Web'));
      await tester.pumpAndSettle();
      await tester.pump(duration);

      final webPlatformFinder = find.widgetWithText(SettingsTile, 'Platform');
      final webPlatformTileValue =
          tester.widget<SettingsTile>(webPlatformFinder).value as Text;

      expect(webPlatformTileValue.data, 'Web');

      final webSwitchFinder = find.descendant(
          of: find.widgetWithText(SettingsTile, 'Enable custom theme'),
          matching: find.byType(Switch));

      expect(webSwitchFinder, findsOneWidget);
      expect(tester.widget<Switch>(webSwitchFinder).value, false);

      await tester.tap(webSwitchFinder);
      await tester.pumpAndSettle();
      await tester.pump(duration);

      expect(tester.widget<Switch>(androidSwitchFinder).value, true);

      await tester.tap(webSwitchFinder);
      await tester.pumpAndSettle();
      await tester.pump(duration);

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();
      await tester.pump(duration);
    });
  });
}
