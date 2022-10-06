import 'package:example/main.dart';
import 'package:example/screens/gallery/android_notifications_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/tiles/platforms/ios_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/android_settings_tile.dart';

void main() {
  testWidgets('Abstract settings UI', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MyApp());

      final abstractTileFinder =
          find.widgetWithIcon(SettingsTile, CupertinoIcons.wrench);

      expect(abstractTileFinder, findsOneWidget);

      await tester.tap(abstractTileFinder);
      await tester.pumpAndSettle();

      final themeTileFinder =
          find.widgetWithText(SettingsTile, 'Enable custom theme');

      await tester.ensureVisible(themeTileFinder);

      expect(themeTileFinder, findsOneWidget);
    });
  });

  testWidgets('Ios title Test', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MyApp());

      final iosTileFinder =
          find.widgetWithIcon(SettingsTile, CupertinoIcons.settings);

      expect(iosTileFinder, findsOneWidget);

      await tester.tap(iosTileFinder);
      await tester.pumpAndSettle();

      final themeTileFinder =
          find.widgetWithText(IOSSettingsTile, 'Dark Appearance');

      await tester.ensureVisible(themeTileFinder);

      expect(themeTileFinder, findsOneWidget);

      final switcherFinder = find.descendant(
        of: themeTileFinder,
        matching: find.byType(CupertinoSwitch),
      );

      expect(switcherFinder, findsOneWidget);

      await tester.tap(switcherFinder);
      await tester.pump();

      final switcherWidget = tester.widget<CupertinoSwitch>(switcherFinder);

      expect(switcherWidget.value, false);
    });
  });

  testWidgets('Android UI tests', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MyApp());

      final androidTileFinder =
          find.widgetWithIcon(SettingsTile, Icons.settings);

      expect(androidTileFinder, findsOneWidget);

      await tester.tap(androidTileFinder);
      await tester.pumpAndSettle();

      final notificationFinder =
          find.widgetWithIcon(AndroidSettingsTile, Icons.notifications_none);

      await tester.ensureVisible(notificationFinder);

      expect(notificationFinder, findsOneWidget);

      await tester.tap(notificationFinder);

      await tester.pumpAndSettle();

      final notificationSwitcherFinder =
          find.widgetWithText(SettingsTile, 'Notification dot on app icon');

      await tester.dragUntilVisible(
        notificationSwitcherFinder,
        find.byType(AndroidNotificationsScreen),
        const Offset(0, -300),
      );
      await tester.pump();

      expect(notificationSwitcherFinder, findsOneWidget);

      final switcherFinder = find.descendant(
        of: notificationSwitcherFinder,
        matching: find.byType(Switch),
      );

      expect(switcherFinder, findsOneWidget);

      await tester.tap(switcherFinder);
      await tester.pump();

      final switcherWidget = tester.widget<Switch>(switcherFinder);

      expect(switcherWidget.value, false);
    });
  });

  testWidgets('Web settings UI test', (tester) async {
    tester.runAsync(() async {
      final webTileFinder = find.widgetWithIcon(SettingsTile, Icons.settings);

      expect(webTileFinder, findsOneWidget);

      await tester.tap(webTileFinder);
      await tester.pumpAndSettle();

      final locationTileFinder =
          find.widgetWithIcon(SettingsTile, Icons.location_on);

      await tester.ensureVisible(locationTileFinder);

      expect(locationTileFinder, findsOneWidget);

      await tester.tap(locationTileFinder);

      await tester.pumpAndSettle();

      final switcherFinder = find.byType(Switch);

      expect(switcherFinder, findsOneWidget);

      await tester.tap(switcherFinder);
      await tester.pump();

      final switcherWidget = tester.widget<Switch>(switcherFinder);

      expect(switcherWidget.value, false);
    });
  });
}
