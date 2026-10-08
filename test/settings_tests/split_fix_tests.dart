import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

TargetPlatform _targetOf(DevicePlatform platform) => switch (platform) {
  DevicePlatform.macOS => TargetPlatform.macOS,
  DevicePlatform.windows => TargetPlatform.windows,
  DevicePlatform.linux => TargetPlatform.linux,
  DevicePlatform.iOS => TargetPlatform.iOS,
  _ => TargetPlatform.android,
};

Widget _app(
  Widget home, {
  TargetPlatform? platform,
  Map<ShortcutActivator, Intent>? shortcuts,
}) => MaterialApp(
  theme: ThemeData(platform: platform),
  shortcuts: shortcuts,
  home: home,
);

final Finder _listPane = find.byKey(const ValueKey('settings_split_list_pane'));

Finder _inList(Finder finder) =>
    find.descendant(of: _listPane, matching: finder);

SettingsSplitController _controllerOf(WidgetTester tester) =>
    SettingsSplitView.of(
      tester.element(
        find
            .descendant(
              of: find.byType(SettingsSplitView),
              matching: find.byType(SettingsTheme),
            )
            .first,
      ),
    );

/// The list pane tile of [title] (a row, or a card with one pane).
Finder _tile(String title) => find.ancestor(
  of: _inList(find.text(title)),
  matching: find.byType(SettingsTile),
);

