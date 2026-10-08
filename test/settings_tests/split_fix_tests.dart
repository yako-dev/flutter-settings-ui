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

Widget _app(Widget home, {TargetPlatform? platform}) => MaterialApp(
  theme: ThemeData(platform: platform),
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
}
