import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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

/// A list whose tiles are enabled while [enabled] is true, logging what
/// they do to [log].
Widget _togglableList(
  DevicePlatform platform,
  ValueNotifier<bool> enabled,
  List<String> log,
) {
  return MaterialApp(
    home: Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: enabled,
        builder: (context, on, _) => SettingsList(
          platform: platform,
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile.navigation(
                  title: const Text('Nav'),
                  enabled: on,
                  onPressed: (_) => log.add('pressed'),
                ),
                SettingsTile.switchTile(
                  title: const Text('Wi-Fi'),
                  enabled: on,
                  initialValue: false,
                  onToggle: (v) => log.add('toggled $v'),
                  onPressed: (_) => log.add('switch row pressed'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Tabs through everything focusable, pressing Enter and Space on each.
Future<void> _pressEverythingFromTheKeyboard(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
  }
}

void tileRegressionTests() {
  group('A disabled tile is inert', () {
    for (final platform in _styles) {
      testWidgets('$platform: Tab, Enter and Space do nothing', (tester) async {
        final log = <String>[];
        final enabled = ValueNotifier(false);
        addTearDown(enabled.dispose);
        await tester.pumpWidget(_togglableList(platform, enabled, log));

        await _pressEverythingFromTheKeyboard(tester);
        expect(log, isEmpty);
      });

      testWidgets('$platform: a press that started before the tile was '
          'disabled does not fire', (tester) async {
        final log = <String>[];
        final enabled = ValueNotifier(true);
        addTearDown(enabled.dispose);
        await tester.pumpWidget(_togglableList(platform, enabled, log));

        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Nav')),
        );
        await tester.pump(const Duration(milliseconds: 200));
        enabled.value = false;
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();
        expect(log, isEmpty);
        expect(tester.takeException(), isNull);
      });
    }

    for (final platform in [
      DevicePlatform.iOS,
      DevicePlatform.android,
      DevicePlatform.web,
    ]) {
      testWidgets('$platform: an enabled tile still works from the keyboard', (
        tester,
      ) async {
        final log = <String>[];
        final enabled = ValueNotifier(true);
        addTearDown(enabled.dispose);
        await tester.pumpWidget(_togglableList(platform, enabled, log));

        await _pressEverythingFromTheKeyboard(tester);
        expect(log, contains('toggled true'));
        if (platform != DevicePlatform.iOS) {
          // iOS rows are not focusable; only their switches are.
          expect(log, contains('pressed'));
        }
      });

      testWidgets('$platform: a list pane row of a split view is inert when '
          'disabled', (tester) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final log = <String>[];
        await tester.pumpWidget(
          MaterialApp(
            home: SettingsSplitView(
              platform: platform,
              sections: [
                SettingsSection(
                  tiles: [
                    // The first page shows in the detail pane from the start.
                    SettingsTile.navigation(
                      title: const Text('On'),
                      destination: SettingsDestination(
                        id: 'on',
                        builder: (_) => const Text('On page'),
                      ),
                    ),
                    SettingsTile.navigation(
                      title: const Text('Off'),
                      enabled: false,
                      onPressed: (_) => log.add('pressed'),
                      destination: SettingsDestination(
                        id: 'off',
                        builder: (_) => const Text('Off page'),
                      ),
                    ),
                    SettingsTile.switchTile(
                      title: const Text('Wi-Fi'),
                      enabled: false,
                      initialValue: false,
                      onToggle: (v) => log.add('toggled $v'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('On page'), findsOneWidget);

        await _pressEverythingFromTheKeyboard(tester);
        expect(log, isEmpty);
        expect(find.text('Off page'), findsNothing);
      });
    }
  });

  group('iOS rows expose a tap action only when they react to taps', () {
    Future<SemanticsData> semanticsOf(
      WidgetTester tester,
      SettingsTile tile,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsList(
              platform: DevicePlatform.iOS,
              sections: [
                SettingsSection(tiles: [tile]),
              ],
            ),
          ),
        ),
      );
      return tester.getSemantics(find.text('Model')).getSemanticsData();
    }

    testWidgets('a value row without onPressed has none', (tester) async {
      final handle = tester.ensureSemantics();
      final data = await semanticsOf(
        tester,
        SettingsTile(title: const Text('Model'), value: const Text('iPhone')),
      );
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      handle.dispose();
    });

    testWidgets('a row with onPressed has one', (tester) async {
      final handle = tester.ensureSemantics();
      final data = await semanticsOf(
        tester,
        SettingsTile(title: const Text('Model'), onPressed: (_) {}),
      );
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('a disabled row with onPressed has none', (tester) async {
      final handle = tester.ensureSemantics();
      final data = await semanticsOf(
        tester,
        SettingsTile(
          title: const Text('Model'),
          enabled: false,
          onPressed: (_) {},
        ),
      );
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      handle.dispose();
    });

    testWidgets('a tap leaves no timer behind', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsList(
              platform: DevicePlatform.iOS,
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile(
                      title: const Text('Model'),
                      onPressed: (_) => presses++,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Model'));
      // The test fails with "A Timer is still pending" if the tile keeps
      // one after it is gone.
      await tester.pumpWidget(const SizedBox());
      expect(presses, 1);
    });
  });

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