/// Whether the primary focus is inside [finder]'s widget.
bool _focusIn(Finder finder) {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return false;
  final targets = finder.evaluate().toSet();
  if (targets.contains(context)) return true;
  var found = false;
  context.visitAncestorElements((element) {
    if (targets.contains(element)) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

/// Presses Tab until the focus is in [finder] (at most [max] times).
Future<void> _tabTo(WidgetTester tester, Finder finder, {int max = 12}) async {
  for (var i = 0; i < max && !_focusIn(finder); i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
  }
  expect(_focusIn(finder), isTrue, reason: 'Tab never got to $finder');
}

/// A navigation tile that opens a page showing "[name] body".
SettingsTile _page(String name, {void Function(BuildContext)? onPressed}) =>
    SettingsTile.navigation(
      leading: const Icon(Icons.list),
      title: Text(name),
      onPressed: onPressed,
      destination: SettingsDestination(
        id: name.toLowerCase(),
        builder: (_) => Center(child: Text('$name body')),
      ),
    );

/// A list pane whose "Display" page opens a "Text size" page.
List<AbstractSettingsSection> _nestedSections() => [
  SettingsSection(
    tiles: [
      SettingsTile.navigation(
        leading: const Icon(Icons.brightness_6),
        title: const Text('Display'),
        destination: SettingsDestination(
          id: 'display',
          builder: (_) => SettingsList(
            sections: [
              SettingsSection(tiles: [_page('Text size')]),
            ],
          ),
        ),
      ),
      _page('Sound'),
    ],
  ),
];

/// Tests for the split view, page header and sidebar bugs fixed after 4.0.1.
void splitFixTests() {
  group('macOS sidebar: the arrow keys', () {
    testWidgets('select a page, and only focus a row without one', (
      tester,
    ) async {
      final log = <String>[];
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: DevicePlatform.macOS,
            sections: [
              SettingsSection(
                tiles: [
                  _page('Network'),
                  SettingsTile(
                    title: const Text('Sign out'),
                    onPressed: (_) => log.add('sign out'),
                  ),
                  // The settings_ui 3.x way to open a page.
                  SettingsTile.navigation(
                    title: const Text('About'),
                    onPressed: (_) => log.add('about'),
                  ),
                  SettingsTile.switchTile(
                    title: const Text('Airplane mode'),
                    initialValue: false,
                    onToggle: (value) => log.add('toggled $value'),
                    onPressed: (_) => log.add('airplane'),
                  ),
                  // Without onPressed the switch takes the focus.
                  SettingsTile.switchTile(
                    title: const Text('Bluetooth'),
                    initialValue: false,
                    onToggle: (value) => log.add('bluetooth $value'),
                  ),
                  _page('Sound', onPressed: (_) => log.add('sound')),
                ],
              ),
            ],
          ),
          platform: _targetOf(DevicePlatform.macOS),
        ),
      );
      await tester.pumpAndSettle();
      await _tabTo(tester, _tile('Network'));

      for (final title in ['Sign out', 'About', 'Airplane mode', 'Bluetooth']) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(_focusIn(_tile(title)), isTrue, reason: title);
        expect(log, isEmpty, reason: title);
        expect(_controllerOf(tester).selectedId, 'network', reason: title);
      }

      // A row with a page is selected as before: its onPressed, then the
      // page.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(_focusIn(_tile('Sound')), isTrue);
      expect(log, ['sound']);
      expect(_controllerOf(tester).selectedId, 'sound');
      log.clear();

      // Going back up doesn't run the rows either...
      for (final title in ['Bluetooth', 'Airplane mode', 'About', 'Sign out']) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(_focusIn(_tile(title)), isTrue, reason: title);
        expect(log, isEmpty, reason: title);
      }
      expect(_controllerOf(tester).selectedId, 'sound');

      // ...but Enter, Space and a click do.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      await tester.tap(_inList(find.text('Sign out')));
      await tester.pumpAndSettle();
      expect(log, ['sign out', 'sign out', 'sign out']);
    });
  });

  group('iOS page header: the back button', () {
    Finder back() => find.bySemanticsLabel('Back');

    /// The 3.5pt ring of a Cupertino control with the keyboard focus.
    final focusRing = paints
      ..something((method, arguments) {
        if (method != #drawCircle) return false;
        final paint = arguments[2] as Paint;
        return paint.style == PaintingStyle.stroke && paint.strokeWidth == 3.5;
      });

    Future<void> openPage(WidgetTester tester) async {
      await tester.tap(find.text('Display'));
      await tester.pumpAndSettle();
      expect(find.text('Display body'), findsOneWidget);
    }

    testWidgets('takes the keyboard focus; Enter and Space go back', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: SettingsList(
              platform: DevicePlatform.iOS,
              sections: [
                SettingsSection(tiles: [_page('Display')]),
              ],
            ),
          ),
          platform: TargetPlatform.iOS,
        ),
      );
      await openPage(tester);

      // At rest it is what it was: a button to tap, without a ring.
      expect(
        tester.getSemantics(back()),
        matchesSemantics(label: 'Back', isButton: true, hasTapAction: true),
      );
      expect(back(), isNot(focusRing));

      await _tabTo(tester, back());
      await tester.pumpAndSettle();
      expect(back(), focusRing);
      expect(
        tester.getSemantics(back()),
        matchesSemantics(label: 'Back', isButton: true, hasTapAction: true),
      );

      // The ring is for the keyboard: a touch hides it, a key shows it.
      await tester.tap(find.text('Display body'));
      await tester.pumpAndSettle();
      expect(_focusIn(back()), isTrue);
      expect(back(), isNot(focusRing));
      await tester.sendKeyEvent(LogicalKeyboardKey.shift);
      await tester.pumpAndSettle();
      expect(back(), focusRing);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Display body'), findsNothing);

      await openPage(tester);
      await _tabTo(tester, back());
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(find.text('Display body'), findsNothing);

      // A tap still goes back.
      await openPage(tester);
      await tester.tap(back());
      await tester.pumpAndSettle();
      expect(find.text('Display body'), findsNothing);
      handle.dispose();
    });

    testWidgets('in a split view with one pane too', (tester) async {
      await _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: DevicePlatform.iOS,
            title: const Text('Settings'),
            sections: [
              SettingsSection(tiles: [_page('Display')]),
            ],
          ),
          platform: TargetPlatform.iOS,
        ),
      );
      await tester.pumpAndSettle();
      await openPage(tester);
      expect(_controllerOf(tester).selectedId, 'display');

      await _tabTo(tester, back());
      await tester.pumpAndSettle();
      expect(back(), focusRing);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Display body'), findsNothing);
      expect(_controllerOf(tester).selectedId, isNull);
    });
  });

  group('bar buttons: Enter on the web', () {
    // On the web Enter is ButtonActivateIntent, not ActivateIntent
    // (WidgetsApp.defaultShortcuts).
    final webShortcuts = <ShortcutActivator, Intent>{
      ...WidgetsApp.defaultShortcuts,
      const SingleActivator(LogicalKeyboardKey.enter):
          const ButtonActivateIntent(),
    };

    Future<void> pump(
      WidgetTester tester,
      DevicePlatform platform, {
      Size size = const Size(1280, 800),
    }) async {
      await _setSize(tester, size);
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: platform,
            title: const Text('Settings'),
            sections: _nestedSections(),
          ),
          platform: _targetOf(platform),
          shortcuts: webShortcuts,
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> openNestedPage(WidgetTester tester) async {
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();
      expect(find.text('Text size body'), findsOneWidget);
    }

    for (final (platform, button) in [
      (DevicePlatform.macOS, 'toolbar back button'),
      (DevicePlatform.linux, 'header bar back button'),
    ]) {
      testWidgets('$platform: the $button', (tester) async {
        await pump(tester, platform);
        await openNestedPage(tester);
        await _tabTo(tester, find.bySemanticsLabel('Back'));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.text('Text size body'), findsNothing);
        expect(find.text('Text size'), findsOneWidget);
      });
    }

    testWidgets('Windows: a breadcrumb crumb', (tester) async {
      await pump(tester, DevicePlatform.windows);
      await openNestedPage(tester);
      // "Display" in the page title, "Display > Text size".
      final crumb = find.ancestor(
        of: find.text('Display').last,
        matching: find.bySemanticsLabel('Display'),
      );
      expect(_inList(crumb), findsNothing);
      await _tabTo(tester, crumb);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Text size body'), findsNothing);
      expect(find.text('Text size'), findsOneWidget);
    });

    testWidgets('Windows: the compact rail\'s menu button', (tester) async {
      await pump(tester, DevicePlatform.windows, size: const Size(800, 700));
      // The rail shows the icons only.
      expect(_inList(find.text('Sound')), findsNothing);
      await _tabTo(tester, find.bySemanticsLabel('Open navigation menu'));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(_inList(find.text('Sound')), findsOneWidget);
    });

    testWidgets('Windows: the back button of one pane', (tester) async {
      await pump(tester, DevicePlatform.windows, size: const Size(500, 800));
      await tester.tap(find.text('Sound'));
      await tester.pumpAndSettle();
      expect(find.text('Sound body'), findsOneWidget);
      await _tabTo(tester, find.bySemanticsLabel('Back'));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Sound body'), findsNothing);
    });
  });

  group('custom tiles next to each other are semantics nodes of their '
      'own', () {
    List<AbstractSettingsSection> sections() => [
      SettingsSection(
        title: const Text('Head'),
        tiles: [
          _page('Network'),
          const CustomSettingsTile(child: Text('First custom')),
          const CustomSettingsTile(child: Text('Second custom')),
          const CustomSettingsTile(child: Text('Third custom')),
        ],
      ),
    ];

    /// The labels a screen reader reads, one per node it visits.
    List<String> labelsRead(WidgetTester tester) {
      final labels = <String>[];
      void visit(SemanticsNode node) {
        final label = node.getSemanticsData().label;
        if (!node.isMergedIntoParent && label.isNotEmpty) labels.add(label);
        node.visitChildren((child) {
          visit(child);
          return true;
        });
      }

      visit(
        tester
            .binding
            .renderViews
            .first
            .owner!
            .semanticsOwner!
            .rootSemanticsNode!,
      );
      return labels;
    }

    void expectOwnNodes(WidgetTester tester) {
      expect(
        labelsRead(tester).where((label) => label.contains('custom')),
        unorderedEquals(['First custom', 'Second custom', 'Third custom']),
      );
    }

    for (final platform in [DevicePlatform.iOS, DevicePlatform.web]) {
      testWidgets('$platform: in a list', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: SettingsList(platform: platform, sections: sections()),
            ),
          ),
        );
        expectOwnNodes(tester);
        handle.dispose();
      });
    }

    for (final platform in [
      DevicePlatform.iOS,
      DevicePlatform.macOS,
      DevicePlatform.windows,
      DevicePlatform.linux,
    ]) {
      testWidgets('$platform: in a split view\'s list pane', (tester) async {
        final handle = tester.ensureSemantics();
        await _setSize(tester, const Size(1400, 900));
        await tester.pumpWidget(
          _app(
            SettingsSplitView(platform: platform, sections: sections()),
            platform: _targetOf(platform),
          ),
        );
        await tester.pumpAndSettle();
        expect(_inList(find.text('First custom')), findsOneWidget);
        expectOwnNodes(tester);
        handle.dispose();
      });
    }
  });

  group('Windows compact rail: what an item reads as', () {
    testWidgets('the title\'s semanticsLabel, like in the open pane', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _setSize(tester, const Size(800, 700));
      SettingsDestination page(String id) =>
          SettingsDestination(id: id, builder: (_) => Text('$id body'));
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: DevicePlatform.windows,
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.wifi),
                    title: const Text('Wi-Fi', semanticsLabel: 'Wireless'),
                    destination: page('wifi'),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.bluetooth),
                    title: RichText(
                      text: const TextSpan(
                        text: 'BT',
                        semanticsLabel: 'Bluetooth',
                        style: TextStyle(color: Color(0xFF000000)),
                      ),
                    ),
                    destination: page('bluetooth'),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.volume_up),
                    title: const Text('Sound'),
                    destination: page('sound'),
                  ),
                ],
              ),
            ],
          ),
          platform: TargetPlatform.windows,
        ),
      );
      await tester.pumpAndSettle();
      String labelOf(Finder finder) =>
          tester.getSemantics(_inList(finder)).getSemanticsData().label;

      // The rail shows the icons only.
      expect(_inList(find.text('Wi-Fi')), findsNothing);
      expect(labelOf(find.byIcon(Icons.wifi)), 'Wireless');
      expect(labelOf(find.byIcon(Icons.bluetooth)), 'Bluetooth');
      expect(labelOf(find.byIcon(Icons.volume_up)), 'Sound');
      // The tooltip stands in for the label the open pane draws.
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Tooltip && widget.message == 'Wi-Fi',
        ),
        findsOneWidget,
      );

      // The open pane reads the same.
      await tester.tap(find.bySemanticsLabel('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(labelOf(find.text('Wi-Fi')), 'Wireless');
      expect(labelOf(find.byIcon(Icons.bluetooth)), 'Bluetooth');
      expect(labelOf(find.text('Sound')), 'Sound');
      handle.dispose();
    });
  });

  group('GNOME sidebar: a row\'s enabled state', () {
    List<AbstractSettingsTile> tiles() => [
      _page('Network'),
      SettingsTile(title: const Text('Version')),
      SettingsTile(title: const Text('Locked'), enabled: false),
      SettingsTile(title: const Text('Sign out'), onPressed: (_) {}),
      SettingsTile(
        title: const Text('Managed'),
        enabled: false,
        onPressed: (_) {},
      ),
      SettingsTile.switchTile(
        title: const Text('Wi-Fi'),
        initialValue: true,
        onToggle: (_) {},
      ),
    ];
    const titles = [
      'Network',
      'Version',
      'Locked',
      'Sign out',
      'Managed',
      'Wi-Fi',
    ];

    Map<String, Tristate> enabledStates(WidgetTester tester) => {
      for (final title in titles)
        title: tester
            .getSemantics(find.text(title))
            .getSemanticsData()
            .flagsCollection
            .isEnabled,
    };

    for (final size in [const Size(1280, 800), const Size(400, 800)]) {
      final panes = size.width > 550 ? 'two panes' : 'one pane';
      testWidgets('$panes: none for a row without an action, like a list '
          'row', (tester) async {
        final handle = tester.ensureSemantics();
        await _setSize(tester, size);

        // What the rows of a GNOME list say.
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: SettingsList(
                platform: DevicePlatform.linux,
                sections: [SettingsSection(tiles: tiles())],
              ),
            ),
            platform: TargetPlatform.linux,
          ),
        );
        final inList = enabledStates(tester);
        expect(inList['Version'], Tristate.none);
        expect(inList['Sign out'], Tristate.isTrue);
        expect(inList['Managed'], Tristate.isFalse);

        await tester.pumpWidget(
          _app(
            SettingsSplitView(
              platform: DevicePlatform.linux,
              emptyDetailBuilder: (_) => const SizedBox.expand(),
              sections: [SettingsSection(tiles: tiles())],
            ),
            platform: TargetPlatform.linux,
          ),
        );
        await tester.pumpAndSettle();
        expect(_inList(find.text('Version')), findsOneWidget);
        expect(enabledStates(tester), inList);
        handle.dispose();
      });
    }
  });

  group('sidebar: a disabled switch takes inactiveSwitchColor', () {
    const inactive = Color(0xFF8E24AA);
    const active = Color(0xFF00897B);

    List<AbstractSettingsTile> tiles() => [
      _page('Network'),
      SettingsTile.switchTile(
        title: const Text('Off limits'),
        enabled: false,
        initialValue: true,
        activeSwitchColor: active,
        onToggle: (_) {},
      ),
      SettingsTile.switchTile(
        title: const Text('Wi-Fi'),
        initialValue: true,
        activeSwitchColor: active,
        onToggle: (_) {},
      ),
    ];

    /// The track color the switch of the row [title] is given.
    Color? trackColorOf(WidgetTester tester, String title) {
      final toggle = tester.widget(
        find.descendant(
          of: find.ancestor(
            of: find.text(title),
            matching: find.byType(SettingsTile),
          ),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is MacosSettingsSwitch ||
                widget is AdwaitaSettingsSwitch,
          ),
        ),
      );
      return switch (toggle) {
        MacosSettingsSwitch() => toggle.activeTrackColor,
        AdwaitaSettingsSwitch() => toggle.activeTrackColor,
        _ => null,
      };
    }

    for (final platform in [DevicePlatform.macOS, DevicePlatform.linux]) {
      for (final themed in [true, false]) {
        final what = themed ? 'with the theme color' : 'without one';
        testWidgets('$platform, $what: like in a list', (tester) async {
          const theme = SettingsThemeData(inactiveSwitchColor: inactive);
          await _setSize(tester, const Size(1280, 800));

          // What the switches of a list are given.
          await tester.pumpWidget(
            _app(
              Scaffold(
                body: SettingsList(
                  platform: platform,
                  lightTheme: themed ? theme : null,
                  sections: [SettingsSection(tiles: tiles())],
                ),
              ),
              platform: _targetOf(platform),
            ),
          );
          final inList = {
            for (final title in ['Off limits', 'Wi-Fi'])
              title: trackColorOf(tester, title),
          };
          expect(inList, {
            'Off limits': themed ? inactive : active,
            'Wi-Fi': active,
          });

          await tester.pumpWidget(
            _app(
              SettingsSplitView(
                platform: platform,
                lightTheme: themed ? theme : null,
                sections: [SettingsSection(tiles: tiles())],
              ),
              platform: _targetOf(platform),
            ),
          );
          await tester.pumpAndSettle();
          expect(_inList(find.text('Off limits')), findsOneWidget);
          expect({
            for (final title in ['Off limits', 'Wi-Fi'])
              title: trackColorOf(tester, title),
          }, inList);
        });
      }
    }
  });
}
