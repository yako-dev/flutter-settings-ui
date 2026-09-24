import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/sections/platforms/macos_settings_section.dart';
import 'package:settings_ui/src/tiles/platforms/macos_settings_tile.dart';

/// Tests for the macOS 26/27 System Settings style (`DevicePlatform.macOS`)
/// and [MacosSettingsSwitch].

const _white = Color(0xFFFFFFFF);
const _lightCard = Color(0xFFF7F7F7);
const _darkCard = Color(0xFF252525);
const _lightDivider = Color(0xFFEBEBEB);
const _lightLabel = Color(0xD8000000);
const _lightSecondary = Color(0x7F000000);
const _lightTertiary = Color(0x42000000);
const _onTrackLight = Color(0xFF0476F7);
const _onTrackDark = Color(0xFF117BFC);
const _offTrackLight = Color(0x1A000000);

Future<void> _pump(
  WidgetTester tester,
  List<AbstractSettingsSection> sections, {
  Size size = const Size(600, 900),
  Brightness? brightness,
  Brightness appBrightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
  double textScale = 1,
  SettingsThemeData? lightTheme,
  SettingsThemeData? darkTheme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: appBrightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(textDirection: textDirection, child: child!),
      ),
      home: Scaffold(
        body: SettingsList(
          platform: DevicePlatform.macOS,
          brightness: brightness,
          lightTheme: lightTheme,
          darkTheme: darkTheme,
          sections: sections,
        ),
      ),
    ),
  );
}

Finder get _cards => find.descendant(
  of: find.byType(MacosSettingsSection),
  matching: find.byType(ClipRSuperellipse),
);

Rect _card(WidgetTester tester, [int index = 0]) =>
    tester.getRect(_cards.at(index));

Rect _row(WidgetTester tester, String title) => tester.getRect(
  find.ancestor(of: find.text(title), matching: find.byType(MacosSettingsTile)),
);

Finder _coloredBox(Color color) =>
    find.byWidgetPredicate((w) => w is ColoredBox && w.color == color);

TextStyle _styleOf(WidgetTester tester, String text) => tester
    .widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text(text),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    )
    .style;

SettingsThemeData _themeData(WidgetTester tester, String text) =>
    SettingsTheme.of(tester.element(find.text(text))).themeData;

List<SettingsTile> _tiles(int count) => [
  for (var i = 0; i < count; i++) SettingsTile(title: Text('Tile $i')),
];

final Finder _switch = find.byType(MacosSettingsSwitch);

RenderObject _switchPaint(WidgetTester tester, [int index = 0]) =>
    tester.renderObject(
      find.descendant(
        of: _switch.at(index),
        matching: find.byType(CustomPaint),
      ),
    );

RRect _knob({required bool on, bool large = false}) => large
    ? RRect.fromLTRBR(
        on ? 16 : 2,
        2,
        on ? 42 : 28,
        18,
        const Radius.circular(8),
      )
    : RRect.fromLTRBR(
        on ? 13.5 : 1.5,
        1.5,
        on ? 34.5 : 22.5,
        14.5,
        const Radius.circular(6.5),
      );

/// Pumps a lone switch that keeps its own value, like an app would, and
/// returns the values passed to `onChanged`.
Future<List<bool>> _pumpSwitch(
  WidgetTester tester, {
  bool value = false,
  bool enabled = true,
  bool followParent = true,
  TextDirection textDirection = TextDirection.ltr,
  bool disableAnimations = false,
  Brightness brightness = Brightness.light,
  MacosSettingsSwitchSize size = MacosSettingsSwitchSize.regular,
  Color? activeTrackColor,
  Color? inactiveTrackColor,
}) async {
  final changes = <bool>[];
  var current = value;
  await tester.pumpWidget(
    CupertinoApp(
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
          builder: (context, setState) => MacosSettingsSwitch(
            value: current,
            size: size,
            activeTrackColor: activeTrackColor,
            inactiveTrackColor: inactiveTrackColor,
            onChanged: enabled
                ? (value) {
                    changes.add(value);
                    if (followParent) setState(() => current = value);
                  }
                : null,
          ),
        ),
      ),
    ),
  );
  return changes;
}

bool _switchValue(WidgetTester tester) =>
    tester.widget<MacosSettingsSwitch>(_switch).value;

