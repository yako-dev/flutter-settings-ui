import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
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

  // Scrolls a target into view before tapping it, so the test also passes on
  // short screens (iPhone, iPad landscape, the 800x600 macOS window).
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
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
        final NavigatorState nav = tester.state<NavigatorState>(
          find.byType(Navigator).last,
        );
        nav.pop(null);
      }
    }
    await pumpSettled(tester);
  }

  group('Gallery screen', () {
    testWidgets('Gallery screen renders all sections', (tester) async {
      app.main();
      await pumpSettled(tester);

      // Scrolls to each entry: the list is lazy, and short windows don't
      // build its end.
      Future<void> expectEntry(String text) async {
        await tester.scrollUntilVisible(
          find.text(text),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(text), findsOneWidget);
      }

      for (final text in [
        // Section titles and tiles, top to bottom
        'General',
        'Abstract settings screen',
        'New in v3',
        'Material 3 Theme Demo',
        'New in v4',
        'Split view',
        'Showcase',
        'Replications',
        'iOS Developer Screen',
        'Android Settings Screen',
        'Web Settings',
        'iOS Native Settings Screen',
        'macOS System Settings',
        'Android Native Settings Screen',
        'GNOME Settings (Power)',
        'Windows Display Settings',
      ]) {
        await expectEntry(text);
      }

      // The next tests start from this state: scroll back to the top.
      await tester.scrollUntilVisible(
        find.text('General'),
        -100,
        scrollable: find.byType(Scrollable).first,
      );
      await pumpSettled(tester);
    });
  });

  group('CrossPlatformSettingsScreen', () {
    testWidgets('Navigate to cross-platform screen and back', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Abstract settings screen'));
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
      final platformTile = tester.widget<SettingsTile>(
        find.widgetWithText(SettingsTile, 'Platform'),
      );
      expect((platformTile.value as Text).data, 'Default');

      await goBack(tester);
    });

    testWidgets('Custom theme toggle changes theme', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Abstract settings screen'));
      await pumpSettled(tester);

      // The switch type depends on the platform the app runs on.
      final switchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Enable custom theme'),
        matching: find.byWidgetPredicate(_isSettingsSwitch),
      );
      expect(
        switchFinder,
        findsOneWidget,
        reason: 'Enable custom theme tile should contain a Switch widget',
      );

      expect(_switchValue(tester.widget(switchFinder)), false);
      await tester.tap(switchFinder);
      await pumpSettled(tester);
      expect(_switchValue(tester.widget(switchFinder)), true);
      // Toggle back
      await tester.tap(switchFinder);
      await pumpSettled(tester);
      expect(_switchValue(tester.widget(switchFinder)), false);

      await goBack(tester);
    });

    testWidgets('Platform picker navigates and changes platform', (
      tester,
    ) async {
      app.main();
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Abstract settings screen'));
      await pumpSettled(tester);

      // Open platform picker
      await tester.tap(find.widgetWithText(SettingsTile, 'Platform'));
      await pumpSettled(tester);

      expect(find.text('Platforms'), findsOneWidget);
      expect(find.text('Android'), findsOneWidget);
      expect(find.text('iOS'), findsOneWidget);
      expect(find.text('Web'), findsOneWidget);

      // Select Android
      await tapVisible(tester, find.text('Android'));
      await pumpSettled(tester);

      final androidTile = tester.widget<SettingsTile>(
        find.widgetWithText(SettingsTile, 'Platform'),
      );
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
      await tapVisible(tester, find.text('Web'));
      await pumpSettled(tester);

      final webTile = tester.widget<SettingsTile>(
        find.widgetWithText(SettingsTile, 'Platform'),
      );
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
      await tapVisible(tester, find.text('iOS'));
      await pumpSettled(tester);

      final iosTile = tester.widget<SettingsTile>(
        find.widgetWithText(SettingsTile, 'Platform'),
      );
      expect((iosTile.value as Text).data, 'iOS');

      // iOS uses CupertinoSettingsSwitch
      final iosSwitchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Enable custom theme'),
        matching: find.byType(CupertinoSettingsSwitch),
      );
      expect(iosSwitchFinder, findsOneWidget);
      expect(
        tester.widget<CupertinoSettingsSwitch>(iosSwitchFinder).value,
        false,
      );

      await goBack(tester);
    });
  });

  group('Material 3 Demo Screen', () {
    testWidgets('Renders and seed color changes', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Material 3 Theme Demo'));
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
      await tapVisible(tester, find.text('Purple'));
      await pumpSettled(tester);
      // A checkmark should now appear next to Purple
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tapVisible(tester, find.text('Green'));
      await pumpSettled(tester);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await goBack(tester);
    });

    testWidgets('Dark mode toggle works', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Material 3 Theme Demo'));
      await pumpSettled(tester);

      // The tile shows a Switch on Android, a CupertinoSettingsSwitch on iOS,
      // a MacosSettingsSwitch on macOS, an AdwaitaSettingsSwitch on Linux and
      // a FluentSettingsSwitch on Windows.
      final darkModeSwitchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Dark mode'),
        matching: find.byWidgetPredicate(_isSettingsSwitch),
      );
      bool darkModeValue() => _switchValue(tester.widget(darkModeSwitchFinder));

      expect(darkModeSwitchFinder, findsOneWidget);
      // The demo starts in the app's mode (the system's, here).
      final initial = darkModeValue();

      await tester.tap(darkModeSwitchFinder);
      await pumpSettled(tester);
      expect(darkModeValue(), !initial);

      await tester.tap(darkModeSwitchFinder);
      await pumpSettled(tester);
      expect(darkModeValue(), initial);

      await goBack(tester);
    });

    testWidgets('Notifications and location access tiles visible', (
      tester,
    ) async {
      app.main();
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Material 3 Theme Demo'));
      await pumpSettled(tester);

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Location access'), findsOneWidget);
      // Desktop windows can be short: scroll to the last section.
      await tester.scrollUntilVisible(
        find.text('Compact tiles'),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Compact tiles'), findsOneWidget);

      await goBack(tester);
    });
  });

  group('iOS Developer Screen', () {
    testWidgets('Renders and switch tiles work', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tapVisible(tester, find.text('iOS Developer Screen'));
      await pumpSettled(tester);

      expect(find.text('Developer'), findsOneWidget);
      expect(find.text('Dark Appearance'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      expect(find.text('Enable UI Automation'), findsOneWidget);
      expect(find.text('Fast App Termination'), findsOneWidget);

      // Toggle Dark Appearance
      final darkAppearanceSwitchFinder = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Dark Appearance'),
        matching: find.byType(CupertinoSettingsSwitch),
      );
      expect(darkAppearanceSwitchFinder, findsOneWidget);
      final initial = tester
          .widget<CupertinoSettingsSwitch>(darkAppearanceSwitchFinder)
          .value;

      await tester.tap(darkAppearanceSwitchFinder);
      await pumpSettled(tester);
      expect(
        tester
            .widget<CupertinoSettingsSwitch>(darkAppearanceSwitchFinder)
            .value,
        !initial,
      );

      await goBack(tester);
    });
  });

  group('Android Settings Screen', () {
    testWidgets('Renders settings tiles', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Android Settings Screen'));
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

      await tapVisible(tester, find.text('Android Settings Screen'));
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Network & internet'));
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

      await tapVisible(tester, find.text('Android Settings Screen'));
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Notifications'));
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

      await tapVisible(tester, find.text('Web Settings'));
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

      await tapVisible(tester, find.text('Web Settings'));
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Addresses and more'));
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

      await tapVisible(tester, find.text('iOS Native Settings Screen'));
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

  group('macOS System Settings replica', () {
    testWidgets('Renders the Notifications pane and toggles a switch', (
      tester,
    ) async {
      app.main();
      await pumpSettled(tester);

      await tester.ensureVisible(find.text('macOS System Settings'));
      await tester.pump();
      await tapVisible(tester, find.text('macOS System Settings'));
      await pumpSettled(tester);

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Notification Center'), findsOneWidget);
      expect(find.text('Show previews'), findsOneWidget);
      expect(find.text('Allow notifications'), findsOneWidget);
      // A pop-up row is 37pt tall, as in System Settings.
      expect(
        tester
            .getSize(find.widgetWithText(SettingsTile, 'Show previews'))
            .height,
        37,
      );

      final lockedSwitch = find.descendant(
        of: find.widgetWithText(SettingsTile, 'When the screen is locked'),
        matching: find.byType(MacosSettingsSwitch),
      );
      expect(tester.widget<MacosSettingsSwitch>(lockedSwitch).value, true);
      await tester.tap(lockedSwitch);
      await pumpSettled(tester);
      expect(tester.widget<MacosSettingsSwitch>(lockedSwitch).value, false);

      await goBack(tester);
    });
  });

  group('Android Native Settings Screen', () {
    testWidgets('Renders native settings layout', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tester.ensureVisible(find.text('Android Native Settings Screen'));
      await tester.pump();
      await tapVisible(tester, find.text('Android Native Settings Screen'));
      await pumpSettled(tester);

      expect(find.text('Search Settings'), findsOneWidget);
      expect(find.text('Network & internet'), findsOneWidget);
      expect(find.text('Sound & vibration'), findsOneWidget);

      await goBack(tester);
    });
  });

  group('GNOME Settings (Power) screen', () {
    testWidgets('Renders the Linux style and toggles a switch row', (
      tester,
    ) async {
      app.main();
      await pumpSettled(tester);

      await tapVisible(tester, find.text('GNOME Settings (Power)'));
      await pumpSettled(tester);

      // The General page.
      expect(find.text('Battery Level'), findsOneWidget);
      expect(find.text('Power Mode'), findsOneWidget);
      expect(find.text('Balanced'), findsOneWidget);
      expect(find.byType(AdwaitaPanDownIcon), findsOneWidget);

      // The Power Saving page, from the view switcher.
      await tapVisible(tester, find.text('Power Saving'));
      await pumpSettled(tester);
      expect(find.text('Automatic Suspend'), findsOneWidget);
      expect(find.text('Delay'), findsNWidgets(3));

      final dimScreen = find.descendant(
        of: find.widgetWithText(SettingsTile, 'Dim Screen'),
        matching: find.byType(AdwaitaSettingsSwitch),
      );
      expect(tester.widget<AdwaitaSettingsSwitch>(dimScreen).value, true);
      // Like GNOME, a click anywhere on the row toggles the switch.
      await tapVisible(tester, find.text('Dim Screen'));
      await pumpSettled(tester);
      expect(tester.widget<AdwaitaSettingsSwitch>(dimScreen).value, false);

      await goBack(tester);
    });
  });

  group('Windows Display Settings', () {
    testWidgets('Renders the Windows style and toggles Night light', (
      tester,
    ) async {
      app.main();
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Windows Display Settings'));
      await pumpSettled(tester);

      expect(find.text('Brightness & color'), findsOneWidget);
      expect(find.text('Scale & layout'), findsOneWidget);
      expect(find.text('150% (Recommended)'), findsOneWidget);

      final nightLight = find.byType(FluentSettingsSwitch);
      expect(tester.widget<FluentSettingsSwitch>(nightLight).value, false);
      expect(find.text('Off'), findsOneWidget);
      await tester.tap(nightLight);
      await pumpSettled(tester);
      expect(tester.widget<FluentSettingsSwitch>(nightLight).value, true);
      expect(find.text('On'), findsOneWidget);

      await goBack(tester);
    });
  });

  group('SettingsTile states', () {
    testWidgets('Disabled tile is not interactive', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Abstract settings screen'));
      await pumpSettled(tester);

      // Email tile is disabled
      final emailTile = tester.widget<SettingsTile>(
        find.widgetWithText(SettingsTile, 'Email'),
      );
      expect(emailTile.enabled, false);

      await goBack(tester);
    });
  });

  group('SettingsList scroll controller', () {
    testWidgets(
      'Web settings can scroll via controller (tap triggers scroll)',
      (tester) async {
        app.main();
        await pumpSettled(tester);

        await tapVisible(tester, find.text('Web Settings'));
        await pumpSettled(tester);

        // Tap Passwords tile which animates the scroll controller
        await tapVisible(tester, find.text('Passwords'));
        await pumpSettled(tester);

        // No crash — the scroll animation completed
        expect(find.text('Auto-fill'), findsOneWidget);

        await goBack(tester);
      },
    );
  });

  group('Split view', () {
    testWidgets('Opens the demo, shows a page, and goes back', (tester) async {
      app.main();
      await pumpSettled(tester);

      await tapVisible(tester, find.text('Split view'));
      await pumpSettled(tester);
      expect(find.byType(SettingsSplitView), findsOneWidget);

      // Each style's tree has its own ids (the macOS, GNOME, Windows and
      // Chrome trees have no 'display' page).
      final listContext = tester.element(find.byType(SettingsList).first);
      final controller = SettingsSplitView.of(listContext);
      final id = switch (PlatformUtils.detectPlatform(listContext)) {
        DevicePlatform.macOS || DevicePlatform.linux => 'displays',
        DevicePlatform.windows => 'system',
        DevicePlatform.web => 'appearance',
        _ => 'display',
      };
      controller.select(id);
      await pumpSettled(tester);
      expect(controller.selectedId, id);

      // System back: one pane closes the page first, then the screen.
      if (!controller.isSplit) {
        await tester.binding.handlePopRoute();
        await pumpSettled(tester);
        expect(controller.selectedId, isNull);
      }
      await tester.binding.handlePopRoute();
      await pumpSettled(tester);
      expect(find.text('Split view'), findsOneWidget);
    });
  });
}

/// The switch of a switch tile, in any style.
bool _isSettingsSwitch(Widget widget) =>
    widget is Switch ||
    widget is CupertinoSettingsSwitch ||
    widget is MacosSettingsSwitch ||
    widget is AdwaitaSettingsSwitch ||
    widget is FluentSettingsSwitch;

bool _switchValue(Widget widget) => switch (widget) {
  Switch(:final value) => value,
  CupertinoSettingsSwitch(:final value) => value,
  MacosSettingsSwitch(:final value) => value,
  AdwaitaSettingsSwitch(:final value) => value,
  FluentSettingsSwitch(:final value) => value,
  _ => throw ArgumentError('$widget is not a settings switch'),
};
