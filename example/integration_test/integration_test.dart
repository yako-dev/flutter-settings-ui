import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/main.dart' as app;
import 'package:settings_ui/settings_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const settle = Duration(milliseconds: 500);

  // Helper: pump, settle, then wait a short fixed duration for animations.
  Future<void> pumpSettled(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.pump(settle);
  }

  // Helper: navigate back using the OS back button / back icon.
  Future<void> goBack(WidgetTester tester) async {
    final backButtonFinder = find.byTooltip('Back');
    if (backButtonFinder.evaluate().isNotEmpty) {
      await tester.tap(backButtonFinder);
    } else {
      // Cupertino back or material back
      final backIos = find.byIcon(CupertinoIcons.back);
      if (backIos.evaluate().isNotEmpty) {
        await tester.tap(backIos);
      } else {
        final NavigatorState nav =
            tester.state<NavigatorState>(find.byType(Navigator).last);
        nav.pop(null);
      }
    }
    await pumpSettled(tester);
  }

  group('Gallery screen', () {
    testWidgets('Gallery screen renders all sections', (tester) async {
      app.main();
      await pumpSettled(tester);

      // Gallery top-level tiles
      expect(find.text('Abstract settings screen'), findsOneWidget);
      expect(find.text('Material 3 Theme Demo'), findsOneWidget);
      expect(find.text('iOS Developer Screen'), findsOneWidget);
      expect(find.text('Android Settings Screen'), findsOneWidget);
      expect(find.text('Web Settings'), findsOneWidget);
      expect(find.text('iOS Native Settings Screen'), findsOneWidget);
      expect(find.text('Android Native Settings Screen'), findsOneWidget);

      // Section titles
      expect(find.text('General'), findsOneWidget);
      expect(find.text('New in v3'), findsOneWidget);
      expect(find.text('Replications'), findsOneWidget);
    });
  });

  group('CrossPlatformSettingsScreen', () {
    testWidgets('Navigate to cross-platform screen and back', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Abstract settings screen'));
      await pumpSettled(tester);

      // Screen title
      expect(find.text('Settings'), findsWidgets);

      // Common section tiles
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Environment'), findsOneWidget);
      expect(find.text('Platform'), findsOneWidget);

      // Account section
      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);

      // Security section
      expect(find.text('Lock app in background'), findsOneWidget);
      expect(find.text('Use fingerprint'), findsOneWidget);

      // Platform value defaults to 'Default'
      final platformTile = tester
          .widget<SettingsTile>(find.widgetWithText(SettingsTile, 'Platform'));
      expect((platformTile.value as Text).data, 'Default');

      await goBack(tester);
    });

    testWidgets('Custom theme toggle changes theme', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Abstract settings screen'));
      await pumpSettled(tester);

      // Detect the switch type based on running platform
      final switchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Enable custom theme'),
        matching: find.byType(Switch),
      );
      final cupertinoSwitchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Enable custom theme'),
        matching: find.byType(CupertinoSwitch),
      );

      final bool hasMaterialSwitch = switchFinder.evaluate().isNotEmpty;
      final bool hasCupertinoSwitch =
          cupertinoSwitchFinder.evaluate().isNotEmpty;

      expect(hasMaterialSwitch || hasCupertinoSwitch, isTrue,
          reason: 'Enable custom theme tile should contain a Switch widget');

      if (hasMaterialSwitch) {
        expect(tester.widget<Switch>(switchFinder).value, false);
        await tester.tap(switchFinder);
        await pumpSettled(tester);
        expect(tester.widget<Switch>(switchFinder).value, true);
        // Toggle back
        await tester.tap(switchFinder);
        await pumpSettled(tester);
        expect(tester.widget<Switch>(switchFinder).value, false);
      } else {
        expect(
            tester.widget<CupertinoSwitch>(cupertinoSwitchFinder).value, false);
        await tester.tap(cupertinoSwitchFinder);
        await pumpSettled(tester);
        expect(
            tester.widget<CupertinoSwitch>(cupertinoSwitchFinder).value, true);
        await tester.tap(cupertinoSwitchFinder);
        await pumpSettled(tester);
        expect(
            tester.widget<CupertinoSwitch>(cupertinoSwitchFinder).value, false);
      }

      await goBack(tester);
    });

    testWidgets('Platform picker navigates and changes platform',
        (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Abstract settings screen'));
      await pumpSettled(tester);

      // Open platform picker
      await tester.tap(find.widgetWithText(SettingsTile, 'Platform'));
      await pumpSettled(tester);

      expect(find.text('Platforms'), findsOneWidget);
      expect(find.text('Android'), findsOneWidget);
      expect(find.text('iOS'), findsOneWidget);
      expect(find.text('Web'), findsOneWidget);

      // Select Android
      await tester.tap(find.text('Android'));
      await pumpSettled(tester);

      final androidTile = tester
          .widget<SettingsTile>(find.widgetWithText(SettingsTile, 'Platform'));
      expect((androidTile.value as Text).data, 'Android');

      // Android platform uses material Switch
      final androidSwitchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Enable custom theme'),
        matching: find.byType(Switch),
      );
      expect(androidSwitchFinder, findsOneWidget);

      // Open platform picker again
      await tester.tap(find.widgetWithText(SettingsTile, 'Platform'));
      await pumpSettled(tester);

      // Select Web
      await tester.tap(find.text('Web'));
      await pumpSettled(tester);

      final webTile = tester
          .widget<SettingsTile>(find.widgetWithText(SettingsTile, 'Platform'));
      expect((webTile.value as Text).data, 'Web');

      // Web uses material Switch
      final webSwitchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Enable custom theme'),
        matching: find.byType(Switch),
      );
      expect(webSwitchFinder, findsOneWidget);

      // Toggle web switch
      expect(tester.widget<Switch>(webSwitchFinder).value, false);
      await tester.tap(webSwitchFinder);
      await pumpSettled(tester);
      expect(tester.widget<Switch>(webSwitchFinder).value, true);
      await tester.tap(webSwitchFinder);
      await pumpSettled(tester);

      // Open platform picker and select iOS
      await tester.tap(find.widgetWithText(SettingsTile, 'Platform'));
      await pumpSettled(tester);
      await tester.tap(find.text('iOS'));
      await pumpSettled(tester);

      final iosTile = tester
          .widget<SettingsTile>(find.widgetWithText(SettingsTile, 'Platform'));
      expect((iosTile.value as Text).data, 'iOS');

      // iOS uses CupertinoSwitch
      final iosSwitchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Enable custom theme'),
        matching: find.byType(CupertinoSwitch),
      );
      expect(iosSwitchFinder, findsOneWidget);
      expect(tester.widget<CupertinoSwitch>(iosSwitchFinder).value, false);

      await goBack(tester);
    });
  });

  group('Material 3 Demo Screen', () {
    testWidgets('Renders and seed color changes', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Material 3 Theme Demo'));
      await pumpSettled(tester);

      expect(find.text('Material 3 Demo'), findsOneWidget);
      expect(find.text('Seed color'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Purple'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Orange'), findsOneWidget);
      expect(find.text('Red'), findsOneWidget);

      // Switch seed color
      await tester.tap(find.text('Purple'));
      await pumpSettled(tester);
      // A checkmark should now appear next to Purple
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Green'));
      await pumpSettled(tester);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await goBack(tester);
    });

    testWidgets('Dark mode toggle works', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Material 3 Theme Demo'));
      await pumpSettled(tester);

      final darkModeSwitchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Dark mode'),
        matching: find.byType(Switch),
      );
      expect(darkModeSwitchFinder, findsOneWidget);
      expect(tester.widget<Switch>(darkModeSwitchFinder).value, false);

      await tester.tap(darkModeSwitchFinder);
      await pumpSettled(tester);
      expect(tester.widget<Switch>(darkModeSwitchFinder).value, true);

      await tester.tap(darkModeSwitchFinder);
      await pumpSettled(tester);
      expect(tester.widget<Switch>(darkModeSwitchFinder).value, false);

      await goBack(tester);
    });

    testWidgets('Notifications and location access tiles visible',
        (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Material 3 Theme Demo'));
      await pumpSettled(tester);

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Location access'), findsOneWidget);
      expect(find.text('Compact tiles'), findsOneWidget);

      await goBack(tester);
    });
  });

  group('iOS Developer Screen', () {
    testWidgets('Renders and switch tiles work', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('iOS Developer Screen'));
      await pumpSettled(tester);

      expect(find.text('Developer'), findsOneWidget);
      expect(find.text('Dark Appearance'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      expect(find.text('Enable UI Automation'), findsOneWidget);
      expect(find.text('Fast App Termination'), findsOneWidget);

      // Toggle Dark Appearance
      final darkAppearanceSwitchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Dark Appearance'),
        matching: find.byType(CupertinoSwitch),
      );
      expect(darkAppearanceSwitchFinder, findsOneWidget);
      final initial =
          tester.widget<CupertinoSwitch>(darkAppearanceSwitchFinder).value;

      await tester.tap(darkAppearanceSwitchFinder);
      await pumpSettled(tester);
      expect(tester.widget<CupertinoSwitch>(darkAppearanceSwitchFinder).value,
          !initial);

      await goBack(tester);
    });
  });

  group('Android Settings Screen', () {
    testWidgets('Renders settings tiles', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Android Settings Screen'));
      await pumpSettled(tester);

      expect(find.text('Network & internet'), findsOneWidget);
      expect(find.text('Connected devices'), findsOneWidget);
      expect(find.text('Apps'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Battery'), findsOneWidget);
      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('Sound & vibration'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);

      await goBack(tester);
    });

    testWidgets('Tap tile navigates to Notifications screen', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Android Settings Screen'));
      await pumpSettled(tester);

      await tester.tap(find.text('Network & internet'));
      await pumpSettled(tester);

      // Should be on notifications screen
      expect(find.text('Notifications'), findsWidgets);
      expect(find.text('App settings'), findsOneWidget);

      await goBack(tester);
      await goBack(tester);
    });
  });

  group('Android Notifications Screen', () {
    testWidgets('All sections and switch tiles render', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Android Settings Screen'));
      await pumpSettled(tester);

      await tester.tap(find.text('Notifications'));
      await pumpSettled(tester);

      expect(find.text('Manage'), findsOneWidget);
      expect(find.text('Conservation'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Notification dot on app icon'), findsOneWidget);

      // Scroll the tile's text label into view before interacting
      await tester.ensureVisible(find.text('Notification dot on app icon'));
      await pumpSettled(tester);

      final notifDotSwitchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Notification dot on app icon'),
        matching: find.byType(Switch),
      );
      expect(notifDotSwitchFinder, findsOneWidget);
      expect(tester.widget<Switch>(notifDotSwitchFinder).value, true);

      await tester.ensureVisible(notifDotSwitchFinder);
      await pumpSettled(tester);
      await tester.tap(notifDotSwitchFinder);
      await pumpSettled(tester);
      expect(tester.widget<Switch>(notifDotSwitchFinder).value, false);

      await goBack(tester);
      await goBack(tester);
    });
  });

  group('Web Chrome Settings', () {
    testWidgets('Renders auto-fill and privacy sections', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Web Settings'));
      await pumpSettled(tester);

      expect(find.text('Auto-fill'), findsOneWidget);
      expect(find.text('Passwords'), findsOneWidget);
      expect(find.text('Payment methods'), findsOneWidget);
      expect(find.text('Addresses and more'), findsOneWidget);
      expect(find.text('Privacy and security'), findsOneWidget);
      expect(find.text('Clear browsing data'), findsOneWidget);

      await goBack(tester);
    });

    testWidgets('Navigate to Addresses screen', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Web Settings'));
      await pumpSettled(tester);

      await tester.tap(find.text('Addresses and more'));
      await pumpSettled(tester);

      expect(find.text('Addresses and more'), findsWidgets);
      expect(find.text('Save and fill addresses'), findsOneWidget);

      // Toggle the switch
      final saveAddressSwitchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Save and fill addresses'),
        matching: find.byType(Switch),
      );
      expect(saveAddressSwitchFinder, findsOneWidget);
      expect(tester.widget<Switch>(saveAddressSwitchFinder).value, true);

      await tester.tap(saveAddressSwitchFinder);
      await pumpSettled(tester);
      expect(tester.widget<Switch>(saveAddressSwitchFinder).value, false);

      await goBack(tester);
      await goBack(tester);
    });
  });

  group('iOS Native Settings Screen', () {
    testWidgets('Renders sections and profile tile', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('iOS Native Settings Screen'));
      await pumpSettled(tester);

      expect(find.text('Sign in to your iPhone'), findsOneWidget);
      expect(find.text('Screen time'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Passwords'), findsOneWidget);
      expect(find.text('News'), findsOneWidget);
      expect(find.text('Maps'), findsOneWidget);

      await goBack(tester);
    });
  });

  group('Android Native Settings Screen', () {
    testWidgets('Renders native settings layout', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Android Native Settings Screen'));
      await pumpSettled(tester);

      expect(find.text('Search Settings'), findsOneWidget);
      expect(find.text('Network & internet'), findsOneWidget);
      expect(find.text('Sound & vibration'), findsOneWidget);

      await goBack(tester);
    });
  });

  group('SettingsTile states', () {
    testWidgets('Disabled tile is not interactive', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Abstract settings screen'));
      await pumpSettled(tester);

      // Email tile is disabled
      final emailTile = tester
          .widget<SettingsTile>(find.widgetWithText(SettingsTile, 'Email'));
      expect(emailTile.enabled, false);

      await goBack(tester);
    });
  });

  group('SettingsList scroll controller', () {
    testWidgets('Web settings can scroll via controller (tap triggers scroll)',
        (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.tap(find.text('Web Settings'));
      await pumpSettled(tester);

      // Tap Passwords tile which animates the scroll controller
      await tester.tap(find.text('Passwords'));
      await pumpSettled(tester);

      // No crash — the scroll animation completed
      expect(find.text('Auto-fill'), findsOneWidget);

      await goBack(tester);
    });
  });
}