void macosStyleTests() {
  group('Layout', () {
    testWidgets('cards have 12pt continuous corners and 20pt side margins', (
      tester,
    ) async {
      await _pump(tester, [SettingsSection(tiles: _tiles(2))]);

      final clip = tester.widget<ClipRSuperellipse>(_cards);
      expect(clip.borderRadius, BorderRadius.circular(12));
      final card = _card(tester);
      expect(card.left, 20);
      expect(card.right, 580);
      expect(_coloredBox(_lightCard), findsOneWidget);
      // No border and no shadow.
      expect(
        find.descendant(
          of: find.byType(MacosSettingsSection),
          matching: find.byType(PhysicalModel),
        ),
        findsNothing,
      );
    });

    testWidgets('rows are 36pt, with 1pt separators inset 10pt', (
      tester,
    ) async {
      await _pump(tester, [SettingsSection(tiles: _tiles(3))]);

      final card = _card(tester);
      final first = _row(tester, 'Tile 0');
      final second = _row(tester, 'Tile 1');
      expect(first.height, 36);
      expect(second.top - first.top, 37);
      expect(card.height, 3 * 36 + 2);

      final separators = find.descendant(
        of: find.byType(MacosSettingsSection),
        matching: _coloredBox(_lightDivider),
      );
      expect(separators, findsNWidgets(2));
      final separator = tester.getRect(separators.first);
      expect(separator.height, 1);
      expect(separator.left, card.left + 10);
      expect(separator.right, card.right - 10);
      expect(separator.top, first.bottom);

      // Title text starts 10pt in from the card edge, in 13pt on a 16pt line.
      final text = tester.getRect(find.text('Tile 0'));
      expect(text.left, card.left + 10);
      expect(text.height, 16);
      expect(text.center.dy, first.center.dy);
      final style = _styleOf(tester, 'Tile 0');
      expect(style.fontSize, 13);
      expect(style.color, _lightLabel);
    });

    testWidgets('a subtitle makes a 52pt row, an icon a 48pt row', (
      tester,
    ) async {
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile(
              title: const Text('Two lines'),
              titleDescription: const Text('Subtitle'),
            ),
            SettingsTile(
              leading: const Icon(Icons.wifi),
              title: const Text('With icon'),
            ),
            SettingsTile(
              leading: const Icon(Icons.wifi),
              title: const Text('Compact icon'),
              compact: true,
            ),
            SettingsTile(title: const Text('Compact'), compact: true),
          ],
        ),
      ]);

      expect(_row(tester, 'Two lines').height, 52);
      final subtitle = tester.getRect(find.text('Subtitle'));
      expect(subtitle.top - tester.getRect(find.text('Two lines')).bottom, 2);
      expect(subtitle.height, 14);
      expect(_styleOf(tester, 'Subtitle').fontSize, 11);
      expect(_styleOf(tester, 'Subtitle').color, _lightSecondary);

      expect(_row(tester, 'With icon').height, 48);
      expect(_row(tester, 'Compact icon').height, 36);
      expect(_row(tester, 'Compact').height, 26);

      // The icon is 20pt, 12pt from the card edge, and the title 11pt after.
      final card = _card(tester);
      final icon = tester.getRect(find.byIcon(Icons.wifi).first);
      expect(icon.size, const Size(20, 20));
      expect(icon.left, card.left + 12);
      expect(tester.getRect(find.text('With icon')).left, icon.right + 11);
      final iconTheme = IconTheme.of(
        tester.element(find.byIcon(Icons.wifi).first),
      );
      expect(iconTheme.color, _lightSecondary);
    });

    testWidgets('headers are 13pt semibold, 10pt above the card', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, [
        SettingsSection(title: const Text('First'), tiles: _tiles(1)),
        SettingsSection(title: const Text('Second'), tiles: _tiles(1)),
        SettingsSection(tiles: _tiles(1)),
      ]);

      final style = _styleOf(tester, 'First');
      expect(style.fontSize, 13);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.color, _lightLabel);

      final first = tester.getRect(find.text('First'));
      final second = tester.getRect(find.text('Second'));
      // The first header starts 20pt down, like in System Settings.
      expect(first.top, 20);
      expect(first.left, 30);
      expect(first.height, 16);
      expect(_card(tester, 0).top - first.bottom, 10);
      // A header starts 30pt below the card above it.
      expect(second.top - _card(tester, 0).bottom, 30);
      expect(_card(tester, 1).top - second.bottom, 10);
      // Cards without a header are 10pt apart.
      expect(_card(tester, 2).top - _card(tester, 1).bottom, 10);
      expect(
        tester.getSemantics(find.text('First')),
        isSemantics(isHeader: true, label: 'First'),
      );
      handle.dispose();
    });

    testWidgets('an untitled first card starts 12pt down', (tester) async {
      await _pump(tester, [
        // An empty section shows nothing and does not count.
        const SettingsSection(title: Text('Empty'), tiles: []),
        SettingsSection(tiles: _tiles(1)),
      ]);

      expect(find.text('Empty'), findsNothing);
      expect(_card(tester).top, 12);
    });

    testWidgets('the list ends 20pt below the last card', (tester) async {
      await _pump(tester, [
        SettingsSection(tiles: _tiles(1)),
      ], size: const Size(600, 200));

      final list = tester.widget<ListView>(find.byType(ListView).first);
      expect(list.padding?.resolve(TextDirection.ltr).bottom, 10);
      expect(
        tester.getRect(find.byType(MacosSettingsSection)).bottom -
            _card(tester).bottom,
        10,
      );
    });

    testWidgets('a description becomes a footer and ends the card', (
      tester,
    ) async {
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile(
              title: const Text('A'),
              description: const Text('Footer A'),
            ),
            SettingsTile(title: const Text('B')),
            SettingsTile(title: const Text('C')),
          ],
        ),
      ]);

      expect(_cards, findsNWidgets(2));
      final first = _card(tester, 0);
      final second = _card(tester, 1);
      final footer = tester.getRect(find.text('Footer A'));
      expect(footer.top - first.bottom, 10);
      expect(footer.left, first.left + 10);
      expect(second.top - footer.bottom, 10);
      final style = _styleOf(tester, 'Footer A');
      expect(style.fontSize, 11);
      expect(style.color, _lightSecondary);
      // The footer is outside the card.
      expect(
        find.descendant(of: _cards.at(0), matching: find.text('Footer A')),
        findsNothing,
      );
    });

    testWidgets('the column is 640pt wide and centered on wide screens', (
      tester,
    ) async {
      await _pump(tester, [
        SettingsSection(tiles: _tiles(1)),
      ], size: const Size(1200, 800));

      final section = tester.getRect(find.byType(MacosSettingsSection));
      expect(section.width, 640);
      expect(section.left, 280);
      expect(_card(tester).width, 600);
    });

    testWidgets('custom tiles sit on the card, with separators', (
      tester,
    ) async {
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile(title: const Text('Tile')),
            const CustomSettingsTile(
              child: SizedBox(height: 40, child: Text('Custom')),
            ),
          ],
        ),
        const CustomSettingsSection(child: Text('Custom section')),
      ]);

      expect(
        find.descendant(of: _cards, matching: find.text('Custom')),
        findsOneWidget,
      );
      expect(_card(tester).height, 36 + 1 + 40);
      // Custom tiles get the row text style.
      expect(_styleOf(tester, 'Custom').fontSize, 13);
      expect(find.text('Custom section'), findsOneWidget);
    });

    testWidgets('a tile outside a section draws its own card and footer', (
      tester,
    ) async {
      await _pump(tester, [
        CustomSettingsSection(
          child: SettingsTile(
            title: const Text('Alone'),
            description: const Text('Below'),
          ),
        ),
      ]);

      final clip = find.ancestor(
        of: find.text('Alone'),
        matching: find.byType(ClipRSuperellipse),
      );
      expect(clip, findsOneWidget);
      expect(
        find.descendant(of: clip, matching: find.text('Below')),
        findsNothing,
      );
      expect(find.text('Below'), findsOneWidget);
    });
  });

  group('Tile types', () {
    testWidgets('navigation tiles end with a chevron after the value', (
      tester,
    ) async {
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile.navigation(
              title: const Text('Wi-Fi'),
              value: const Text('Connected'),
            ),
            SettingsTile(title: const Text('Version'), value: const Text('27')),
          ],
        ),
      ]);

      expect(find.byType(MacosChevron), findsOneWidget);
      final card = _card(tester);
      final chevron = tester.getRect(find.byType(MacosChevron));
      final value = tester.getRect(find.text('Connected'));
      expect(chevron.size, const Size(5.5, 9));
      expect(chevron.right, card.right - 10);
      expect(chevron.left - value.right, 8);
      expect(chevron.center.dy, _row(tester, 'Wi-Fi').center.dy);
      expect(tester.getRect(find.text('27')).right, card.right - 10);
      expect(_styleOf(tester, 'Connected').color, _lightSecondary);
      // tertiaryLabelColor.
      final chevronColor = tester
          .widget<MacosChevron>(find.byType(MacosChevron))
          .color!;
      expect(chevronColor.a, moreOrLessEquals(0.259, epsilon: 0.001));
      expect(chevronColor.r, 0);
    });

    testWidgets('switch tiles end with a 36x16 switch, 10pt from the edge', (
      tester,
    ) async {
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile.switchTile(
              title: const Text('Wi-Fi'),
              initialValue: true,
              onToggle: (_) {},
            ),
          ],
        ),
      ]);

      final rect = tester.getRect(_switch);
      expect(rect.size, const Size(36, 16));
      expect(rect.right, _card(tester).right - 10);
      expect(rect.center.dy, _row(tester, 'Wi-Fi').center.dy);
      expect(_row(tester, 'Wi-Fi').height, 36);
    });

    testWidgets('with a subtitle, trailing parts line up with the title', (
      tester,
    ) async {
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile.switchTile(
              title: const Text('Toggle'),
              titleDescription: const Text('Explains the toggle'),
              initialValue: false,
              onToggle: (_) {},
            ),
            SettingsTile(
              title: const Text('Title'),
              titleDescription: const Text('Subtitle'),
              value: const Text('Value'),
            ),
          ],
        ),
      ]);

      final title = tester.getRect(find.text('Toggle'));
      expect(tester.getRect(_switch).center.dy, title.center.dy);
      expect(
        tester.getRect(find.text('Value')).top,
        tester.getRect(find.text('Title')).top,
      );
    });

    testWidgets('trailing widgets come before the switch', (tester) async {
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile.switchTile(
              title: const Text('Tile'),
              trailing: const Icon(Icons.star),
              initialValue: true,
              onToggle: (_) {},
            ),
          ],
        ),
      ]);

      final star = tester.getRect(find.byIcon(Icons.star));
      expect(star.size, const Size(16, 16));
      expect(tester.getRect(_switch).left - star.right, 12);
    });

    testWidgets('a long value takes at most half the row and is ellipsized', (
      tester,
    ) async {
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile(
              title: const Text('Title'),
              value: Text('Value ' * 30),
            ),
          ],
        ),
      ], size: const Size(400, 600));

      expect(tester.takeException(), isNull);
      // 400 - 2 * 20 margins - 2 * 10 insets = 340.
      expect(tester.getRect(find.text('Value ' * 30)).width, 170);
    });
  });

  group('Interaction', () {
    testWidgets('only the switch toggles; the row calls onPressed', (
      tester,
    ) async {
      final toggles = <bool>[];
      var presses = 0;
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile.switchTile(
              title: const Text('Tile'),
              initialValue: false,
              onToggle: toggles.add,
              onPressed: (_) => presses++,
            ),
          ],
        ),
      ]);

      await tester.tap(find.text('Tile'));
      await tester.pumpAndSettle();
      expect(presses, 1);
      expect(toggles, isEmpty);

      await tester.tap(_switch);
      await tester.pumpAndSettle();
      expect(toggles, [true]);
      expect(presses, 1);
    });

    testWidgets('a pressed row shows the highlight; hovering does not', (
      tester,
    ) async {
      var presses = 0;
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile.navigation(
              title: const Text('General'),
              onPressed: (_) => presses++,
            ),
          ],
        ),
      ]);
      const highlight = Color(0x0F000000);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('General')));
      await tester.pumpAndSettle();
      expect(_coloredBox(highlight), findsNothing);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('General')),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(_coloredBox(highlight), findsOneWidget);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_coloredBox(highlight), findsNothing);
      expect(presses, 1);
    });

    testWidgets('rows without onPressed do not highlight', (tester) async {
      await _pump(tester, [SettingsSection(tiles: _tiles(1))]);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Tile 0')),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(_coloredBox(const Color(0x0F000000)), findsNothing);
      await gesture.up();
    });

    testWidgets('Tab focuses a row, shows the focus ring, Enter presses it', (
      tester,
    ) async {
      var presses = 0;
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile(title: const Text('Static')),
            SettingsTile.navigation(
              title: const Text('Open'),
              onPressed: (_) => presses++,
            ),
          ],
        ),
      ]);

      Finder ring() => find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.position == DecorationPosition.foreground &&
            w.decoration is ShapeDecoration,
      );
      expect(ring(), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(ring(), findsOneWidget);
      final shape =
          (tester.widget<DecoratedBox>(ring()).decoration as ShapeDecoration)
                  .shape
              as RoundedSuperellipseBorder;
      expect(shape.side.width, 3);
      expect(shape.side.color, const Color(0x800067F4));

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(presses, 1);
    });

    testWidgets('each row is one node; switch rows read as a toggle', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final toggles = <bool>[];
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile.navigation(
              title: const Text('Open'),
              value: const Text('On'),
              onPressed: (_) {},
            ),
            SettingsTile(title: const Text('Static')),
            SettingsTile.switchTile(
              title: const Text('Wi-Fi'),
              initialValue: false,
              onToggle: toggles.add,
            ),
          ],
        ),
      ]);

      expect(
        tester.getSemantics(find.text('Open')),
        isSemantics(
          label: 'Open\nOn',
          isButton: true,
          hasTapAction: true,
          isEnabled: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Static')),
        isSemantics(label: 'Static', isButton: false, hasTapAction: false),
      );
      expect(
        tester.getSemantics(find.text('Wi-Fi')),
        isSemantics(
          label: 'Wi-Fi',
          hasToggledState: true,
          isToggled: false,
          hasTapAction: true,
        ),
      );
      tester.semantics.tap(find.semantics.byLabel('Wi-Fi'));
      await tester.pumpAndSettle();
      expect(toggles, [true]);
      handle.dispose();
    });

    testWidgets('a disabled tile dims its text and ignores input', (
      tester,
    ) async {
      final toggles = <bool>[];
      var presses = 0;
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile.switchTile(
              title: const Text('Off limits'),
              initialValue: true,
              onToggle: toggles.add,
              onPressed: (_) => presses++,
              enabled: false,
            ),
            SettingsTile.navigation(
              title: const Text('Also off'),
              value: const Text('Value'),
              onPressed: (_) => presses++,
              enabled: false,
            ),
          ],
        ),
      ]);

      expect(_styleOf(tester, 'Off limits').color, _lightTertiary);
      expect(_styleOf(tester, 'Value').color, _lightTertiary);
      expect(tester.widget<MacosSettingsSwitch>(_switch).onChanged, isNull);

      await tester.tap(_switch, warnIfMissed: false);
      await tester.tap(find.text('Also off'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(toggles, isEmpty);
      expect(presses, 0);
    });
  });

  group('Colors', () {
    for (final brightness in Brightness.values) {
      final isLight = brightness == Brightness.light;
      testWidgets('$brightness: System Settings colors', (tester) async {
        await _pump(tester, [
          SettingsSection(title: const Text('Header'), tiles: _tiles(2)),
        ], appBrightness: brightness);

        final data = _themeData(tester, 'Tile 0');
        expect(
          data.settingsListBackground,
          isLight ? _white : const Color(0xFF1E1E1E),
        );
        expect(
          data.settingsSectionBackground,
          isLight ? _lightCard : _darkCard,
        );
        expect(
          data.dividerColor,
          isLight ? _lightDivider : const Color(0xFF2F2F2F),
        );
        expect(
          data.settingsTileTextColor,
          isLight ? _lightLabel : const Color(0xD8FFFFFF),
        );
        expect(data.titleTextColor, data.settingsTileTextColor);
        expect(
          data.trailingTextColor,
          isLight ? _lightSecondary : const Color(0x8CFFFFFF),
        );
        expect(data.tileDescriptionTextColor, data.trailingTextColor);
        expect(
          data.inactiveTitleColor,
          isLight ? _lightTertiary : const Color(0x3FFFFFFF),
        );
        expect(_coloredBox(data.settingsSectionBackground!), findsOneWidget);
        expect(
          tester
              .widget<Container>(
                find
                    .ancestor(
                      of: find.byType(ListView),
                      matching: find.byType(Container),
                    )
                    .first,
              )
              .color,
          data.settingsListBackground,
        );
      });
    }

    testWidgets('ignores the app ColorScheme', (tester) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          ),
          home: Scaffold(
            body: SettingsList(
              platform: DevicePlatform.macOS,
              sections: [SettingsSection(tiles: _tiles(1))],
            ),
          ),
        ),
      );
      expect(
        _themeData(tester, 'Tile 0').settingsSectionBackground,
        _lightCard,
      );
    });

    testWidgets('a list forced to dark gets dark switches in a light app', (
      tester,
    ) async {
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile.switchTile(
              title: const Text('Tile'),
              initialValue: false,
              onToggle: (_) {},
            ),
          ],
        ),
      ], brightness: Brightness.dark);

      expect(
        _switchPaint(tester),
        paints
          ..rrect(color: const Color(0x1AFFFFFF))
          ..rrect()
          ..rrect(color: const Color(0xFFE2E2E2)),
      );
    });

    testWidgets('SettingsThemeData overrides every color', (tester) async {
      const theme = SettingsThemeData(
        settingsListBackground: Color(0xFF000001),
        settingsSectionBackground: Color(0xFF000002),
        dividerColor: Color(0xFF000003),
        titleTextColor: Color(0xFF000004),
        settingsTileTextColor: Color(0xFF000005),
        trailingTextColor: Color(0xFF000006),
        tileDescriptionTextColor: Color(0xFF000007),
        leadingIconsColor: Color(0xFF000008),
        tileHighlightColor: Color(0xFF000009),
        inactiveTitleColor: Color(0xFF00000A),
        inactiveSubtitleColor: Color(0xFF00000B),
        inactiveSwitchColor: Color(0xFF00000C),
      );
      await _pump(tester, [
        SettingsSection(
          title: const Text('Header'),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(Icons.wifi),
              title: const Text('Title'),
              titleDescription: const Text('Subtitle'),
              value: const Text('Value'),
              onPressed: (_) {},
              description: const Text('Footer'),
            ),
            SettingsTile.switchTile(
              title: const Text('Disabled'),
              titleDescription: const Text('Disabled subtitle'),
              initialValue: true,
              onToggle: (_) {},
              enabled: false,
            ),
            SettingsTile(title: const Text('Last')),
          ],
        ),
      ], lightTheme: theme);

      expect(_coloredBox(const Color(0xFF000002)), findsNWidgets(2));
      expect(_coloredBox(const Color(0xFF000003)), findsOneWidget);
      expect(_styleOf(tester, 'Header').color, const Color(0xFF000004));
      expect(_styleOf(tester, 'Title').color, const Color(0xFF000005));
      expect(_styleOf(tester, 'Value').color, const Color(0xFF000006));
      expect(_styleOf(tester, 'Subtitle').color, const Color(0xFF000007));
      expect(_styleOf(tester, 'Footer').color, const Color(0xFF000007));
      expect(
        IconTheme.of(tester.element(find.byIcon(Icons.wifi))).color,
        const Color(0xFF000008),
      );
      expect(_styleOf(tester, 'Disabled').color, const Color(0xFF00000A));
      expect(
        _styleOf(tester, 'Disabled subtitle').color,
        const Color(0xFF00000B),
      );
      expect(
        tester.widget<MacosSettingsSwitch>(_switch).activeTrackColor,
        const Color(0xFF00000C),
      );
      expect(
        tester
            .widget<Container>(
              find
                  .ancestor(
                    of: find.byType(ListView),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .color,
        const Color(0xFF000001),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Title')),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(_coloredBox(const Color(0xFF000009)), findsOneWidget);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('SettingsThemeData text styles replace the defaults', (
      tester,
    ) async {
      await _pump(
        tester,
        [
          SettingsSection(
            title: const Text('Header'),
            tiles: [
              SettingsTile(
                title: const Text('Title'),
                titleDescription: const Text('Subtitle'),
                description: const Text('Footer'),
              ),
            ],
          ),
        ],
        lightTheme: const SettingsThemeData(
          titleTextStyle: TextStyle(fontSize: 20, color: Color(0xFFFF0000)),
          tileTextStyle: TextStyle(fontSize: 17),
          tileDescriptionTextStyle: TextStyle(fontSize: 12),
        ),
      );

      expect(_styleOf(tester, 'Header').fontSize, 20);
      // A color in the style wins over titleTextColor.
      expect(_styleOf(tester, 'Header').color, const Color(0xFFFF0000));
      expect(_styleOf(tester, 'Title').fontSize, 17);
      expect(_styleOf(tester, 'Title').color, _lightLabel);
      expect(_styleOf(tester, 'Subtitle').fontSize, 12);
      expect(_styleOf(tester, 'Footer').fontSize, 12);
    });

    testWidgets('activeSwitchColor colors the switch', (tester) async {
      const green = Color(0xFF34C759);
      await _pump(tester, [
        SettingsSection(
          tiles: [
            SettingsTile.switchTile(
              title: const Text('Tile'),
              initialValue: true,
              onToggle: (_) {},
              activeSwitchColor: green,
            ),
          ],
        ),
      ]);

      expect(_switchPaint(tester), paints..rrect(color: green));
    });
  });

  group('Paddings', () {
    EdgeInsetsGeometry paddingAround(WidgetTester tester, Finder finder) =>
        tester
            .widget<Padding>(
              find.ancestor(of: finder, matching: find.byType(Padding)).first,
            )
            .padding;

    testWidgets('every padding parameter reaches its widget', (tester) async {
      await _pump(tester, [
        SettingsSection(
          margin: const EdgeInsetsDirectional.all(1),
          titlePadding: const EdgeInsets.all(2),
          title: const Text('Header'),
          tiles: [
            SettingsTile(
              leading: const Icon(Icons.wifi),
              title: const Text('Title'),
              titleDescription: const Text('Subtitle'),
              trailing: const Icon(Icons.star),
              description: const Text('Footer'),
              titlePadding: const EdgeInsets.all(3),
              leadingPadding: const EdgeInsets.all(4),
              trailingPadding: const EdgeInsets.all(5),
              titleDescriptionPadding: const EdgeInsets.all(6),
              descriptionPadding: const EdgeInsets.all(7),
            ),
          ],
        ),
      ]);

      expect(
        paddingAround(tester, find.text('Header')),
        const EdgeInsets.all(2),
      );
      expect(
        paddingAround(tester, find.text('Title')),
        const EdgeInsets.all(3),
      );
      expect(
        paddingAround(tester, find.byIcon(Icons.wifi)),
        const EdgeInsets.all(4),
      );
      expect(
        paddingAround(tester, find.byIcon(Icons.star)),
        const EdgeInsets.all(5),
      );
      expect(
        paddingAround(tester, find.text('Subtitle')),
        const EdgeInsets.all(6),
      );
      expect(
        paddingAround(tester, find.text('Footer')),
        const EdgeInsets.all(7),
      );
      expect(
        tester
            .widget<Padding>(
              find
                  .descendant(
                    of: find.byType(MacosSettingsSection),
                    matching: find.byType(Padding),
                  )
                  .first,
            )
            .padding,
        const EdgeInsetsDirectional.all(1),
      );
    });
  });

  group('Right-to-left and text scaling', () {
    testWidgets('RTL mirrors the row and the chevron', (tester) async {
      await _pump(tester, [
        SettingsSection(
          title: const Text('Header'),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(Icons.wifi),
              title: const Text('Title'),
              value: const Text('Value'),
            ),
          ],
        ),
      ], textDirection: TextDirection.rtl);

      final card = _card(tester);
      expect(tester.getRect(find.byIcon(Icons.wifi)).right, card.right - 12);
      expect(tester.getRect(find.byType(MacosChevron)).left, card.left + 10);
      expect(tester.getRect(find.text('Header')).right, card.right - 10);
      expect(
        tester.widget<MacosChevron>(find.byType(MacosChevron)).pointsLeft,
        isTrue,
      );
      expect(
        tester.getRect(find.text('Value')).left,
        greaterThan(tester.getRect(find.byType(MacosChevron)).right),
      );
    });

    testWidgets('text scale 2.0 in a narrow window does not overflow', (
      tester,
    ) async {
      await _pump(
        tester,
        [
          SettingsSection(
            title: const Text('A header that is long enough to wrap'),
            tiles: [
              SettingsTile(
                leading: const Icon(Icons.wifi),
                title: const Text('A title that is long enough to wrap'),
                value: const Text('And a long value too'),
              ),
              SettingsTile.navigation(
                title: const Text('Navigation with a long title'),
                titleDescription: const Text('And a subtitle that wraps'),
                value: const Text('Value'),
                trailing: const Icon(Icons.star),
              ),
              SettingsTile.switchTile(
                title: const Text('Switch with a long title'),
                titleDescription: const Text('And a subtitle'),
                trailing: const Icon(Icons.star),
                initialValue: true,
                onToggle: (_) {},
                description: const Text('A footer that is long enough to wrap'),
              ),
              SettingsTile(title: const Text('Compact'), compact: true),
            ],
          ),
        ],
        size: const Size(320, 900),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
      // Paddings grow with the text.
      expect(_row(tester, 'Compact').height, 2 * 26);
    });
  });

  group('MacosSettingsSwitch', () {
    testWidgets('is 36x16, or 44x20 when large', (tester) async {
      await _pumpSwitch(tester);
      expect(tester.getSize(_switch), const Size(36, 16));

      await _pumpSwitch(tester, size: MacosSettingsSwitchSize.large);
      expect(tester.getSize(_switch), const Size(44, 20));
    });

    testWidgets('draws the measured System Settings colors', (tester) async {
      await _pumpSwitch(tester);
      expect(
        _switchPaint(tester),
        paints
          ..rrect(
            rrect: RRect.fromLTRBR(0, 0, 36, 16, const Radius.circular(8)),
            color: _offTrackLight,
          )
          ..rrect()
          ..rrect(rrect: _knob(on: false), color: _white),
      );

      await _pumpSwitch(tester, value: true);
      expect(
        _switchPaint(tester),
        paints
          ..rrect(color: _onTrackLight)
          ..rrect()
          ..rrect(rrect: _knob(on: true), color: _white),
      );

      await _pumpSwitch(tester, brightness: Brightness.dark);
      expect(
        _switchPaint(tester),
        paints
          ..rrect(color: const Color(0x1AFFFFFF))
          ..rrect()
          ..rrect(color: const Color(0xFFE2E2E2)),
      );

      await _pumpSwitch(tester, value: true, brightness: Brightness.dark);
      expect(
        _switchPaint(tester),
        paints
          ..rrect(color: _onTrackDark)
          ..rrect()
          ..rrect(color: Color.lerp(_white, _onTrackDark, 0.14)),
      );

      await _pumpSwitch(
        tester,
        value: true,
        size: MacosSettingsSwitchSize.large,
      );
      expect(
        _switchPaint(tester),
        paints
          ..rrect(
            rrect: RRect.fromLTRBR(0, 0, 44, 20, const Radius.circular(10)),
          )
          ..rrect()
          ..rrect(rrect: _knob(on: true, large: true)),
      );
    });

    testWidgets('uses activeTrackColor and inactiveTrackColor', (tester) async {
      const green = Color(0xFF34C759);
      const pink = Color(0xFFFF2D55);
      await _pumpSwitch(
        tester,
        value: true,
        activeTrackColor: green,
        inactiveTrackColor: pink,
      );
      expect(_switchPaint(tester), paints..rrect(color: green));

      await tester.tap(_switch);
      await tester.pumpAndSettle();
      expect(_switchValue(tester), isFalse);
      expect(_switchPaint(tester), paints..rrect(color: pink));
    });

    testWidgets('a click toggles the value and animates the knob', (
      tester,
    ) async {
      final changes = await _pumpSwitch(tester);

      await tester.tap(_switch);
      await tester.pump();
      expect(changes, [true]);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(
        _switchPaint(tester),
        paints
          ..rrect(color: _onTrackLight)
          ..rrect()
          ..rrect(rrect: _knob(on: true)),
      );

      await tester.tap(_switch);
      await tester.pumpAndSettle();
      expect(changes, [true, false]);
      expect(_switchValue(tester), isFalse);
    });

    testWidgets('the knob darkens while pressed', (tester) async {
      await _pumpSwitch(tester);
      final gesture = await tester.startGesture(tester.getCenter(_switch));
      await tester.pump(const Duration(milliseconds: 150));
      expect(
        _switchPaint(tester),
        paints
          ..rrect()
          ..rrect()
          ..rrect(color: Color.lerp(_white, const Color(0xFF000000), 0.06)),
      );
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('dragging past the middle flips the value on release', (
      tester,
    ) async {
      final changes = await _pumpSwitch(tester);
      final start = tester.getTopLeft(_switch) + const Offset(12, 8);

      // Less than half the 12pt travel: back to OFF.
      await tester.dragFrom(
        start,
        const Offset(5, 0),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(
        _switchPaint(tester),
        paints
          ..rrect()
          ..rrect()
          ..rrect(rrect: _knob(on: false)),
      );

      final gesture = await tester.startGesture(
        start,
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(4, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(4, 0));
      await tester.pump();
      // The knob follows the pointer: 8pt of the 12pt travel.
      expect(
        _switchPaint(tester),
        paints
          ..rrect()
          ..rrect()
          ..rrect(rrect: _knob(on: false).shift(const Offset(8, 0))),
      );
      expect(changes, isEmpty, reason: 'the value flips on release');
      await gesture.up();
      await tester.pumpAndSettle();
      expect(changes, [true]);
      expect(_switchValue(tester), isTrue);
    });

    testWidgets('snaps back when the parent keeps the old value', (
      tester,
    ) async {
      final changes = await _pumpSwitch(tester, followParent: false);

      await tester.dragFrom(
        tester.getTopLeft(_switch) + const Offset(12, 8),
        const Offset(30, 0),
      );
      await tester.pumpAndSettle();
      expect(changes, [true]);
      expect(
        _switchPaint(tester),
        paints
          ..rrect(color: _offTrackLight)
          ..rrect()
          ..rrect(rrect: _knob(on: false)),
      );
    });

    testWidgets('drags are mirrored in right-to-left layouts', (tester) async {
      final changes = await _pumpSwitch(
        tester,
        textDirection: TextDirection.rtl,
      );
      final start = tester.getTopRight(_switch) + const Offset(-12, 8);

      await tester.dragFrom(start, const Offset(30, 0));
      await tester.pumpAndSettle();
      expect(changes, isEmpty);

      await tester.dragFrom(start, const Offset(-30, 0));
      await tester.pumpAndSettle();
      expect(changes, [true]);
    });

    testWidgets('a disabled switch ignores input and fades its track', (
      tester,
    ) async {
      final changes = await _pumpSwitch(tester, value: true, enabled: false);

      final track = _onTrackLight.withValues(alpha: 1);
      final faded = Color.lerp(track, const Color(0xFF808080), 0.1)!;
      expect(
        _switchPaint(tester),
        paints
          ..rrect(color: faded.withValues(alpha: 0.7))
          ..rrect()
          ..rrect(color: _white),
      );

      await tester.tap(_switch);
      await tester.dragFrom(tester.getCenter(_switch), const Offset(-30, 0));
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
    });

    testWidgets('is a toggle for accessibility', (tester) async {
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
      expect(tester.getSemantics(_switch), isSemantics(isToggled: true));

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

    testWidgets('Space toggles a focused switch, which shows a focus ring', (
      tester,
    ) async {
      final changes = await _pumpSwitch(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      // Track, focus ring, knob shadow, knob.
      expect(
        _switchPaint(tester),
        paints
          ..rrect()
          ..rrect(
            style: PaintingStyle.stroke,
            strokeWidth: 3,
            color: const Color(0x800067F4),
          )
          ..rrect()
          ..rrect(),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(changes, [true]);
    });

    testWidgets('with reduced motion, the knob jumps', (tester) async {
      final changes = await _pumpSwitch(tester, disableAnimations: true);

      await tester.tap(_switch);
      await tester.pump();
      expect(changes, [true]);
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(
        _switchPaint(tester),
        paints
          ..rrect(color: _onTrackLight)
          ..rrect()
          ..rrect(rrect: _knob(on: true)),
      );
    });

    testWidgets('a vertical drag that starts on the switch scrolls', (
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
                child: MacosSettingsSwitch(
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
    });
  });
}
