import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Tests for [FluentSettingsSwitch], the Windows 11 ToggleSwitch.

final Finder _switch = find.byType(FluentSettingsSwitch);

const Color _accentLight = Color(0xFF005FB8);
const Color _accentDark = Color(0xFF60CDFF);
const Color _white = Color(0xFFFFFFFF);
const Color _black = Color(0xFF000000);

/// Pumps a switch that keeps its own value, like an app would, and returns
/// the values passed to `onChanged`.
Future<List<bool>> _pumpSwitch(
  WidgetTester tester, {
  bool value = false,
  bool enabled = true,
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
  bool disableAnimations = false,
  Color? activeTrackColor,
  Color? inactiveTrackColor,
}) async {
  final changes = <bool>[];
  var current = value;
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      theme: ThemeData(brightness: brightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: Directionality(textDirection: textDirection, child: child!),
      ),
      home: Center(
        child: StatefulBuilder(
          builder: (context, setState) => FluentSettingsSwitch(
            value: current,
            onChanged: enabled
                ? (value) {
                    changes.add(value);
                    setState(() => current = value);
                  }
                : null,
            activeTrackColor: activeTrackColor,
            inactiveTrackColor: inactiveTrackColor,
          ),
        ),
      ),
    ),
  );
  return changes;
}

bool _value(WidgetTester tester) =>
    tester.widget<FluentSettingsSwitch>(_switch).value;

RenderObject _painted(WidgetTester tester) => tester.renderObject(
  find.descendant(of: _switch, matching: find.byType(CustomPaint)),
);

RRect _track() => RRect.fromRectAndRadius(
  const Rect.fromLTWH(0, 0, 40, 20),
  const Radius.circular(10),
);

RRect _knob(Rect rect) =>
    RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));

/// The resting 12px knob, in the switch's own coordinates.
RRect _restingKnob({required bool on}) => _knob(
  Rect.fromCenter(center: Offset(on ? 30 : 10, 10), width: 12, height: 12),
);

Future<TestGesture> _hover(WidgetTester tester, Offset position) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  await gesture.moveTo(position);
  await tester.pumpAndSettle();
  return gesture;
}

