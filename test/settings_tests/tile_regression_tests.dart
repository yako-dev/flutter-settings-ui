import 'dart:ui' show Tristate;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart';
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

/// The semantics nodes a screen reader visits (not merged into a parent).
List<SemanticsData> _visibleNodes(WidgetTester tester) {
  final nodes = <SemanticsData>[];
  void visit(SemanticsNode node) {
    if (!node.isMergedIntoParent) nodes.add(node.getSemanticsData());
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return nodes;
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

  group('A switch says what it switches', () {
    for (final platform in _styles) {
      for (final withOnPressed in [false, true]) {
        for (final enabled in [true, false]) {
          final what = [
            withOnPressed ? 'with onPressed' : 'without onPressed',
            if (!enabled) 'disabled',
          ].join(', ');

          testWidgets('$platform: a switch tile $what', (tester) async {
            final handle = tester.ensureSemantics();
            final log = <String>[];
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: SettingsList(
                    platform: platform,
                    sections: [
                      SettingsSection(
                        tiles: [
                          SettingsTile(
                            title: const Text('Before'),
                            value: const Text('Value'),
                          ),
                          SettingsTile.switchTile(
                            title: const Text('Wi-Fi'),
                            enabled: enabled,
                            initialValue: true,
                            onToggle: (v) => log.add('toggled $v'),
                            onPressed: withOnPressed
                                ? (_) => log.add('pressed')
                                : null,
                          ),
                          SettingsTile(
                            title: const Text('After'),
                            onPressed: (_) {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );

            final nodes = _visibleNodes(tester);
            final toggles = nodes.where(
              (node) => node.flagsCollection.isToggled != Tristate.none,
            );
            expect(toggles.map((node) => node.label), ['Wi-Fi']);
            final toggle = toggles.single;
            expect(toggle.hasAction(SemanticsAction.tap), enabled);
            // No other row got merged into the switch.
            expect(toggle.label, isNot(contains('Before')));
            expect(toggle.label, isNot(contains('After')));

            if (enabled) {
              tester.semantics.tap(
                find.semantics.byFlag(SemanticsFlag.hasToggledState),
              );
              await tester.pumpAndSettle();
              expect(log, ['toggled false']);
            }

            // On iOS, macOS and Windows a row with onPressed is a second
            // node, with the same label, that runs onPressed when enabled.
            final separateRow =
                withOnPressed &&
                const [
                  DevicePlatform.iOS,
                  DevicePlatform.macOS,
                  DevicePlatform.windows,
                ].contains(platform);
            final rows = nodes.where(
              (node) =>
                  node.label.contains('Wi-Fi') &&
                  node.flagsCollection.isToggled == Tristate.none,
            );
            expect(rows, hasLength(separateRow ? 1 : 0));
            if (separateRow) {
              expect(rows.single.label, 'Wi-Fi');
              expect(rows.single.hasAction(SemanticsAction.tap), enabled);
            }
            handle.dispose();
          });
        }
      }
    }

    for (final platform in [
      DevicePlatform.iOS,
      DevicePlatform.android,
      DevicePlatform.web,
    ]) {
      testWidgets('$platform: a switch in the list pane of a split view', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1400, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          MaterialApp(
            home: SettingsSplitView(
              platform: platform,
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile.navigation(
                      title: const Text('Page'),
                      destination: SettingsDestination(
                        id: 'page',
                        builder: (_) => const Text('Page body'),
                      ),
                    ),
                    SettingsTile.switchTile(
                      title: const Text('Wi-Fi'),
                      initialValue: true,
                      onToggle: (_) {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        final toggles = _visibleNodes(
          tester,
        ).where((node) => node.flagsCollection.isToggled != Tristate.none);
        expect(toggles.map((node) => node.label), ['Wi-Fi']);
        handle.dispose();
      });
    }
  });

  group('A disabled row with onPressed is a disabled button', () {
    for (final platform in [
      DevicePlatform.macOS,
      DevicePlatform.windows,
      DevicePlatform.linux,
    ]) {
      testWidgets('$platform', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsList(
                platform: platform,
                sections: [
                  SettingsSection(
                    tiles: [
                      SettingsTile.navigation(
                        title: const Text('Keyboard'),
                        enabled: false,
                        onPressed: (_) {},
                      ),
                      SettingsTile(
                        title: const Text('Model'),
                        value: const Text('Mac'),
                        enabled: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(
          tester.getSemantics(find.text('Keyboard')),
          isSemantics(
            label: 'Keyboard',
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
            hasTapAction: false,
          ),
        );
        // A row that does nothing is no button, enabled or not.
        expect(
          tester
              .getSemantics(find.text('Model'))
              .getSemanticsData()
              .flagsCollection
              .isButton,
          isFalse,
        );
        handle.dispose();
      });
    }
  });

  group('Desktop cards host Material widgets and style custom tiles', () {
    const desktopStyles = [
      DevicePlatform.macOS,
      DevicePlatform.windows,
      DevicePlatform.linux,
    ];

    List<AbstractSettingsSection> sections() => [
      SettingsSection(
        tiles: [
          CustomSettingsTile(
            child: ListTile(title: const Text('List tile'), onTap: () {}),
          ),
          SettingsTile(
            title: const Text('Tile'),
            leading: Checkbox(value: true, onChanged: (_) {}),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {},
            ),
          ),
        ],
      ),
    ];

    for (final platform in desktopStyles) {
      testWidgets('$platform: without a Scaffold in a MaterialApp', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SettingsList(platform: platform, sections: sections()),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(Checkbox), findsOneWidget);
      });

      testWidgets('$platform: in a CupertinoApp', (tester) async {
        await tester.pumpWidget(
          CupertinoApp(
            home: SettingsList(platform: platform, sections: sections()),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(ListTile), findsOneWidget);
      });

      for (final forced in Brightness.values) {
        testWidgets('$platform: custom tile text takes the tile text color '
            'in a list forced to $forced', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: _other(forced)),
              home: Scaffold(
                body: SettingsList(
                  platform: platform,
                  brightness: forced,
                  sections: [
                    SettingsSection(
                      tiles: [
                        SettingsTile(title: const Text('Title')),
                        CustomSettingsTile(child: const Text('Custom')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
          Color colorOf(String text) => tester
              .renderObject<RenderParagraph>(find.text(text))
              .text
              .style!
              .color!;
          expect(colorOf('Custom'), colorOf('Title'));
        });
      }
    }
  });

  group('GNOME rows', () {
    Future<void> pumpRows(WidgetTester tester, List<String> log) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsList(
              platform: DevicePlatform.linux,
              sections: [
                SettingsSection(
                  tiles: [
                    for (var i = 0; i < 30; i++)
                      SettingsTile.navigation(
                        title: Text('Row $i'),
                        onPressed: (_) => log.add('Row $i'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    double pressedAlpha(WidgetTester tester, String row) {
      final decoration =
          tester
                  .widget<AnimatedContainer>(
                    find.ancestor(
                      of: find.text(row),
                      matching: find.byType(AnimatedContainer),
                    ),
                  )
                  .decoration!
              as BoxDecoration;
      return decoration.color!.a;
    }

    testWidgets('a row lets go of its pressed fill when a scroll starts on '
        'it', (tester) async {
      final log = <String>[];
      await pumpRows(tester, log);
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Row 3')),
      );
      await tester.pump(const Duration(milliseconds: 20));
      expect(pressedAlpha(tester, 'Row 3'), greaterThan(0));

      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(const Offset(0, -15));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.getCenter(find.text('Row 3')).dy, lessThan(200));
      await tester.pumpAndSettle();
      expect(pressedAlpha(tester, 'Row 3'), 0);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(log, isEmpty);
    });

    testWidgets('a mouse press stays pressed inside the row and lets go '
        'outside it', (tester) async {
      final log = <String>[];
      await pumpRows(tester, log);
      final row = tester.getRect(
        find
            .ancestor(
              of: find.text('Row 1'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final gesture = await tester.startGesture(
        row.center,
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(10, 5));
      await tester.pumpAndSettle();
      expect(pressedAlpha(tester, 'Row 1'), greaterThan(0));

      await gesture.moveTo(row.bottomCenter + const Offset(0, 20));
      await tester.pumpAndSettle();
      expect(pressedAlpha(tester, 'Row 1'), 0);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a tap still presses and activates the row', (tester) async {
      final log = <String>[];
      await pumpRows(tester, log);
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Row 2')),
      );
      await gesture.moveBy(const Offset(0, 4));
      await tester.pumpAndSettle();
      expect(pressedAlpha(tester, 'Row 2'), greaterThan(0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(pressedAlpha(tester, 'Row 2'), 0);
      expect(log, ['Row 2']);
    });
  });
}
