import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/utils/fluent_tokens.dart';

/// Regression tests for the tile, switch and theme bugs found in the final
/// QA of the 4.0.0 release candidate.

const _styles = [
  DevicePlatform.iOS,
  DevicePlatform.android,
  DevicePlatform.web,
  DevicePlatform.macOS,
  DevicePlatform.windows,
  DevicePlatform.linux,
];

Brightness _other(Brightness brightness) =>
    brightness == Brightness.dark ? Brightness.light : Brightness.dark;

/// The brightness a switch of [platform] draws with.
Brightness _switchBrightness(WidgetTester tester, DevicePlatform platform) {
  switch (platform) {
    case DevicePlatform.android:
    case DevicePlatform.fuchsia:
    case DevicePlatform.web:
      return Theme.of(
        tester.element(find.byType(Switch)),
      ).colorScheme.brightness;
    case DevicePlatform.iOS:
      return CupertinoTheme.brightnessOf(
        tester.element(find.byType(CupertinoSettingsSwitch)),
      );
    case DevicePlatform.macOS:
      return CupertinoTheme.brightnessOf(
        tester.element(find.byType(MacosSettingsSwitch)),
      );
    case DevicePlatform.windows:
      return FluentTokens.brightnessOf(
        tester.element(find.byType(FluentSettingsSwitch)),
      );
    case DevicePlatform.linux:
      return tester
          .widget<AdwaitaSettingsSwitch>(find.byType(AdwaitaSettingsSwitch))
          .brightness!;
    case DevicePlatform.device:
      throw ArgumentError(platform);
  }
}

void tileRegressionTests() {
  group('SettingsList.brightness forces the colors in every style', () {
    for (final platform in _styles) {
      for (final forced in Brightness.values) {
        final app = _other(forced);

        testWidgets('$platform: $forced in a $app app', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: app),
              home: Scaffold(
                body: SettingsList(
                  platform: platform,
                  brightness: forced,
                  sections: [
                    SettingsSection(
                      title: const Text('Section'),
                      tiles: [
                        SettingsTile(title: const Text('Title')),
                        SettingsTile.switchTile(
                          title: const Text('Switch'),
                          initialValue: false,
                          onToggle: (_) {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );

          final theme = SettingsTheme.of(
            tester.element(find.text('Title')),
          ).themeData;
          expect(
            ThemeData.estimateBrightnessForColor(theme.settingsListBackground!),
            forced,
            reason: 'page ${theme.settingsListBackground}',
          );
          final title = tester
              .renderObject<RenderParagraph>(find.text('Title'))
              .text
              .style!
              .color!;
          expect(
            ThemeData.estimateBrightnessForColor(title),
            // Light text on a dark list, and the other way round.
            app,
            reason: 'title $title',
          );
          expect(_switchBrightness(tester, platform), forced);
        });
      }
    }

    for (final platform in [DevicePlatform.android, DevicePlatform.web]) {
      testWidgets('$platform: the forced colors come from the app primary '
          'color', (tester) async {
        final appScheme = ColorScheme.fromSeed(seedColor: Colors.green);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(colorScheme: appScheme),
            home: Scaffold(
              body: SettingsList(
                platform: platform,
                brightness: Brightness.dark,
                sections: [
                  SettingsSection(
                    tiles: [SettingsTile(title: const Text('Title'))],
                  ),
                ],
              ),
            ),
          ),
        );

        final expected = ColorScheme.fromSeed(
          seedColor: appScheme.primary,
          brightness: Brightness.dark,
        );
        final tileTheme = Theme.of(tester.element(find.text('Title')));
        expect(tileTheme.colorScheme, expected);
        expect(
          SettingsTheme.of(
            tester.element(find.text('Title')),
          ).themeData.settingsTileTextColor,
          expected.onSurface,
        );
      });

      testWidgets('$platform: a list that is not forced keeps the app theme', (
        tester,
      ) async {
        final appTheme = ThemeData(brightness: Brightness.dark);
        await tester.pumpWidget(
          MaterialApp(
            theme: appTheme,
            home: Scaffold(
              body: SettingsList(
                platform: platform,
                brightness: Brightness.dark,
                sections: [
                  SettingsSection(
                    tiles: [
                      SettingsTile.switchTile(
                        title: const Text('Switch'),
                        initialValue: true,
                        onToggle: (_) {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(
          find.descendant(
            of: find.byType(SettingsList),
            matching: find.byType(Theme),
          ),
          findsNothing,
        );
        expect(
          Theme.of(tester.element(find.byType(Switch))).colorScheme,
          appTheme.colorScheme,
        );
      });
    }
  });
}