void fluentSwitchTests() {
  testWidgets('takes 40x20 of layout space', (tester) async {
    await _pumpSwitch(tester);

    expect(tester.getSize(_switch), const Size(40, 20));
    expect(tester.takeException(), isNull);
  });

  testWidgets('OFF: an outlined track with a 12px secondary knob', (
    tester,
  ) async {
    await _pumpSwitch(tester);
    expect(
      _painted(tester),
      paints
        ..rrect(rrect: _track(), color: const Color(0x06000000))
        ..rrect(
          rrect: _track().deflate(0.5),
          style: PaintingStyle.stroke,
          strokeWidth: 1,
          color: const Color(0x72000000),
        )
        ..rrect(rrect: _restingKnob(on: false), color: const Color(0x9E000000)),
    );

    await _pumpSwitch(tester, brightness: Brightness.dark);
    expect(
      _painted(tester),
      paints
        ..rrect(rrect: _track(), color: const Color(0x19000000))
        ..rrect(color: const Color(0x8BFFFFFF))
        ..rrect(rrect: _restingKnob(on: false), color: const Color(0xC5FFFFFF)),
    );
  });

  testWidgets('ON: the accent track with a white (black in dark) knob', (
    tester,
  ) async {
    await _pumpSwitch(tester, value: true);
    expect(
      _painted(tester),
      paints
        ..rrect()
        ..rrect()
        ..rrect(rrect: _track(), color: _accentLight)
        ..rrect(rrect: _restingKnob(on: true), color: _white),
    );

    await _pumpSwitch(tester, value: true, brightness: Brightness.dark);
    expect(
      _painted(tester),
      paints
        ..rrect()
        ..rrect()
        ..rrect(rrect: _track(), color: _accentDark)
        ..rrect(rrect: _restingKnob(on: true), color: _black),
    );
  });

  testWidgets('a tap toggles the value and the knob slides over', (
    tester,
  ) async {
    final changes = await _pumpSwitch(tester);

    await tester.tap(_switch);
    await tester.pump();
    expect(changes, [true]);
    expect(_value(tester), isTrue);

    // Halfway through the 167 ms slide the knob is between the ends.
    await tester.pump(const Duration(milliseconds: 40));
    final double midway = _knobLeft(tester);
    expect(midway, greaterThan(4));
    expect(midway, lessThan(24));

    await tester.pumpAndSettle();
    expect(
      _painted(tester),
      paints
        ..rrect()
        ..rrect()
        ..rrect(color: _accentLight)
        ..rrect(rrect: _restingKnob(on: true), color: _white),
    );

    await tester.tap(_switch);
    await tester.pumpAndSettle();
    expect(changes, [true, false]);
  });

  testWidgets('hovering grows the knob to 14px', (tester) async {
    await _pumpSwitch(tester);
    await _hover(tester, tester.getCenter(_switch));

    expect(
      _painted(tester),
      paints
        ..rrect(color: const Color(0x0F000000))
        ..rrect()
        ..rrect(
          rrect: _knob(
            Rect.fromCenter(
              center: const Offset(10, 10),
              width: 14,
              height: 14,
            ),
          ),
        ),
    );
  });

  testWidgets('pressing stretches the knob to 17x14 toward the middle', (
    tester,
  ) async {
    await _pumpSwitch(tester);
    final gesture = await tester.startGesture(tester.getCenter(_switch));
    await tester.pumpAndSettle();
    expect(
      _painted(tester),
      paints
        ..rrect(color: const Color(0x18000000))
        ..rrect()
        ..rrect(rrect: _knob(const Rect.fromLTRB(3, 3, 20, 17))),
    );
    await gesture.up();
    await tester.pumpAndSettle();

    await _pumpSwitch(tester, value: true);
    final onGesture = await tester.startGesture(tester.getCenter(_switch));
    await tester.pumpAndSettle();
    expect(
      _painted(tester),
      paints
        ..rrect()
        ..rrect()
        ..rrect(color: _accentLight.withValues(alpha: 0.8))
        ..rrect(rrect: _knob(const Rect.fromLTRB(20, 3, 37, 17))),
    );
    await onGesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('a hovered ON switch shows the accent at 90%', (tester) async {
    await _pumpSwitch(tester, value: true);
    await _hover(tester, tester.getCenter(_switch));

    expect(
      _painted(tester),
      paints
        ..rrect()
        ..rrect()
        ..rrect(color: _accentLight.withValues(alpha: 0.9)),
    );
  });

  testWidgets('dragging past the middle sets the value on release', (
    tester,
  ) async {
    final changes = await _pumpSwitch(tester);
    final start = tester.getTopLeft(_switch) + const Offset(10, 10);

    // A short drag goes back.
    await tester.dragFrom(
      start,
      const Offset(8, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(_value(tester), isFalse);

    // Past the middle, it flips when the pointer lifts.
    final gesture = await tester.startGesture(
      start,
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveBy(const Offset(6, 0));
    await gesture.moveBy(const Offset(8, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(changes, isEmpty);
    // The knob follows the pointer from where it went down: the pressed
    // 17px knob starts 3 in, plus 14 of travel.
    expect(_knobLeft(tester), moreOrLessEquals(3 + 14, epsilon: 0.01));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes, [true]);
    expect(_value(tester), isTrue);
  });

  testWidgets('a touch drag follows the finger past the slop', (tester) async {
    final changes = await _pumpSwitch(tester);
    final gesture = await tester.startGesture(
      tester.getTopLeft(_switch) + const Offset(10, 10),
    );
    for (var i = 0; i < 5; i++) {
      await gesture.moveBy(const Offset(5, 0));
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // 25 px of finger travel takes the knob all the way.
    expect(_knobLeft(tester), moreOrLessEquals(3 + 20, epsilon: 0.01));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes, [true]);
  });

  testWidgets('right-to-left: mirrored, and dragged the other way', (
    tester,
  ) async {
    final changes = await _pumpSwitch(tester, textDirection: TextDirection.rtl);
    final rect = tester.getRect(_switch);

    // The canvas is mirrored, so the OFF knob is drawn at the right end.
    expect(
      _painted(tester),
      paints
        ..translate(x: 40, y: 0)
        ..scale(x: -1, y: 1),
    );

    // Dragging a little to the right does nothing; to the left turns it on.
    await tester.dragFrom(
      rect.centerRight - const Offset(10, 0),
      const Offset(8, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    await tester.dragFrom(
      rect.centerRight - const Offset(10, 0),
      const Offset(-20, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(changes, [true]);
  });

  testWidgets('disabled: Windows disabled colors, no toggling', (tester) async {
    final changes = await _pumpSwitch(tester, enabled: false);
    expect(
      _painted(tester),
      paints
        ..rrect(color: const Color(0x00000000))
        ..rrect(color: const Color(0x37000000))
        ..rrect(rrect: _restingKnob(on: false), color: const Color(0x5C000000)),
    );

    await tester.tap(_switch);
    await tester.dragFrom(tester.getCenter(_switch), const Offset(20, 0));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);

    await _pumpSwitch(tester, value: true, enabled: false);
    expect(
      _painted(tester),
      paints
        ..rrect()
        ..rrect()
        ..rrect(color: const Color(0x37000000))
        ..rrect(color: _white),
    );

    await _pumpSwitch(
      tester,
      value: true,
      enabled: false,
      brightness: Brightness.dark,
    );
    expect(
      _painted(tester),
      paints
        ..rrect()
        ..rrect()
        ..rrect(color: const Color(0x28FFFFFF))
        ..rrect(color: const Color(0x87FFFFFF)),
    );
  });

  testWidgets('custom colors; the knob contrasts with the accent', (
    tester,
  ) async {
    const yellow = Color(0xFFFFEB3B);
    const purple = Color(0xFF4A148C);
    const pink = Color(0xFFE91E63);

    await _pumpSwitch(tester, value: true, activeTrackColor: yellow);
    expect(
      _painted(tester),
      paints
        ..rrect()
        ..rrect()
        ..rrect(color: yellow)
        ..rrect(color: _black),
    );

    await _pumpSwitch(
      tester,
      value: true,
      activeTrackColor: purple,
      brightness: Brightness.dark,
    );
    expect(
      _painted(tester),
      paints
        ..rrect()
        ..rrect()
        ..rrect(color: purple)
        ..rrect(color: _white),
    );

    await _pumpSwitch(tester, inactiveTrackColor: pink);
    expect(
      _painted(tester),
      paints
        ..rrect()
        ..rrect(color: pink)
        ..rrect(color: pink),
    );
  });

  testWidgets('keyboard: focus shows the focus rectangle, Space toggles', (
    tester,
  ) async {
    final changes = await _pumpSwitch(tester);
    expect(_painted(tester), isNot(paints..drrect()));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    // 2px outer and 1px inner ring, 7 to the sides and 8 above and below.
    expect(
      _painted(tester),
      paints
        ..drrect(
          outer: RRect.fromRectAndRadius(
            const Rect.fromLTRB(-7, -8, 47, 28),
            const Radius.circular(7),
          ),
          color: const Color(0xE4000000),
        )
        ..drrect(color: const Color(0xB3FFFFFF)),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(changes, [true]);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(changes, [true, false]);
  });

  testWidgets('semantics: a toggled, tappable node', (tester) async {
    final handle = tester.ensureSemantics();
    final changes = await _pumpSwitch(tester, value: true);

    expect(
      tester.getSemantics(_switch),
      isSemantics(
        hasToggledState: true,
        isToggled: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isFocusable: true,
      ),
    );

    tester.semantics.tap(find.semantics.byFlag(SemanticsFlag.hasToggledState));
    await tester.pumpAndSettle();
    expect(changes, [false]);

    await _pumpSwitch(tester, enabled: false);
    expect(
      tester.getSemantics(_switch),
      isSemantics(
        hasToggledState: true,
        isToggled: false,
        hasEnabledState: true,
        isEnabled: false,
        hasTapAction: false,
      ),
    );
    handle.dispose();
  });

  testWidgets('reduce motion: the knob jumps to the new end', (tester) async {
    await _pumpSwitch(tester, disableAnimations: true);

    await tester.tap(_switch);
    await tester.pump();
    await tester.pump();
    expect(_knobLeft(tester), 24);
  });

  testWidgets('inside a settings list it follows the list colors', (
    tester,
  ) async {
    // A dark list in a light app draws dark switches.
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.light),
        home: Scaffold(
          body: SettingsList(
            platform: DevicePlatform.windows,
            brightness: Brightness.dark,
            sections: [
              SettingsSection(
                tiles: [
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
      ),
    );
    expect(
      _painted(tester),
      paints
        ..rrect()
        ..rrect()
        ..rrect(color: _accentDark)
        ..rrect(color: _black),
    );

    // A disabled switch uses inactiveSwitchColor.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsList(
            platform: DevicePlatform.windows,
            lightTheme: const SettingsThemeData(
              inactiveSwitchColor: Colors.pink,
            ),
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile.switchTile(
                    title: const Text('Wi-Fi'),
                    initialValue: true,
                    onToggle: (_) {},
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
      _painted(tester),
      paints
        ..rrect()
        ..rrect(color: Colors.pink)
        ..rrect(color: Colors.pink),
    );
  });
}

/// The left edge of the knob, from the last knob drawn.
double _knobLeft(WidgetTester tester) {
  final RenderObject object = _painted(tester);
  double? left;
  expect(
    object,
    paints..everything((Symbol method, List<dynamic> arguments) {
      if (method == #drawRRect) {
        final RRect rrect = arguments[0] as RRect;
        if (rrect.width < 20) left = rrect.left;
      }
      return true;
    }),
  );
  return left!;
}
