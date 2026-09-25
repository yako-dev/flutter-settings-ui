import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/sections/platforms/fluent_settings_section.dart';
import 'package:settings_ui/src/tiles/platforms/fluent_settings_tile.dart';

/// Tests for the Windows 11 (Fluent) style: one SettingsCard per tile.

const Color _page = Color(0xFFF3F3F3);
const Color _card = Color(0xFFFBFBFB);
const Color _stroke = Color(0xFFE5E5E5);
const Color _text = Color(0xFF1B1B1B);
const Color _secondary = Color(0xFF5F5F5F);
const Color _disabled = Color(0xFFA0A0A0);

Future<void> _pump(
  WidgetTester tester,
  List<AbstractSettingsSection> sections, {
  Size size = const Size(1100, 900),
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
  double textScale = 1,
  SettingsThemeData? lightTheme,
  SettingsThemeData? darkTheme,
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      // A fresh app each time, so a new theme applies without animating.
      key: UniqueKey(),
      theme: ThemeData(brightness: brightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(textDirection: textDirection, child: child!),
      ),
      home: Scaffold(
        body: SettingsList(
          platform: DevicePlatform.windows,
          lightTheme: lightTheme,
          darkTheme: darkTheme,
          crossAxisAlignment: crossAxisAlignment,
          sections: sections,
        ),
      ),
    ),
  );
}

SettingsSection _section(List<AbstractSettingsTile> tiles, {String? title}) =>
    SettingsSection(title: title == null ? null : Text(title), tiles: tiles);

Finder _tile(String title) =>
    find.ancestor(of: find.text(title), matching: find.byType(SettingsTile));

/// The card of a tile: its painter draws the background, then the border.
RenderObject _cardPaint(WidgetTester tester, String title) =>
    tester.renderObject(
      find
          .descendant(of: _tile(title), matching: find.byType(CustomPaint))
          .first,
    );

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

/// The chevron: the 13x13 CustomPaint of a navigation tile.
Finder _chevron(String title) => find.descendant(
  of: _tile(title),
  matching: find.byWidgetPredicate(
    (widget) => widget is CustomPaint && widget.size == const Size.square(13),
  ),
);

Future<TestGesture> _mouseAt(WidgetTester tester, Offset position) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: position);
  addTearDown(gesture.removePointer);
  await tester.pumpAndSettle();
  return gesture;
}

