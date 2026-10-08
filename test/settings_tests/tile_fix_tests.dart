import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Tests for the tile and switch bugs fixed after 4.0.1.

typedef _SwitchBuilder =
    Widget Function(bool value, ValueChanged<bool> onChanged);

/// The four painted switches.
final Map<String, _SwitchBuilder> _paintedSwitches = {
  'CupertinoSettingsSwitch': (value, onChanged) =>
      CupertinoSettingsSwitch(value: value, onChanged: onChanged),
  'MacosSettingsSwitch': (value, onChanged) =>
      MacosSettingsSwitch(value: value, onChanged: onChanged),
  'FluentSettingsSwitch': (value, onChanged) =>
      FluentSettingsSwitch(value: value, onChanged: onChanged),
  'AdwaitaSettingsSwitch': (value, onChanged) =>
      AdwaitaSettingsSwitch(value: value, onChanged: onChanged),
};

const _switchKey = ValueKey<String>('switch');

/// A switch that keeps the value it is given and stays in the tree while
/// [shown] is true.
Widget _removableSwitch(_SwitchBuilder builder, ValueNotifier<bool> shown) {
  var value = false;
  return MaterialApp(
    home: Center(
      child: ValueListenableBuilder<bool>(
        valueListenable: shown,
        builder: (context, isShown, _) => isShown
            ? StatefulBuilder(
                builder: (context, setState) => KeyedSubtree(
                  key: _switchKey,
                  child: builder(value, (v) => setState(() => value = v)),
                ),
              )
            : const SizedBox.shrink(),
      ),
    ),
  );
}

