import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/sections/platforms/android_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/ios_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/web_settings_section.dart';
import 'package:settings_ui/src/tiles/platforms/android_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/ios_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/web_settings_tile.dart';

void main() {
  group('Android tile tests', () {
    bool isPressed = false;
    final settingsTile = SettingsTile(
      onPressed: (context) {
        isPressed = true;
      },
      title: Text('Network & internet'),
      description: Text('Mobile, Wi-Fi, hotspot'),
      leading: Icon(Icons.wifi),
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

      expect(titleWidget.style.color, Color(0xff1b1b1b));
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

      expect(descriptionWidget.style.color, Color(0xff464646));
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

      expect(iconWidget.data.color, Color(0xff464646));
    });

    testWidgets('Settings Tile onPressed is called', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.android,
      ));
      await tester.tap(find.byType(AndroidSettingsTile));

      expect(isPressed, true);
    });

    testWidgets('Settings Tile onToggle is called', (tester) async {
      bool onToggleValue = false;
      final onToggleTile = SettingsTile.switchTile(
        initialValue: onToggleValue,
        onToggle: (value) {
          onToggleValue = value;
        },
        title: Text('Notification dot on app icon'),
      );

      await tester.pumpWidget(_wrapWithMaterialApp(
        onToggleTile,
        DevicePlatform.android,
      ));

      final switcherFinder = find.descendant(
        of: find.byType(AndroidSettingsTile),
        matching: find.byType(Switch),
      );

      await tester.tap(switcherFinder);
      expect(onToggleValue, true);
    });
  });

  group('IOS tile tests', () {
    bool isPressed = false;
    final settingsTile = SettingsTile.navigation(
      onPressed: (_) {
        isPressed = true;
      },
      title: Text('View'),
      value: Text('Standard'),
      description: Text('Choose a view for iPhone'),
    );

    testWidgets('Widget should render correctly', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.iOS,
      ));
      expect(find.byType(IOSSettingsSection), findsOneWidget);
      expect(find.byType(IOSSettingsTile), findsOneWidget);
    });

    testWidgets('Title content should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.iOS,
      ));
      expect(find.text('View'), findsOneWidget);
    });

    testWidgets('Title style should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.iOS,
      ));

      final defaultTextFinder = find.ancestor(
          of: find.text('View'), matching: find.byType(DefaultTextStyle));

      final DefaultTextStyle titleWidget =
          tester.firstWidget(defaultTextFinder);

      expect(titleWidget.style.color, Colors.black);
      expect(titleWidget.style.fontSize, 16);
      expect(titleWidget.style.fontWeight, null);
    });

    testWidgets('Description content should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.iOS,
      ));

      expect(find.text('Choose a view for iPhone'), findsOneWidget);
    });

    testWidgets('Description style should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.iOS,
      ));

      final defaultTextFinder = find.ancestor(
          of: find.text('Choose a view for iPhone'),
          matching: find.byType(DefaultTextStyle));

      final DefaultTextStyle descriptionWidget =
          tester.firstWidget(defaultTextFinder);

      expect(descriptionWidget.style.color, Color(0xff6d6d72));
      expect(descriptionWidget.style.fontSize, 13);
      expect(descriptionWidget.style.fontWeight, null);
    });

    testWidgets('Tile icon should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.iOS,
      ));

      expect(find.byIcon(CupertinoIcons.chevron_forward), findsOneWidget);
    });

    testWidgets('Settings Tile onPressed is called', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_wrapWithMaterialApp(
          settingsTile,
          DevicePlatform.iOS,
        ));
        await tester.tap(find.byType(IOSSettingsTile));

        expect(isPressed, true);
      });
    });

    testWidgets('Settings Tile onToggle is called', (tester) async {
      bool onToggleValue = false;
      final onToggleTile = SettingsTile.switchTile(
        initialValue: onToggleValue,
        onToggle: (value) {
          onToggleValue = value;
        },
        title: Text('Dark Appearance'),
      );

      await tester.pumpWidget(_wrapWithMaterialApp(
        onToggleTile,
        DevicePlatform.iOS,
      ));

      final switcherFinder = find.descendant(
        of: find.byType(IOSSettingsTile),
        matching: find.byType(CupertinoSwitch),
      );

      await tester.tap(switcherFinder);
      expect(onToggleValue, true);
    });
  });

  group('Web tile tests', () {
    bool isPressed = false;
    final settingsTile = SettingsTile.navigation(
      onPressed: (_) {
        isPressed = true;
      },
      leading: Icon(Icons.web),
      title: Text('Cookies and other site data'),
      description: Text('Third-party cookies are blocked in Incognito mode'),
    );

    testWidgets('Widget should render correctly', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.web,
      ));
      expect(find.byType(WebSettingsSection), findsOneWidget);
      expect(find.byType(WebSettingsTile), findsOneWidget);
    });

    testWidgets('Title content should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.web,
      ));
      expect(find.text('Cookies and other site data'), findsOneWidget);
    });

    testWidgets('Title style should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.web,
      ));

      final defaultTextFinder = find.ancestor(
        of: find.text('Cookies and other site data'),
        matching: find.byType(DefaultTextStyle),
      );

      final DefaultTextStyle titleWidget =
          tester.firstWidget(defaultTextFinder);

      expect(titleWidget.style.color, Color(0xff1b1b1b));
      expect(titleWidget.style.fontSize, 18);
      expect(titleWidget.style.fontWeight, FontWeight.w400);
    });

    testWidgets('Description content should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.web,
      ));

      expect(
        find.text('Third-party cookies are blocked in Incognito mode'),
        findsOneWidget,
      );
    });

    testWidgets('Description style should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.web,
      ));

      final defaultTextFinder = find.ancestor(
          of: find.text('Third-party cookies are blocked in Incognito mode'),
          matching: find.byType(DefaultTextStyle));

      final DefaultTextStyle descriptionWidget =
          tester.firstWidget(defaultTextFinder);

      expect(descriptionWidget.style.color, Color(0xff464646));
      expect(descriptionWidget.style.fontSize, null);
      expect(descriptionWidget.style.fontWeight, null);
    });

    testWidgets('Leading icon should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.web,
      ));

      expect(find.byIcon(Icons.web), findsOneWidget);
    });

    testWidgets('Leading icon color should match', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.web,
      ));

      final iconThemeFinder = find.ancestor(
        of: find.byIcon(Icons.web),
        matching: find.byType(IconTheme),
      );

      final IconTheme iconWidget = tester.firstWidget(iconThemeFinder);

      expect(iconWidget.data.color, Color(0xff464646));
    });

    testWidgets('Settings Tile onPressed is called', (tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(
        settingsTile,
        DevicePlatform.web,
      ));
      await tester.tap(find.byType(WebSettingsTile));

      expect(isPressed, true);
    });

    testWidgets('Settings Tile onToggle is called', (tester) async {
      bool onToggleValue = false;
      final onToggleTile = SettingsTile.switchTile(
        initialValue: onToggleValue,
        onToggle: (value) {
          onToggleValue = value;
        },
        title: Text('Dark Appearance'),
      );

      await tester.pumpWidget(_wrapWithMaterialApp(
        onToggleTile,
        DevicePlatform.web,
      ));

      final switcherFinder = find.descendant(
        of: find.byType(WebSettingsTile),
        matching: find.byType(Switch),
      );

      await tester.tap(switcherFinder);
      expect(onToggleValue, true);
    });
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