void fluentStyleTests() {
  group('Page', () {
    testWidgets('default colors, light and dark', (tester) async {
      await _pump(tester, [
        _section([SettingsTile(title: const Text('Tile'))]),
      ]);
      var data = SettingsTheme.of(tester.element(find.text('Tile'))).themeData;
      expect(data.settingsListBackground, _page);
      expect(data.settingsSectionBackground, _card);
      expect(data.dividerColor, _stroke);
      expect(data.tileHighlightColor, const Color(0xFFF5F5F5));
      expect(data.settingsTileTextColor, _text);
      expect(data.titleTextColor, _text);
      expect(data.tileDescriptionTextColor, _secondary);
      expect(data.trailingTextColor, _secondary);
      expect(data.leadingIconsColor, _text);
      expect(data.inactiveTitleColor, _disabled);
      expect(data.inactiveSubtitleColor, _disabled);

      await _pump(tester, [
        _section([SettingsTile(title: const Text('Tile'))]),
      ], brightness: Brightness.dark);
      data = SettingsTheme.of(tester.element(find.text('Tile'))).themeData;
      expect(data.settingsListBackground, const Color(0xFF202020));
      expect(data.settingsSectionBackground, const Color(0xFF2B2B2B));
      expect(data.dividerColor, const Color(0xFF1D1D1D));
      expect(data.tileHighlightColor, const Color(0xFF272727));
      expect(data.settingsTileTextColor, const Color(0xFFFFFFFF));
      expect(data.tileDescriptionTextColor, const Color(0xFFCFCFCF));
      expect(data.inactiveTitleColor, const Color(0xFF787878));
    });

    testWidgets('36 margins and a 1000 column on wide windows', (tester) async {
      await _pump(tester, [
        _section([SettingsTile(title: const Text('Tile'))]),
      ], size: const Size(1100, 900));
      expect(
        tester.getRect(_tile('Tile')),
        const Rect.fromLTWH(50, 20, 1000, 68),
      );

      await _pump(tester, [
        _section([SettingsTile(title: const Text('Tile'))]),
      ], size: const Size(800, 900));
      expect(tester.getRect(_tile('Tile')).left, 36);
      expect(tester.getRect(_tile('Tile')).right, 800 - 36);

      await _pump(
        tester,
        [
          _section([SettingsTile(title: const Text('Tile'))]),
        ],
        size: const Size(1400, 900),
        crossAxisAlignment: CrossAxisAlignment.start,
      );
      expect(tester.getRect(_tile('Tile')).left, 36);
      expect(tester.getRect(_tile('Tile')).width, 1000);
    });

    testWidgets('16 margins below 641, like NavigationView minimal mode', (
      tester,
    ) async {
      await _pump(tester, [
        _section([SettingsTile(title: const Text('Tile'))]),
      ], size: const Size(640, 900));
      expect(tester.getRect(_tile('Tile')).left, 16);
      expect(tester.getRect(_tile('Tile')).right, 640 - 16);
    });

    testWidgets('36 below the last card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: SettingsList(
                platform: DevicePlatform.windows,
                shrinkWrap: true,
                sections: [
                  _section([SettingsTile(title: const Text('Tile'))]),
                ],
              ),
            ),
          ),
        ),
      );
      expect(
        tester.getRect(find.byType(ListView)).bottom -
            tester.getRect(_tile('Tile')).bottom,
        36,
      );
    });
  });

  group('Sections', () {
    testWidgets('BodyStrong headers, margin 1,30,0,6, cards 4 apart', (
      tester,
    ) async {
      await _pump(tester, [
        _section([
          SettingsTile(title: const Text('A1')),
          SettingsTile(title: const Text('A2')),
        ], title: 'First'),
        _section([SettingsTile(title: const Text('B1'))], title: 'Second'),
      ]);

      final style = _styleOf(tester, 'First');
      expect(style.fontSize, 14);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.height, 20 / 14);
      expect(style.color, _text);

      final first = tester.getRect(find.text('First'));
      final a1 = tester.getRect(_tile('A1'));
      final a2 = tester.getRect(_tile('A2'));
      final second = tester.getRect(find.text('Second'));
      final b1 = tester.getRect(_tile('B1'));
      expect(first.top, 30);
      expect(first.left, 51);
      expect(first.height, 20);
      expect(a1.top - first.bottom, 10);
      expect(a2.top - a1.bottom, 4);
      expect(second.top - a2.bottom, 34);
      expect(b1.top - second.bottom, 10);
    });

    testWidgets('an untitled section starts 24 below the previous one', (
      tester,
    ) async {
      await _pump(tester, [
        _section([SettingsTile(title: const Text('A'))]),
        _section([SettingsTile(title: const Text('B'))]),
      ]);
      expect(tester.getRect(_tile('A')).top, 20);
      expect(
        tester.getRect(_tile('B')).top - tester.getRect(_tile('A')).bottom,
        24,
      );
    });

    testWidgets('the header is a semantics header', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, [
        _section([SettingsTile(title: const Text('A'))], title: 'Head'),
      ]);
      expect(
        tester.getSemantics(find.text('Head')),
        isSemantics(label: 'Head', isHeader: true),
      );
      handle.dispose();
    });

    testWidgets('margin and titlePadding replace the defaults', (tester) async {
      await _pump(tester, [
        const SettingsSection(tiles: []),
        SettingsSection(
          margin: const EdgeInsetsDirectional.only(top: 7, start: 5),
          titlePadding: const EdgeInsets.only(bottom: 3),
          title: const Text('Head'),
          tiles: [SettingsTile(title: const Text('A'))],
        ),
      ]);
      expect(find.byType(FluentSettingsSection), findsOneWidget);
      expect(tester.getRect(find.text('Head')).top, 7);
      expect(tester.getRect(find.text('Head')).left, 55);
      expect(
        tester.getRect(_tile('A')).top -
            tester.getRect(find.text('Head')).bottom,
        3,
      );
    });

    testWidgets('custom tiles get a card; custom sections do not', (
      tester,
    ) async {
      await _pump(tester, [
        _section([
          const CustomSettingsTile(
            child: SizedBox(height: 40, child: Text('C')),
          ),
        ]),
        const CustomSettingsSection(child: Text('Free')),
      ]);
      final decorated = tester.widget<DecoratedBox>(
        find
            .ancestor(of: find.text('C'), matching: find.byType(DecoratedBox))
            .first,
      );
      final decoration = decorated.decoration as BoxDecoration;
      expect(decoration.color, _card);
      expect(decoration.border, Border.all(color: _stroke));
      expect(decoration.borderRadius, BorderRadius.circular(4));
      expect(
        find.descendant(
          of: find.byType(SettingsList),
          matching: find.ancestor(
            of: find.text('Free'),
            matching: find.byType(DecoratedBox),
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('an empty section renders nothing', (tester) async {
      await _pump(tester, [
        const SettingsSection(title: Text('Empty'), tiles: []),
      ]);
      expect(find.text('Empty'), findsNothing);
      expect(find.byType(FluentSettingsSection), findsNothing);
    });
  });

  group('Cards', () {
    testWidgets('68 tall, radius 4, 1px border, card colors', (tester) async {
      await _pump(tester, [
        _section([SettingsTile(title: const Text('Tile'))]),
      ]);
      final rect = tester.getRect(_tile('Tile'));
      expect(rect.height, 68);
      final outer = RRect.fromRectAndRadius(
        Offset.zero & rect.size,
        const Radius.circular(4),
      );
      expect(
        _cardPaint(tester, 'Tile'),
        paints
          ..rrect(rrect: outer, color: _card)
          ..drrect(outer: outer, inner: outer.deflate(1), color: _stroke),
      );

      await _pump(tester, [
        _section([SettingsTile(title: const Text('Tile'))]),
      ], brightness: Brightness.dark);
      expect(
        _cardPaint(tester, 'Tile'),
        paints
          ..rrect(color: const Color(0xFF2B2B2B))
          ..drrect(color: const Color(0xFF1D1D1D)),
      );
    });

    testWidgets('text 17 from the edge, 59 with a 20px icon', (tester) async {
      await _pump(tester, [
        _section([
          SettingsTile(title: const Text('Plain')),
          SettingsTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Icon'),
            description: const Text('Description'),
          ),
        ]),
      ]);
      final plain = tester.getRect(_tile('Plain'));
      expect(tester.getRect(find.text('Plain')).left - plain.left, 17);
      expect(tester.getRect(find.text('Plain')).center.dy, plain.center.dy);

      final card = tester.getRect(_tile('Icon'));
      final icon = tester.getRect(find.byIcon(Icons.wifi));
      expect(icon.size, const Size(20, 20));
      expect(icon.left - card.left, 19);
      expect(icon.center.dy, card.center.dy);
      expect(tester.getRect(find.text('Icon')).left - card.left, 59);
      // Body 14/20 over Caption 12/16, 16 padding + 1 border: 70 tall.
      expect(card.height, 70);
      expect(tester.getRect(find.text('Icon')).top - card.top, 17);
      expect(tester.getRect(find.text('Description')).height, 16);
    });

    testWidgets('title Body 14/20, description Caption 12/16', (tester) async {
      await _pump(tester, [
        _section([
          SettingsTile(
            title: const Text('Title'),
            titleDescription: const Text('Below'),
            description: const Text('Description'),
          ),
        ]),
      ]);
      final title = _styleOf(tester, 'Title');
      expect(title.fontSize, 14);
      expect(title.height, 20 / 14);
      expect(title.fontWeight, FontWeight.w400);
      expect(title.color, _text);
      for (final text in ['Below', 'Description']) {
        final style = _styleOf(tester, text);
        expect(style.fontSize, 12);
        expect(style.height, 16 / 12);
        expect(style.color, _secondary);
      }
      expect(
        tester.getRect(find.text('Below')).top,
        tester.getRect(find.text('Title')).bottom,
      );
      expect(
        tester.getRect(find.text('Description')).top,
        tester.getRect(find.text('Below')).bottom,
      );
    });

    testWidgets('value in secondary text, then a 13px chevron 14 after it', (
      tester,
    ) async {
      await _pump(tester, [
        _section([
          SettingsTile.navigation(
            title: const Text('Scale'),
            value: const Text('150%'),
            onPressed: (_) {},
          ),
          SettingsTile(title: const Text('Version'), value: const Text('1.0')),
        ]),
      ]);
      final card = tester.getRect(_tile('Scale'));
      final chevron = tester.getRect(_chevron('Scale'));
      expect(chevron.size, const Size(13, 13));
      expect(card.right - chevron.right, 17);
      expect(chevron.center.dy, card.center.dy);
      expect(chevron.left - tester.getRect(find.text('150%')).right, 14);

      final value = _styleOf(tester, '150%');
      expect(value.fontSize, 14);
      expect(value.color, _secondary);

      // Simple tiles: the value ends at the padding, and there is no chevron.
      expect(_chevron('Version'), findsNothing);
      expect(
        tester.getRect(_tile('Version')).right -
            tester.getRect(find.text('1.0')).right,
        17,
      );
    });

    testWidgets('a long value takes at most half the row, on one line', (
      tester,
    ) async {
      await _pump(tester, [
        _section([
          SettingsTile(title: const Text('Title'), value: Text('Value ' * 40)),
        ]),
      ]);
      expect(tester.takeException(), isNull);
      final card = tester.getRect(_tile('Title'));
      final value = tester.getRect(find.textContaining('Value'));
      expect(value.width, lessThanOrEqualTo((card.width - 34) / 2));
      expect(card.height, 68);
    });

    testWidgets('switch tiles: FluentSettingsSwitch at the end', (
      tester,
    ) async {
      await _pump(tester, [
        _section([
          SettingsTile.switchTile(
            title: const Text('Wi-Fi'),
            initialValue: true,
            onToggle: (_) {},
            activeSwitchColor: Colors.purple,
            trailing: const Text('On'),
          ),
        ]),
      ]);
      final card = tester.getRect(_tile('Wi-Fi'));
      final toggle = tester.getRect(find.byType(FluentSettingsSwitch));
      expect(toggle.size, const Size(40, 20));
      expect(card.right - toggle.right, 17);
      expect(toggle.center.dy, card.center.dy);
      expect(
        tester
            .widget<FluentSettingsSwitch>(find.byType(FluentSettingsSwitch))
            .activeTrackColor,
        Colors.purple,
      );
      // The On/Off label sits 12 before the switch, in Body primary.
      expect(toggle.left - tester.getRect(find.text('On')).right, 12);
      expect(_styleOf(tester, 'On').color, _text);
      expect(_chevron('Wi-Fi'), findsNothing);
    });

    testWidgets('compact tiles are 52 tall', (tester) async {
      await _pump(tester, [
        _section([SettingsTile(title: const Text('Tile'), compact: true)]),
      ]);
      expect(tester.getRect(_tile('Tile')).height, 52);
    });
  });

  group('Narrow cards', () {
    Future<void> pumpAt(WidgetTester tester, double width) => _pump(tester, [
      _section([
        SettingsTile.navigation(
          leading: const Icon(Icons.aspect_ratio),
          title: const Text('Resolution'),
          description: const Text('Fit your display'),
          value: const Text('1920 × 1080'),
          onPressed: (_) {},
        ),
        SettingsTile.switchTile(
          leading: const Icon(Icons.nightlight),
          title: const Text('Night light'),
          initialValue: false,
          onToggle: (_) {},
        ),
      ]),
    ], size: Size(width, 900));

    testWidgets('below 476 the content moves under the header', (tester) async {
      await pumpAt(tester, 440);
      final title = tester.getRect(find.text('Resolution'));
      final description = tester.getRect(find.text('Fit your display'));
      final value = tester.getRect(find.text('1920 × 1080'));
      expect(value.left, title.left);
      expect(value.top - description.bottom, 8);
      // The icon stays centered on the header, the chevron on the card.
      final icon = tester.getRect(find.byIcon(Icons.aspect_ratio));
      expect(icon.center.dy, (title.top + description.bottom) / 2);
      expect(
        tester.getRect(_chevron('Resolution')).center.dy,
        tester.getRect(_tile('Resolution')).center.dy,
      );

      final toggle = tester.getRect(find.byType(FluentSettingsSwitch));
      expect(toggle.left, tester.getRect(find.text('Night light')).left);
      expect(toggle.top - tester.getRect(find.text('Night light')).bottom, 8);
    });

    testWidgets('below 286 the icon is hidden too', (tester) async {
      await pumpAt(tester, 300);
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.aspect_ratio), findsNothing);
      expect(
        tester.getRect(find.text('Resolution')).left -
            tester.getRect(_tile('Resolution')).left,
        17,
      );
    });

    testWidgets('wide cards keep one row', (tester) async {
      await pumpAt(tester, 1100);
      expect(
        tester.getRect(find.text('1920 × 1080')).center.dy,
        tester.getRect(_tile('Resolution')).center.dy,
      );
    });
  });

  group('Interaction', () {
    testWidgets('hover: lighter fill and the elevation border', (tester) async {
      await _pump(tester, [
        _section([
          SettingsTile.navigation(title: const Text('Nav'), onPressed: (_) {}),
          SettingsTile(title: const Text('Static')),
        ]),
      ]);
      final gesture = await _mouseAt(tester, tester.getCenter(_tile('Nav')));
      expect(
        _cardPaint(tester, 'Nav'),
        paints..rrect(color: const Color(0xFFF6F6F6)),
      );

      // Cards that do nothing do not react to the mouse.
      await gesture.moveTo(tester.getCenter(_tile('Static')));
      await tester.pumpAndSettle();
      expect(_cardPaint(tester, 'Static'), paints..rrect(color: _card));
      expect(_cardPaint(tester, 'Nav'), paints..rrect(color: _card));
    });

    testWidgets('hover in dark mode is lighter', (tester) async {
      await _pump(tester, [
        _section([
          SettingsTile.navigation(title: const Text('Nav'), onPressed: (_) {}),
        ]),
      ], brightness: Brightness.dark);
      await _mouseAt(tester, tester.getCenter(_tile('Nav')));
      expect(
        _cardPaint(tester, 'Nav'),
        paints..rrect(color: const Color(0xFF323232)),
      );
    });

    testWidgets('pressed: tileHighlightColor and a secondary header', (
      tester,
    ) async {
      var presses = 0;
      await _pump(tester, [
        _section([
          SettingsTile.navigation(
            leading: const Icon(Icons.wifi),
            title: const Text('Nav'),
            onPressed: (_) => presses++,
          ),
        ]),
      ]);
      final gesture = await tester.startGesture(tester.getCenter(_tile('Nav')));
      await tester.pumpAndSettle();
      expect(
        _cardPaint(tester, 'Nav'),
        paints
          ..rrect(color: const Color(0xFFF5F5F5))
          ..drrect(color: _stroke),
      );
      expect(_styleOf(tester, 'Nav').color, _secondary);
      expect(
        tester
            .widget<IconTheme>(
              find
                  .ancestor(
                    of: find.byIcon(Icons.wifi),
                    matching: find.byType(IconTheme),
                  )
                  .first,
            )
            .data
            .color,
        _secondary,
      );

      await gesture.up();
      await tester.pumpAndSettle();
      expect(presses, 1);
      expect(_cardPaint(tester, 'Nav'), paints..rrect(color: _card));
    });

    testWidgets('keyboard: Tab focuses clickable cards, Enter activates', (
      tester,
    ) async {
      var presses = 0;
      await _pump(tester, [
        _section([
          SettingsTile(title: const Text('Static')),
          SettingsTile.navigation(
            title: const Text('Nav'),
            onPressed: (_) => presses++,
          ),
        ]),
      ]);
      expect(
        _cardPaint(tester, 'Nav'),
        isNot(
          paints
            ..drrect()
            ..drrect(),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final size = tester.getSize(_tile('Nav'));
      final edge = RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(4),
      );
      // The border, then the 2px outer and 1px inner focus rings.
      expect(
        _cardPaint(tester, 'Nav'),
        paints
          ..drrect()
          ..drrect(
            outer: edge.inflate(3),
            inner: edge.inflate(1),
            color: const Color(0xE4000000),
          )
          ..drrect(
            outer: edge.inflate(1),
            inner: edge,
            color: const Color(0xB3FFFFFF),
          ),
      );
      expect(
        _cardPaint(tester, 'Static'),
        isNot(
          paints
            ..drrect()
            ..drrect(),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(presses, 2);
    });

    testWidgets('switch tiles: the switch toggles, the row calls onPressed', (
      tester,
    ) async {
      final toggles = <bool>[];
      var presses = 0;
      await _pump(tester, [
        _section([
          SettingsTile.switchTile(
            title: const Text('Night light'),
            initialValue: false,
            onToggle: toggles.add,
            onPressed: (_) => presses++,
          ),
        ]),
      ]);
      await tester.tap(find.byType(FluentSettingsSwitch));
      await tester.pumpAndSettle();
      expect(toggles, [true]);
      expect(presses, 0);

      await tester.tap(find.text('Night light'));
      await tester.pumpAndSettle();
      expect(toggles, [true]);
      expect(presses, 1);
    });

    testWidgets('pressing the switch does not press the card', (tester) async {
      await _pump(tester, [
        _section([
          SettingsTile.switchTile(
            title: const Text('Night light'),
            initialValue: false,
            onToggle: (_) {},
            onPressed: (_) {},
          ),
        ]),
      ]);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(FluentSettingsSwitch)),
      );
      await tester.pumpAndSettle();
      expect(_cardPaint(tester, 'Night light'), paints..rrect(color: _card));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('disabled: disabled colors and no taps', (tester) async {
      var presses = 0;
      final toggles = <bool>[];
      await _pump(tester, [
        _section([
          SettingsTile.navigation(
            leading: const Icon(Icons.mail),
            title: const Text('Email'),
            description: const Text('Description'),
            value: const Text('Value'),
            enabled: false,
            onPressed: (_) => presses++,
          ),
          SettingsTile.switchTile(
            title: const Text('Wi-Fi'),
            initialValue: true,
            onToggle: toggles.add,
            enabled: false,
          ),
        ]),
      ]);
      expect(_styleOf(tester, 'Email').color, _disabled);
      expect(_styleOf(tester, 'Description').color, _disabled);
      expect(_styleOf(tester, 'Value').color, _disabled);
      expect(
        _cardPaint(tester, 'Email'),
        paints..rrect(color: const Color(0xFFF5F5F5)),
      );
      expect(
        tester
            .widget<FluentSettingsSwitch>(find.byType(FluentSettingsSwitch))
            .onChanged,
        isNull,
      );

      await tester.tap(find.text('Email'), warnIfMissed: false);
      await tester.tap(find.byType(FluentSettingsSwitch), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(presses, 0);
      expect(toggles, isEmpty);
    });
  });

  group('Layout directions and text size', () {
    testWidgets('right-to-left mirrors the card', (tester) async {
      await _pump(tester, [
        _section([
          SettingsTile.navigation(
            leading: const Icon(Icons.wifi),
            title: const Text('Nav'),
            value: const Text('Value'),
            onPressed: (_) {},
          ),
        ], title: 'Head'),
      ], textDirection: TextDirection.rtl);
      final card = tester.getRect(_tile('Nav'));
      expect(card.right - tester.getRect(find.byIcon(Icons.wifi)).right, 19);
      expect(card.right - tester.getRect(find.text('Nav')).right, 59);
      expect(tester.getRect(_chevron('Nav')).left - card.left, 17);
      expect(
        tester.getRect(find.text('Value')).left -
            tester.getRect(_chevron('Nav')).right,
        14,
      );
      expect(card.right - tester.getRect(find.text('Head')).right, 1);
    });

    for (final width in [360.0, 1100.0]) {
      testWidgets('text scale 2.0 does not overflow at $width', (tester) async {
        await _pump(
          tester,
          [
            _section([
              SettingsTile.navigation(
                leading: const Icon(Icons.wifi),
                title: const Text('A rather long setting title here'),
                description: const Text(
                  'And a description that needs a couple of lines',
                ),
                value: const Text('A long value'),
                onPressed: (_) {},
              ),
              SettingsTile.switchTile(
                leading: const Icon(Icons.bluetooth),
                title: const Text('Bluetooth devices'),
                trailing: const Text('Off'),
                initialValue: false,
                onToggle: (_) {},
              ),
              SettingsTile(
                title: const Text('Version'),
                value: const Text('1.0'),
              ),
            ], title: 'Section header'),
          ],
          size: Size(width, 1600),
          textScale: 2,
        );
        expect(tester.takeException(), isNull);
        expect(tester.getRect(_tile('Version')).height, greaterThan(68));
      });
    }
  });

  group('Overrides', () {
    testWidgets('SettingsThemeData fields reach the cards', (tester) async {
      const theme = SettingsThemeData(
        settingsListBackground: Color(0xFF000001),
        settingsSectionBackground: Color(0xFFEEEEEE),
        dividerColor: Color(0xFF000003),
        tileHighlightColor: Color(0xFF000004),
        titleTextColor: Color(0xFF000005),
        settingsTileTextColor: Color(0xFF000006),
        tileDescriptionTextColor: Color(0xFF000007),
        trailingTextColor: Color(0xFF000008),
        leadingIconsColor: Color(0xFF000009),
        inactiveTitleColor: Color(0xFF00000A),
        inactiveSubtitleColor: Color(0xFF00000B),
        titleTextStyle: TextStyle(fontSize: 21),
        tileTextStyle: TextStyle(fontSize: 22),
        tileDescriptionTextStyle: TextStyle(fontSize: 23),
      );
      await _pump(tester, [
        _section([
          SettingsTile.navigation(
            leading: const Icon(Icons.wifi),
            title: const Text('Nav'),
            description: const Text('Description'),
            value: const Text('Value'),
            onPressed: (_) {},
          ),
          SettingsTile(
            title: const Text('Off'),
            description: const Text('Gone'),
            enabled: false,
          ),
        ], title: 'Head'),
      ], lightTheme: theme);

      expect(
        tester
            .widget<Container>(
              find
                  .ancestor(
                    of: find.byType(ListView).first,
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .color,
        const Color(0xFF000001),
      );
      expect(
        _cardPaint(tester, 'Nav'),
        paints
          ..rrect(color: const Color(0xFFEEEEEE))
          ..drrect(color: const Color(0xFF000003)),
      );
      expect(_styleOf(tester, 'Head').color, const Color(0xFF000005));
      expect(_styleOf(tester, 'Head').fontSize, 21);
      expect(_styleOf(tester, 'Nav').color, const Color(0xFF000006));
      expect(_styleOf(tester, 'Nav').fontSize, 22);
      expect(_styleOf(tester, 'Description').color, const Color(0xFF000007));
      expect(_styleOf(tester, 'Description').fontSize, 23);
      expect(_styleOf(tester, 'Value').color, const Color(0xFF000008));
      expect(
        tester
            .widget<IconTheme>(
              find
                  .ancestor(
                    of: find.byIcon(Icons.wifi),
                    matching: find.byType(IconTheme),
                  )
                  .first,
            )
            .data
            .color,
        const Color(0xFF000009),
      );
      expect(
        tester.renderObject(_chevron('Nav')),
        paints..path(color: const Color(0xFF000009)),
      );
      expect(_styleOf(tester, 'Off').color, const Color(0xFF00000A));
      expect(_styleOf(tester, 'Gone').color, const Color(0xFF00000B));

      final gesture = await tester.startGesture(tester.getCenter(_tile('Nav')));
      await tester.pumpAndSettle();
      expect(
        _cardPaint(tester, 'Nav'),
        paints..rrect(color: const Color(0xFF000004)),
      );
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('padding parameters replace the defaults', (tester) async {
      await _pump(tester, [
        _section([
          SettingsTile(
            leading: const Icon(Icons.wifi),
            title: const Text('Title'),
            titleDescription: const Text('Below'),
            description: const Text('Description'),
            trailing: const Icon(Icons.star),
            leadingPadding: const EdgeInsets.all(1),
            titlePadding: const EdgeInsets.all(2),
            titleDescriptionPadding: const EdgeInsets.all(3),
            descriptionPadding: const EdgeInsets.all(4),
            trailingPadding: const EdgeInsets.all(5),
          ),
        ]),
      ]);
      EdgeInsetsGeometry paddingAround(Finder finder) => tester
          .widget<Padding>(
            find.ancestor(of: finder, matching: find.byType(Padding)).first,
          )
          .padding;
      expect(paddingAround(find.byIcon(Icons.wifi)), const EdgeInsets.all(1));
      expect(paddingAround(find.text('Title')), const EdgeInsets.all(2));
      expect(paddingAround(find.text('Below')), const EdgeInsets.all(3));
      expect(paddingAround(find.text('Description')), const EdgeInsets.all(4));
      expect(paddingAround(find.byIcon(Icons.star)), const EdgeInsets.all(5));
    });
  });

  group('Semantics', () {
    testWidgets('a switch tile reads as one toggle', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, [
        _section([
          SettingsTile.switchTile(
            title: const Text('Wi-Fi'),
            description: const Text('Connect automatically'),
            initialValue: true,
            onToggle: (_) {},
          ),
        ]),
      ]);
      expect(
        tester.getSemantics(find.text('Wi-Fi')),
        isSemantics(
          label: 'Wi-Fi\nConnect automatically',
          hasToggledState: true,
          isToggled: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('a clickable card is a button', (tester) async {
      final handle = tester.ensureSemantics();
      var presses = 0;
      await _pump(tester, [
        _section([
          SettingsTile.navigation(
            title: const Text('Display'),
            value: const Text('1080p'),
            onPressed: (_) => presses++,
          ),
        ]),
      ]);
      expect(
        tester.getSemantics(find.text('Display')),
        isSemantics(
          label: 'Display\n1080p',
          isButton: true,
          hasTapAction: true,
          isFocusable: true,
        ),
      );
      tester.semantics.tap(find.semantics.byLabel('Display\n1080p'));
      await tester.pumpAndSettle();
      expect(presses, 1);
      handle.dispose();
    });
  });

  testWidgets('dispatch: FluentSettingsTile for Windows', (tester) async {
    await _pump(tester, [
      _section([SettingsTile(title: const Text('Tile'))]),
    ]);
    expect(find.byType(FluentSettingsSection), findsOneWidget);
    expect(find.byType(FluentSettingsTile), findsOneWidget);
  });
}