/// A list whose second tile, 'Goes', stays in the tree while [shown] is
/// true.
Widget _listWithRemovableTile(
  DevicePlatform platform,
  ValueNotifier<bool> shown,
) {
  return MaterialApp(
    home: Scaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: shown,
        builder: (context, isShown, _) => SettingsList(
          platform: platform,
          sections: [
            SettingsSection(
              tiles: [
                SettingsTile(title: const Text('Stays'), onPressed: (_) {}),
                if (isShown)
                  SettingsTile(title: const Text('Goes'), onPressed: (_) {}),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// A split view whose second sidebar row, 'Goes', stays in the tree while
/// [shown] is true.
Widget _splitViewWithRemovableRow(
  DevicePlatform platform,
  ValueNotifier<bool> shown,
) {
  SettingsTile row(String name) => SettingsTile.navigation(
    title: Text(name),
    destination: SettingsDestination(
      id: name,
      builder: (_) => Text('$name page'),
    ),
  );
  return MaterialApp(
    home: ValueListenableBuilder<bool>(
      valueListenable: shown,
      builder: (context, isShown, _) => SettingsSplitView(
        platform: platform,
        sections: [
          SettingsSection(tiles: [row('Stays'), if (isShown) row('Goes')]),
        ],
      ),
    ),
  );
}

/// Presses 'Goes' with a pointer of [kind], removes it after [hold], then
/// moves the pointer and lifts it.
Future<void> _removeWhilePressed(
  WidgetTester tester,
  ValueNotifier<bool> shown,
  PointerDeviceKind kind,
  Duration hold,
) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.text('Goes')),
    kind: kind,
  );
  await tester.pump(hold);
  shown.value = false;
  await tester.pump();
  expect(find.text('Goes'), findsNothing);

  await gesture.moveBy(const Offset(4, 2));
  await tester.pump();
  await gesture.moveBy(const Offset(0, 300));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void tileFixTests() {
  group('A row removed while it is pressed throws nothing', () {
    // A tap is recognized as down 100 ms after the pointer: the row goes
    // away before that, and after it.
    const holds = {
      'at once': Duration.zero,
      'after 200 ms': Duration(milliseconds: 200),
    };
    for (final platform in [DevicePlatform.windows, DevicePlatform.linux]) {
      for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
        for (final MapEntry(key: moment, value: hold) in holds.entries) {
          testWidgets('$platform: a tile with onPressed, pressed by a $kind '
              'and removed $moment', (tester) async {
            final shown = ValueNotifier(true);
            addTearDown(shown.dispose);
            await tester.pumpWidget(_listWithRemovableTile(platform, shown));

            await _removeWhilePressed(tester, shown, kind, hold);
          });

          testWidgets('$platform: a sidebar row of a split view, pressed by '
              'a $kind and removed $moment', (tester) async {
            tester.view.physicalSize = const Size(1400, 900);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            final shown = ValueNotifier(true);
            addTearDown(shown.dispose);
            await tester.pumpWidget(
              _splitViewWithRemovableRow(platform, shown),
            );
            await tester.pumpAndSettle();
            expect(find.text('Stays page'), findsOneWidget);

            await _removeWhilePressed(tester, shown, kind, hold);
          });
        }
      }
    }
  });

  group('MacosSettingsSwitch centers its track in a larger box', () {
    const trackColor = Color(0xFF112233);
    const knobColor = Color(0xFFFFFFFF);
    // The track and the knob of each size, as its docs give them.
    const sizes = {
      MacosSettingsSwitchSize.regular: (
        track: Size(36, 16),
        knob: Size(21, 13),
      ),
      MacosSettingsSwitchSize.large: (track: Size(44, 20), knob: Size(26, 16)),
    };

    RRect capsule(Rect rect) =>
        RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));

    Widget app(TextDirection direction, Widget child) => MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Center(child: child),
      ),
    );

    for (final MapEntry(key: size, value: metrics) in sizes.entries) {
      // The gap between the knob and the edge of the track.
      final inset = (metrics.track.height - metrics.knob.height) / 2;

      // What an OFF switch paints when its track is at [track], before a
      // right-to-left layout mirrors it: the track, then the knob's shadow
      // and the knob at the start of the track.
      PaintPattern offSwitchAt(Rect track) => paints
        ..rrect(rrect: capsule(track), color: trackColor)
        ..rrect()
        ..rrect(
          rrect: capsule((track.topLeft + Offset(inset, inset)) & metrics.knob),
          color: knobColor,
        );

      for (final direction in TextDirection.values) {
        testWidgets('$size, $direction: in an 80x40 box', (tester) async {
          await tester.pumpWidget(
            app(
              direction,
              SizedBox(
                width: 80,
                height: 40,
                child: MacosSettingsSwitch(
                  value: false,
                  onChanged: (_) {},
                  size: size,
                  inactiveTrackColor: trackColor,
                ),
              ),
            ),
          );
          final switchFinder = find.byType(MacosSettingsSwitch);
          expect(tester.getSize(switchFinder), const Size(80, 40));

          final track = Rect.fromCenter(
            center: const Offset(40, 20),
            width: metrics.track.width,
            height: metrics.track.height,
          );
          expect(switchFinder, offSwitchAt(track));
          if (direction == TextDirection.rtl) {
            // Mirrored around the middle of the box, so the track stays in
            // the middle and the knob of an OFF switch is at its right end.
            expect(
              switchFinder,
              paints
                ..translate(x: 80.0, y: 0.0)
                ..scale(x: -1.0, y: 1.0)
                ..rrect(rrect: capsule(track), color: trackColor),
            );
          }
        });

        testWidgets('$size, $direction: at its own size the track fills the '
            'box', (tester) async {
          await tester.pumpWidget(
            app(
              direction,
              MacosSettingsSwitch(
                value: false,
                onChanged: (_) {},
                size: size,
                inactiveTrackColor: trackColor,
              ),
            ),
          );
          final switchFinder = find.byType(MacosSettingsSwitch);
          expect(tester.getSize(switchFinder), metrics.track);
          expect(switchFinder, offSwitchAt(Offset.zero & metrics.track));
        });
      }
    }
  });

  group('AdwaitaSettingsSwitch diagnostics', () {
    List<DiagnosticsNode> propertiesOf(AdwaitaSettingsSwitch widget) {
      final builder = DiagnosticPropertiesBuilder();
      widget.debugFillProperties(builder);
      return builder.properties;
    }

    test('list focusNode and autofocus', () {
      final focusNode = FocusNode(debugLabel: 'switch');
      addTearDown(focusNode.dispose);
      final properties = propertiesOf(
        AdwaitaSettingsSwitch(
          value: true,
          onChanged: (_) {},
          focusNode: focusNode,
          autofocus: true,
        ),
      );

      final byName = {for (final p in properties) p.name: p};
      expect(byName.keys, containsAll(<String>['focusNode', 'autofocus']));
      expect(byName['focusNode']!.value, same(focusNode));
      expect(byName['autofocus']!.value, isTrue);
      for (final name in ['focusNode', 'autofocus']) {
        expect(
          byName[name]!.isFiltered(DiagnosticLevel.info),
          isFalse,
          reason: '$name is set, so it shows',
        );
      }
    });

    test('print neither for a switch that sets neither', () {
      final shown = propertiesOf(
        AdwaitaSettingsSwitch(value: true, onChanged: (_) {}),
      ).where((p) => !p.isFiltered(DiagnosticLevel.info)).map((p) => p.name);

      expect(shown, isNot(contains('focusNode')));
      expect(shown, isNot(contains('autofocus')));
      // What it printed before stays.
      expect(
        shown,
        containsAll(<String>[
          'value',
          'activeTrackColor',
          'inactiveTrackColor',
          'brightness',
        ]),
      );
    });
  });

  group('A switch removed in the middle of a gesture throws nothing', () {
    for (final MapEntry(key: name, value: builder)
        in _paintedSwitches.entries) {
      for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
        testWidgets('$name: removed while a $kind holds it, then the pointer '
            'goes up', (tester) async {
          final shown = ValueNotifier(true);
          addTearDown(shown.dispose);
          await tester.pumpWidget(_removableSwitch(builder, shown));

          final gesture = await tester.startGesture(
            tester.getCenter(find.byKey(_switchKey)),
            kind: kind,
          );
          await tester.pump(const Duration(milliseconds: 200));
          shown.value = false;
          await tester.pump();
          expect(find.byKey(_switchKey), findsNothing);

          await gesture.up();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });

        testWidgets('$name: removed while a $kind holds it, then the pointer '
            'moves away', (tester) async {
          final shown = ValueNotifier(true);
          addTearDown(shown.dispose);
          await tester.pumpWidget(_removableSwitch(builder, shown));

          final gesture = await tester.startGesture(
            tester.getCenter(find.byKey(_switchKey)),
            kind: kind,
          );
          await tester.pump(const Duration(milliseconds: 200));
          shown.value = false;
          await tester.pump();

          await gesture.moveBy(const Offset(0, 60));
          await tester.pump();
          await gesture.up();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });

        testWidgets('$name: removed while a $kind drags it, then the pointer '
            'moves and goes up', (tester) async {
          final shown = ValueNotifier(true);
          addTearDown(shown.dispose);
          await tester.pumpWidget(_removableSwitch(builder, shown));

          final gesture = await tester.startGesture(
            tester.getCenter(find.byKey(_switchKey)) - const Offset(10, 0),
            kind: kind,
          );
          await tester.pump(const Duration(milliseconds: 200));
          // Past the drag slop, so the knob follows the pointer.
          await gesture.moveBy(const Offset(25, 0));
          await tester.pump(const Duration(milliseconds: 50));
          shown.value = false;
          await tester.pump();
          expect(find.byKey(_switchKey), findsNothing);

          await gesture.moveBy(const Offset(10, 0));
          await tester.pump();
          await gesture.moveBy(const Offset(0, 60));
          await tester.pump();
          await gesture.up();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }

      testWidgets('$name: removed while it settles after a tap', (
        tester,
      ) async {
        final shown = ValueNotifier(true);
        addTearDown(shown.dispose);
        await tester.pumpWidget(_removableSwitch(builder, shown));

        await tester.tap(find.byKey(_switchKey));
        // One frame in: the knob has started to move.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        shown.value = false;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('$name: removed while it settles after a drag', (
        tester,
      ) async {
        final shown = ValueNotifier(true);
        addTearDown(shown.dispose);
        await tester.pumpWidget(_removableSwitch(builder, shown));

        final gesture = await tester.startGesture(
          tester.getCenter(find.byKey(_switchKey)) - const Offset(10, 0),
        );
        await tester.pump(const Duration(milliseconds: 200));
        await gesture.moveBy(const Offset(25, 0));
        await tester.pump(const Duration(milliseconds: 50));
        await gesture.up();
        // Removed in the frame right after the release, before the knob has
        // settled.
        shown.value = false;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
