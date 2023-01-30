import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/utils/cupertino_theme_provider.dart';

import '../cupertino_app_wrapper.dart';

void main() {
  group(
      'Cupertino theme defaults apply to SettingsList if useSystemTheme: true',
      () {
    const settingsList = SettingsList(
      platform: DevicePlatform.iOS,
      sections: [],
      useSystemTheme: true,
    );
    testWidgets('CupertinoTheme.of.scaffoldBackgroundColor, Brightness.light',
        (tester) async {
      // Checking that the background color of the SettingsList is the same as
      // the colors specified in the CupertinoThemeData
      // if the backgroundColor in SettingsTheme is not specified.
      // This is due to useSystemTheme = true
      await tester.pumpWidget(wrapWithCupertinoApp(
          settingsList, DevicePlatform.iOS, Brightness.light));
      final settingsListFinder = find.byType(SettingsList);
      expect(settingsListFinder, findsOneWidget);

      final containerFinder = find.descendant(
        of: settingsListFinder,
        matching: find.byType(Container),
      );

      final containerWidget = tester.widget(containerFinder) as Container;
      final BuildContext context = tester.element(find.byType(SettingsList));
      expect(
          containerWidget.color, getCupertinoScaffoldBackgroundColor(context));
    });

    testWidgets('CupertinoTheme.of.scaffoldBackgroundColor, Brightness.dark',
        (tester) async {
      // Checking that the background color of the SettingsList is the same as
      // the colors specified in the CupertinoThemeData
      // if the backgroundColor in SettingsTheme is not specified.
      // This is due to useSystemTheme = true
      await tester.pumpWidget(wrapWithCupertinoApp(
          settingsList, DevicePlatform.iOS, Brightness.dark));
      final settingsListFinder = find.byType(SettingsList);
      expect(settingsListFinder, findsOneWidget);

      final containerFinder = find.descendant(
        of: settingsListFinder,
        matching: find.byType(Container),
      );

      final containerWidget = tester.widget(containerFinder) as Container;
      final BuildContext context = tester.element(find.byType(SettingsList));
      expect(
          containerWidget.color, getCupertinoScaffoldBackgroundColor(context));
    });
  });

  group(
      'Settings theme defaults apply to SettingsList if useSystemTheme: false and SettingsThemeData is not specified',
      () {
    const settingsList = SettingsList(
      platform: DevicePlatform.iOS,
      sections: [],
      useSystemTheme: false,
    );
    testWidgets('SettingsThemeData.backgroundColor, Brightness.light',
        (tester) async {
      // Checking that the background color of the SettingsList is the same as in the [CupertinoThemeProvider]
      // this is due to SettingsThemeData not being specified and useSystemTheme = false
      await tester.pumpWidget(wrapWithCupertinoApp(
          settingsList, DevicePlatform.iOS, Brightness.light));
      final settingsListFinder = find.byType(SettingsList);
      expect(settingsListFinder, findsOneWidget);

      final containerFinder = find.descendant(
        of: settingsListFinder,
        matching: find.byType(Container),
      );

      final containerWidget = tester.widget(containerFinder) as Container;
      expect(containerWidget.color,
          CupertinoThemeProvider.backgroundColors[Brightness.light]);
    });

    testWidgets('SettingsThemeData.backgroundColor, Brightness.dark',
        (tester) async {
      // Checking that the background color of the SettingsList is the same as in the [CupertinoThemeProvider]
      // this is due to SettingsThemeData not being specified and useSystemTheme = false
      await tester.pumpWidget(wrapWithCupertinoApp(
          settingsList, DevicePlatform.iOS, Brightness.dark));
      final settingsListFinder = find.byType(SettingsList);
      expect(settingsListFinder, findsOneWidget);

      final containerFinder = find.descendant(
        of: settingsListFinder,
        matching: find.byType(Container),
      );

      final containerWidget = tester.widget(containerFinder) as Container;
      expect(containerWidget.color,
          CupertinoThemeProvider.backgroundColors[Brightness.dark]);
    });
  });
}
