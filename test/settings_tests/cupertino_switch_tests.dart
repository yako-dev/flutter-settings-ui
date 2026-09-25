import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Tests for [CupertinoSettingsSwitch], the iOS 26+ "Liquid Glass" switch.

const Color _white = Color(0xFFFFFFFF);

final Finder _switch = find.byType(CupertinoSettingsSwitch);

/// Pumps a switch that keeps its own value, like an app would, and returns
/// the list of values passed to `onChanged`.
Future<List<bool>> _pumpSwitch(
  WidgetTester tester, {
  bool value = false,
  bool enabled = true,
  TextDirection textDirection = TextDirection.ltr,
  bool disableAnimations = false,
  Brightness brightness = Brightness.light,
  Color? activeTrackColor,
  Color? inactiveTrackColor,
}) async {
  final changes = <bool>[];
  var current = value;
  await tester.pumpWidget(
    CupertinoApp(
      // A fresh switch on every call.
      key: UniqueKey(),
      theme: CupertinoThemeData(brightness: brightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: Directionality(textDirection: textDirection, child: child!),
      ),
      home: Center(
        child: StatefulBuilder(
          builder: (context, setState) => CupertinoSettingsSwitch(
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
    tester.widget<CupertinoSettingsSwitch>(_switch).value;

/// The center of the resting thumb.
Offset _thumb(WidgetTester tester, {bool on = false, bool rtl = false}) {
  final rect = tester.getRect(_switch);
  final fromStart = 20.5 + (on ? 22 : 0);
  return Offset(
    rtl ? rect.right - fromStart : rect.left + fromStart,
    rect.center.dy,
  );
}

RenderObject _painted(WidgetTester tester) => tester.renderObject(
  find.descendant(of: _switch, matching: find.byType(CustomPaint)),
);

/// The resting thumb, in the switch's own coordinates.
RSuperellipse _restingThumb({required bool on}) =>
    RSuperellipse.fromRectAndRadius(
      Rect.fromLTWH(on ? 24 : 2, 2, 37, 24),
      const Radius.circular(12),
    );

void cupertinoSwitchTests() {
  testWidgets('takes 63x28 of layout space', (tester) async {
    await _pumpSwitch(tester);

    expect(tester.getSize(_switch), const Size(63, 28));
    expect(tester.takeException(), isNull);
  });

  testWidgets('draws the measured iOS 27 colors at rest', (tester) async {
    await _pumpSwitch(tester);
    expect(
      _painted(tester),
      paints
        ..rsuperellipse(color: const Color(0xFFC5C5C7))
        ..rsuperellipse(rsuperellipse: _restingThumb(on: false), color: _white),
    );

    await _pumpSwitch(tester, value: true);
    expect(
      _painted(tester),
      paints
        ..rsuperellipse(color: const Color(0xFF34C759))
        ..rsuperellipse(rsuperellipse: _restingThumb(on: true), color: _white),
    );

    await _pumpSwitch(tester, brightness: Brightness.dark);
    expect(
      _painted(tester),
      paints..rsuperellipse(color: const Color(0xFF5A5A5E)),
    );

    await _pumpSwitch(tester, value: true, brightness: Brightness.dark);
    expect(
      _painted(tester),
      paints..rsuperellipse(color: const Color(0xFF30D158)),
    );
  });

  testWidgets('uses activeTrackColor and inactiveTrackColor', (tester) async {
    const blue = Color(0xFF0A84FF);
    const pink = Color(0xFFFF2D55);
    await _pumpSwitch(
      tester,
      value: true,
      activeTrackColor: blue,
      inactiveTrackColor: pink,
    );
    expect(_painted(tester), paints..rsuperellipse(color: blue));

    await tester.tap(_switch);
    await tester.pumpAndSettle();
    expect(_value(tester), isFalse);
    expect(_painted(tester), paints..rsuperellipse(color: pink));
  });

  testWidgets('a tap toggles the value', (tester) async {
    final changes = await _pumpSwitch(tester);

    await tester.tap(_switch);
    await tester.pump();
    expect(changes, [true]);
    // The glass lens is showing while the thumb travels.
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();
    expect(_value(tester), isTrue);
    expect(
      _painted(tester),
      paints
        ..rsuperellipse(color: const Color(0xFF34C759))
        ..rsuperellipse(rsuperellipse: _restingThumb(on: true), color: _white),
    );

    await tester.tap(_switch);
    await tester.pumpAndSettle();
    expect(changes, [true, false]);
    expect(_value(tester), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a disabled switch ignores input and is half opaque', (
    tester,
  ) async {
    final changes = await _pumpSwitch(tester, enabled: false);

    final opacity = tester.widget<Opacity>(
      find.descendant(of: _switch, matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 0.5);

    await tester.tap(_switch);
    await tester.pumpAndSettle();
    await tester.dragFrom(_thumb(tester), const Offset(40, 0));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(_value(tester), isFalse);
  });

  testWidgets('dragging past the far end flips the value mid-drag', (
    tester,
  ) async {
    final changes = await _pumpSwitch(tester);

    final gesture = await tester.startGesture(_thumb(tester));
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    expect(changes, isEmpty, reason: 'not past the ON end yet');
    await gesture.moveBy(const Offset(10, 0));
    await tester.pump();
    expect(changes, [true], reason: 'flips before the finger lifts');

    // Dragging back past the OFF end flips it back, still mid-drag.
    await gesture.moveBy(const Offset(-32, 0));
    await tester.pump();
    expect(changes, [true, false]);
    await gesture.moveBy(const Offset(32, 0));
    await tester.pump();
    expect(changes, [true, false, true]);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes, [true, false, true]);
    expect(_value(tester), isTrue);
    expect(
      _painted(tester),
      paints
        ..rsuperellipse()
        ..rsuperellipse(rsuperellipse: _restingThumb(on: true), color: _white),
    );
  });

  testWidgets('releasing at the midpoint, or right at the far end, does not '
      'flip the value', (tester) async {
    final changes = await _pumpSwitch(tester);

    var gesture = await tester.startGesture(_thumb(tester));
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-9, 0));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(_value(tester), isFalse);
    expect(
      _painted(tester),
      paints
        ..rsuperellipse()
        ..rsuperellipse(rsuperellipse: _restingThumb(on: false)),
    );

    gesture = await tester.startGesture(_thumb(tester));
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(2, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(_value(tester), isFalse);
  });

  testWidgets('drags are mirrored in right-to-left layouts', (tester) async {
    final changes = await _pumpSwitch(tester, textDirection: TextDirection.rtl);

    // Dragging right (toward OFF) does nothing.
    await tester.dragFrom(_thumb(tester, rtl: true), const Offset(40, 0));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);

    await tester.dragFrom(_thumb(tester, rtl: true), const Offset(-40, 0));
    await tester.pumpAndSettle();
    expect(changes, [true]);
    expect(_value(tester), isTrue);

    await tester.dragFrom(
      _thumb(tester, on: true, rtl: true),
      const Offset(40, 0),
    );
    await tester.pumpAndSettle();
    expect(changes, [true, false]);
  });

  testWidgets('a vertical drag that starts on the switch scrolls the list', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final changes = <bool>[];
    await tester.pumpWidget(
      CupertinoApp(
        home: ListView(
          controller: controller,
          children: [
            const SizedBox(height: 100),
            Center(
              child: CupertinoSettingsSwitch(
                value: false,
                onChanged: changes.add,
              ),
            ),
            const SizedBox(height: 2000),
          ],
        ),
      ),
    );

    await tester.drag(_switch, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(200));
    expect(changes, isEmpty);

    // A drag that wobbles sideways first, but less than the touch slop,
    // still scrolls once it goes vertical.
    controller.jumpTo(0);
    await tester.pump();
    final gesture = await tester.startGesture(_thumb(tester));
    await tester.pump(const Duration(milliseconds: 150));
    await gesture.moveBy(const Offset(8, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -30));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -170));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(150));
    expect(changes, isEmpty);
  });

  testWidgets('is a toggle for accessibility, not a button', (tester) async {
    final handle = tester.ensureSemantics();
    final changes = await _pumpSwitch(tester);

    expect(
      tester.getSemantics(_switch),
      isSemantics(
        hasToggledState: true,
        isToggled: false,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isButton: false,
      ),
    );

    tester.semantics.tap(find.semantics.byAction(SemanticsAction.tap));
    await tester.pumpAndSettle();
    expect(changes, [true]);
    expect(
      tester.getSemantics(_switch),
      isSemantics(isToggled: true, isEnabled: true),
    );

    await _pumpSwitch(tester, enabled: false);
    expect(
      tester.getSemantics(_switch),
      isSemantics(
        hasToggledState: true,
        hasEnabledState: true,
        isEnabled: false,
        hasTapAction: false,
      ),
    );
    handle.dispose();
  });

  testWidgets('Space toggles a focused switch', (tester) async {
    final changes = await _pumpSwitch(tester);

    Focus.of(
      tester.element(
        find.descendant(of: _switch, matching: find.byType(CustomPaint)),
      ),
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(changes, [true]);
  });

  testWidgets('with reduced motion, there is no lens and no animation', (
    tester,
  ) async {
    final changes = await _pumpSwitch(tester, disableAnimations: true);

    final gesture = await tester.startGesture(_thumb(tester));
    await tester.pump(const Duration(milliseconds: 200));
    // Still just a track and a white thumb: no lens.
    expect(_painted(tester), paintsExactlyCountTimes(#drawRSuperellipse, 2));
    await gesture.up();
    await tester.pump();
    expect(changes, [true]);
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(
      _painted(tester),
      paints
        ..rsuperellipse(color: const Color(0xFF34C759))
        ..rsuperellipse(rsuperellipse: _restingThumb(on: true), color: _white),
    );

    await tester.dragFrom(_thumb(tester, on: true), const Offset(-40, 0));
    await tester.pump();
    expect(changes, [true, false]);
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(
      _painted(tester),
      paints
        ..rsuperellipse()
        ..rsuperellipse(rsuperellipse: _restingThumb(on: false)),
    );
  });

  testWidgets(
    'plays a light haptic on each change on iOS',
    (tester) async {
      final haptics = <Object?>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await _pumpSwitch(tester);

      await tester.tap(_switch);
      await tester.pumpAndSettle();
      await tester.dragFrom(_thumb(tester, on: true), const Offset(-40, 0));
      await tester.pumpAndSettle();

      final isApple =
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS;
      expect(
        haptics,
        isApple
            ? [
                'HapticFeedbackType.lightImpact',
                'HapticFeedbackType.lightImpact',
              ]
            : isEmpty,
      );
    },
    variant: const TargetPlatformVariant(<TargetPlatform>{
      TargetPlatform.iOS,
      TargetPlatform.android,
    }),
  );

  testWidgets('iOS switch tiles use it, and the lens stays inside the card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var value = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SettingsList(
              platform: DevicePlatform.iOS,
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile.switchTile(
                      title: const Text('Wi-Fi'),
                      initialValue: value,
                      onToggle: (newValue) => setState(() => value = newValue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final switchRect = tester.getRect(_switch);
    final card = tester.getRect(find.byType(ClipRSuperellipse));
    expect(switchRect.size, const Size(63, 28));
    expect(card.right - switchRect.right, 16);

    // Worst case: the lens at the peak of the press spring (41.7pt tall)
    // and dragged as far as it goes (12.5pt past the track end).
    const maxOverhang = 12.5;
    const maxHalfHeight = 41.7 / 2;
    expect(switchRect.right + maxOverhang, lessThan(card.right));
    expect(switchRect.center.dy - maxHalfHeight, greaterThan(card.top));
    expect(switchRect.center.dy + maxHalfHeight, lessThan(card.bottom));
    // The lens's round end must also stay inside the card's 26pt corners.
    final capCenter = Offset(
      switchRect.right + maxOverhang - maxHalfHeight,
      switchRect.center.dy,
    );
    for (final corner in [
      Offset(card.right - 26, card.top + 26),
      Offset(card.right - 26, card.bottom - 26),
    ]) {
      expect((capCenter - corner).distance + maxHalfHeight, lessThan(26));
    }

    final gesture = await tester.startGesture(_thumb(tester));
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(value, isTrue);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(value, isTrue);
    expect(tester.takeException(), isNull);
  });
}
