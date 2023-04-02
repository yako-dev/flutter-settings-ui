import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/utils/cupertino_theme_provider.dart';

import '../cupertino_app_wrapper.dart';

/// This tests only [SettingsSection] theme data
/// Testing [settingsSectionBackground] and [sectionTitleColor]
void main() {
  group('Settings Theme defaults for settingsSectionBackground', () {
    // Checking that the background color of the SettingsSection is the same as
    // the colors specified in the SettingsTheme
    // if the [settingsSectionBackground] in SettingsTheme is not specified.
    final settingsList = SettingsList(
      platform: DevicePlatform.iOS,
      sections: [
        SettingsSection(
          title: const Text('General'),
          tiles: [
            SettingsTile.navigation(
              title: const Text('Section title'),
              leading: const Icon(CupertinoIcons.wrench),
              description:
                  const Text('UI created to show plugin\'s possibilities'),
              onPressed: (context) {},
            )
          ],
        ),
      ],
    );

    testWidgets('Brightness.light', (tester) async {
      await tester.pumpWidget(wrapWithCupertinoApp(
          settingsList, DevicePlatform.iOS, Brightness.light));
      final containerFinder =
          find.byKey(const Key('ios_settings_tile_container'));
      final containerWidget = tester.widget(containerFinder) as Container;
      expect(containerWidget.color,
          CupertinoThemeProvider.sectionBackgroundColors[Brightness.light]);
    });

    testWidgets('Brightness.dark', (tester) async {
      await tester.pumpWidget(wrapWithCupertinoApp(
          settingsList, DevicePlatform.iOS, Brightness.dark));
      final containerFinder =
          find.byKey(const Key('ios_settings_tile_container'));
      final containerWidget = tester.widget(containerFinder) as Container;
      expect(containerWidget.color,
          CupertinoThemeProvider.sectionBackgroundColors[Brightness.dark]);
    });
  });

  group('SettingsTheme specified values applied for SettingsSection', () {
    // Checking that the background color of the SettingsSection is the same as
    // the colors specified in the SettingsTheme
    // The same for [sectionTitleColor]
    final settingsList = SettingsList(
      platform: DevicePlatform.iOS,
      lightTheme: const SettingsThemeData(
        settingsSectionBackground: Colors.yellow,
        sectionTitleColor: Colors.green,
      ),
      darkTheme: const SettingsThemeData(
        settingsSectionBackground: Colors.red,
        sectionTitleColor: Colors.purple,
      ),
      sections: [
        SettingsSection(
          title: const Text('Section title'),
          tiles: [
            SettingsTile.navigation(
              title: const Text('Tile title'),
              leading: const Icon(CupertinoIcons.wrench),
              description: const Text('Tile desciption'),
              onPressed: (context) {},
            )
          ],
        ),
      ],
    );

    testWidgets('Brightness.light', (tester) async {
      // The [settingsSectionBackground] is specified in the [lightTheme]
      await tester.pumpWidget(wrapWithCupertinoApp(
          settingsList, DevicePlatform.iOS, Brightness.light));
      final containerFinder =
          find.byKey(const Key('ios_settings_tile_container'));
      final containerWidget = tester.widget(containerFinder) as Container;
      expect(containerWidget.color, Colors.yellow);

      // The [sectionTitleColor] is specified in the [lightTheme]
      final iosSectionTitleStyleFinder =
          find.byKey(const Key('ios_settings_section_title_style'));
      final defaultTextStyle =
          tester.widget<DefaultTextStyle>(iosSectionTitleStyleFinder);
      expect(defaultTextStyle.style.color, Colors.green);
    });

    testWidgets('Brightness.dark', (tester) async {
      // The [settingsSectionBackground] is specified in the [darkTheme]
      await tester.pumpWidget(wrapWithCupertinoApp(
          settingsList, DevicePlatform.iOS, Brightness.dark));
      final containerFinder =
          find.byKey(const Key('ios_settings_tile_container'));
      final containerWidget = tester.widget(containerFinder) as Container;
      expect(containerWidget.color, Colors.red);

      // The [sectionTitleColor] is specified in the [darkTheme]
      final iosSectionTitleStyleFinder =
          find.byKey(const Key('ios_settings_section_title_style'));
      final defaultTextStyle =
          tester.widget<DefaultTextStyle>(iosSectionTitleStyleFinder);
      expect(defaultTextStyle.style.color, Colors.purple);
    });
  });
}
