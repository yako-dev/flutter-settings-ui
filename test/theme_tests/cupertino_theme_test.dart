import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';

import '../cupertino_app_wrapper.dart';

void main() {
  group('Cupertino theme defaults apply to SettingsList', () {
    const settingsList = SettingsList(
      platform: DevicePlatform.iOS,
      sections: [],
    );
    testWidgets(
        'scaffoldBackgroundColor, Brightness.light',
        (tester) async {
      // Checking that the background color of the SettingsList is the same as
      // the colors specified in the CupertinoThemeData
      // if the backgroundColor in SettingsTheme is not specified.
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

    testWidgets(
        'scaffoldBackgroundColor, Brightness.dark',
        (tester) async {
      // Checking that the background color of the SettingsList is the same as
      // the colors specified in the CupertinoThemeData
      // if the backgroundColor in SettingsTheme is not specified.
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
}
