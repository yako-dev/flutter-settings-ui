import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/settings_ui.dart' as settings_ui;
import 'package:settings_ui/src/sections/platforms/adwaita_settings_section.dart';
import 'package:settings_ui/src/tiles/platforms/adwaita_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/adwaita_symbolic_icons.dart';

/// Tests for the GNOME (libadwaita 1.10) style used for DevicePlatform.linux.

const _lightForeground = Color.fromRGBO(0, 0, 6, 0.8);
const _white = Color(0xFFFFFFFF);
const _accent = Color(0xFF3584E4);

Future<void> _pump(
  WidgetTester tester,
  List<AbstractSettingsSection> sections, {
  Size size = const Size(800, 1200),
  Brightness? brightness,
  SettingsThemeData? lightTheme,
  SettingsThemeData? darkTheme,
  TextDirection direction = TextDirection.ltr,
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  EdgeInsetsGeometry? contentPadding,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: SettingsList(
            platform: DevicePlatform.linux,
            brightness: brightness,
            lightTheme: lightTheme,
            darkTheme: darkTheme,
            crossAxisAlignment: crossAxisAlignment,
            contentPadding: contentPadding,
            sections: sections,
          ),
        ),
      ),
    ),
  );
}

Future<void> _pumpTiles(
  WidgetTester tester,
  List<AbstractSettingsTile> tiles, {
  Widget? title,
  Size size = const Size(800, 1200),
  Brightness? brightness,
  SettingsThemeData? lightTheme,
  TextDirection direction = TextDirection.ltr,
}) => _pump(
  tester,
  [SettingsSection(title: title, tiles: tiles)],
  size: size,
  brightness: brightness,
  lightTheme: lightTheme,
  direction: direction,
);

SettingsThemeData _theme(WidgetTester tester) => SettingsTheme.of(
  tester.element(find.byType(SettingsSection).first),
).themeData;

Rect _card(WidgetTester tester, [int index = 0]) =>
    tester.getRect(find.byType(AdwaitaBoxedList).at(index));

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

/// The decoration of a tile's row background (hover and pressed colors).
AnimatedContainer _rowOf(WidgetTester tester, String title) =>
    tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.ancestor(
          of: find.text(title),
          matching: find.byType(AdwaitaSettingsTile),
        ),
        matching: find.byType(AnimatedContainer),
      ),
    );

Color? _rowColor(WidgetTester tester, String title) =>
    (_rowOf(tester, title).decoration as BoxDecoration?)?.color;

void _useTraditionalHighlights() {
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  addTearDown(
    () => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.automatic,
  );
}

List<SettingsTile> _tiles(int count) => [
  for (var i = 0; i < count; i++) SettingsTile(title: Text('Tile $i')),
];

void adwaitaStyleTests() {
  group('theme', () {
    testWidgets('light colors follow libadwaita', (tester) async {
      await _pumpTiles(tester, _tiles(1), brightness: Brightness.light);
      final theme = _theme(tester);

      expect(theme.settingsListBackground, const Color(0xFFFAFAFB));
      expect(theme.settingsSectionBackground, _white);
      expect(theme.dividerColor, const Color.fromRGBO(0, 0, 6, 0.07));
      expect(theme.settingsTileTextColor, _lightForeground);
      expect(theme.titleTextColor, _lightForeground);
      expect(theme.leadingIconsColor, _lightForeground);
      expect(theme.tileDescriptionTextColor!.a, closeTo(0.8 * 0.55, 1e-3));
      expect(theme.trailingTextColor!.a, closeTo(0.8 * 0.55, 1e-3));
      expect(theme.tileHighlightColor!.a, closeTo(0.8 * 0.08, 1e-3));
      expect(theme.inactiveTitleColor!.a, closeTo(0.8 * 0.5, 1e-3));
    });

    testWidgets('dark colors follow libadwaita', (tester) async {
      await _pumpTiles(tester, _tiles(1), brightness: Brightness.dark);
      final theme = _theme(tester);

      expect(theme.settingsListBackground, const Color(0xFF222226));
      expect(
        theme.settingsSectionBackground,
        const Color.fromRGBO(255, 255, 255, 0.08),
      );
      expect(theme.dividerColor, const Color.fromRGBO(0, 0, 6, 0.36));
      expect(theme.settingsTileTextColor, _white);
      expect(theme.tileDescriptionTextColor, _white.withValues(alpha: 0.55));
      expect(theme.tileHighlightColor, _white.withValues(alpha: 0.08));
    });

    testWidgets('the ColorScheme does not change the colors', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorSchemeSeed: Colors.red),
          home: Scaffold(
            body: SettingsList(
              platform: DevicePlatform.linux,
              sections: [SettingsSection(tiles: _tiles(1))],
            ),
          ),
        ),
      );
      expect(_theme(tester).settingsListBackground, const Color(0xFFFAFAFB));
      expect(_theme(tester).settingsTileTextColor, _lightForeground);
    });

    testWidgets('user themes override every default', (tester) async {
      const custom = SettingsThemeData(
        settingsListBackground: Colors.grey,
        settingsSectionBackground: Colors.teal,
        dividerColor: Colors.pink,
        titleTextColor: Colors.cyan,
        settingsTileTextColor: Colors.green,
        tileDescriptionTextColor: Colors.blue,
        trailingTextColor: Colors.orange,
        leadingIconsColor: Colors.red,
        tileHighlightColor: Colors.yellow,
        titleTextStyle: TextStyle(fontSize: 21),
        tileTextStyle: TextStyle(fontSize: 19),
        tileDescriptionTextStyle: TextStyle(fontSize: 11),
      );
      await _pumpTiles(
        tester,
        [
          SettingsTile.navigation(
            leading: const Icon(Icons.wifi),
            title: const Text('Title'),
            description: const Text('Subtitle'),
            value: const Text('Value'),
            onPressed: (_) {},
          ),
          SettingsTile(title: const Text('Second')),
        ],
        title: const Text('Group'),
        lightTheme: custom,
      );

      expect(
        tester
            .widget<ColoredBox>(
              find
                  .descendant(
                    of: find.byType(SettingsList),
                    matching: find.byType(ColoredBox),
                  )
                  .first,
            )
            .color,
        Colors.grey,
      );
      final card = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(AdwaitaBoxedList),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(card.color, Colors.teal);
      final separator = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(AdwaitaBoxedList),
              matching: find.byType(ColoredBox),
            )
            .last,
      );
      expect(separator.color, Colors.pink);
      expect(_styleOf(tester, 'Group').color, Colors.cyan);
      expect(_styleOf(tester, 'Group').fontSize, 21);
      expect(_styleOf(tester, 'Title').color, Colors.green);
      expect(_styleOf(tester, 'Title').fontSize, 19);
      expect(_styleOf(tester, 'Subtitle').color, Colors.blue);
      expect(_styleOf(tester, 'Subtitle').fontSize, 11);
      expect(_styleOf(tester, 'Value').color, Colors.orange);
      final icon = tester.widget<IconTheme>(
        find
            .ancestor(
              of: find.byIcon(Icons.wifi),
              matching: find.byType(IconTheme),
            )
            .first,
      );
      expect(icon.data.color, Colors.red);
      final arrow = tester.widget<AdwaitaGoNextIcon>(
        find.byType(AdwaitaGoNextIcon),
      );
      expect(arrow.color, Colors.red);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Title')),
      );
      await tester.pumpAndSettle();
      expect(_rowColor(tester, 'Title'), Colors.yellow);
      await gesture.up();
    });

    testWidgets('the brightness of the list picks light or dark switches', (
      tester,
    ) async {
      await _pumpTiles(tester, [
        SettingsTile.switchTile(
          title: const Text('Switch'),
          initialValue: false,
          onToggle: (_) {},
        ),
      ], brightness: Brightness.dark);

      expect(
        tester
            .widget<AdwaitaSettingsSwitch>(find.byType(AdwaitaSettingsSwitch))
            .brightness,
        Brightness.dark,
      );
    });
  });

  group('layout', () {
    testWidgets('cards have 12 px corners, 12 px side margins, 24 px on top', (
      tester,
    ) async {
      await _pumpTiles(tester, _tiles(1), size: const Size(360, 800));

      final clip = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(AdwaitaBoxedList),
          matching: find.byType(ClipRRect),
        ),
      );
      expect(clip.borderRadius, BorderRadius.circular(12));
      expect(_card(tester), const Rect.fromLTWH(12, 24, 336, 54));
    });

    for (final (width, card) in [
      (360.0, 336.0),
      (400.0, 376.0),
      (700.0, 575.0 - 24),
      (1000.0, 576.0),
      (1600.0, 576.0),
    ]) {
      testWidgets('the content is clamped like AdwClamp at $width px', (
        tester,
      ) async {
        await _pumpTiles(tester, _tiles(1), size: Size(width, 800));
        expect(_card(tester).width, moreOrLessEquals(card, epsilon: 0.01));
        expect(_card(tester).center.dx, width / 2);
      });
    }

    test('adwaitaClampWidth eases from the threshold to the maximum', () {
      expect(adwaitaClampWidth(300), 300);
      expect(adwaitaClampWidth(400), 400);
      // 400 + 200 * easeOutCubic(0.5)
      expect(adwaitaClampWidth(700), 575);
      expect(adwaitaClampWidth(1000), 600);
      expect(adwaitaClampWidth(5000), 600);
      expect(
        adwaitaClampWidth(700, maximumSize: 1200, tighteningThreshold: 800),
        700,
      );
      // The width only grows.
      var previous = 0.0;
      for (var w = 0.0; w < 1200; w += 7) {
        final clamped = adwaitaClampWidth(w);
        expect(clamped, greaterThanOrEqualTo(previous));
        expect(clamped, lessThanOrEqualTo(w));
        previous = clamped;
      }
    });

    testWidgets('the clamp grows with the text scale (sp)', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pumpTiles(tester, _tiles(1), size: const Size(800, 1200));
      // Below the 800 sp threshold: all the width, minus the margins.
      expect(_card(tester).width, 776);
    });

    testWidgets('crossAxisAlignment.start puts the column at the start', (
      tester,
    ) async {
      await _pump(
        tester,
        [SettingsSection(tiles: _tiles(1))],
        size: const Size(1400, 800),
        crossAxisAlignment: CrossAxisAlignment.start,
      );
      expect(_card(tester).left, 12);
      expect(_card(tester).width, 576);
    });

    testWidgets('contentPadding replaces the page padding', (tester) async {
      await _pump(
        tester,
        [SettingsSection(tiles: _tiles(1))],
        size: const Size(1400, 800),
        contentPadding: EdgeInsets.zero,
      );
      expect(_card(tester), const Rect.fromLTWH(12, 0, 1376, 54));
    });

    testWidgets('rows are 54 tall with full-width 1 px separators', (
      tester,
    ) async {
      await _pumpTiles(tester, [
        SettingsTile(title: const Text('One')),
        SettingsTile(
          title: const Text('Two'),
          description: const Text('With a subtitle'),
        ),
        SettingsTile.switchTile(
          title: const Text('Three'),
          initialValue: true,
          onToggle: (_) {},
        ),
      ], size: const Size(600, 800));

      final card = _card(tester);
      final rows = [
        for (final title in ['One', 'Two', 'Three'])
          tester.getRect(
            find.ancestor(
              of: find.text(title),
              matching: find.byType(AdwaitaSettingsTile),
            ),
          ),
      ];
      for (final row in rows) {
        expect(row.height, 54);
        expect(row.width, card.width);
      }
      expect(rows[1].top - rows[0].bottom, 1);
      expect(rows[2].top - rows[1].bottom, 1);
      expect(card.height, 3 * 54 + 2);

      final separators = tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(AdwaitaBoxedList),
              matching: find.byWidgetPredicate(
                (w) => w is SizedBox && w.height == 1,
              ),
            ),
          )
          .toList();
      expect(separators, hasLength(2));
    });

    testWidgets('text starts 14 px in, or 12 px after a 16 px icon', (
      tester,
    ) async {
      await _pumpTiles(tester, [
        SettingsTile(title: const Text('Plain')),
        SettingsTile(
          leading: const Icon(Icons.wifi),
          title: const Text('Icon'),
        ),
      ], size: const Size(600, 800));

      final card = _card(tester);
      expect(tester.getTopLeft(find.text('Plain')).dx - card.left, 14);
      final icon = tester.getRect(find.byIcon(Icons.wifi));
      expect(icon.size, const Size(16, 16));
      expect(icon.left - card.left, 14);
      expect(tester.getTopLeft(find.text('Icon')).dx - card.left, 42);
      expect(
        tester.getCenter(find.text('Icon')).dy,
        moreOrLessEquals(icon.center.dy, epsilon: 0.5),
      );
    });

    testWidgets('a group title is 34 tall, 6 above the card, 24 apart', (
      tester,
    ) async {
      await _pump(tester, [
        SettingsSection(title: const Text('First'), tiles: _tiles(2)),
        SettingsSection(title: const Text('Second'), tiles: _tiles(1)),
        SettingsSection(tiles: [SettingsTile(title: const Text('Third'))]),
      ], size: const Size(600, 1000));

      final first = tester.getRect(find.text('First'));
      expect(first.left, _card(tester, 0).left);
      expect(first.height, 18);
      // Centered in the 34 tall title row, 24 below the top.
      expect(first.top, 24 + (34 - 18) / 2);
      expect(_card(tester, 0).top, 24 + 34 + 6);

      final second = tester.getRect(find.text('Second'));
      expect(second.top - (34 - 18) / 2 - _card(tester, 0).bottom, 24);
      expect(_card(tester, 1).top - _card(tester, 0).bottom, 24 + 34 + 6);
      // Without a title, the card is 24 below the previous one.
      expect(_card(tester, 2).top - _card(tester, 1).bottom, 24);
    });

    testWidgets('the group title is bold 14.67 px and marked as a header', (
      tester,
    ) async {
      await _pumpTiles(tester, _tiles(1), title: const Text('Behavior'));
      final style = _styleOf(tester, 'Behavior');
      expect(style.fontSize, closeTo(14.67, 0.01));
      expect(style.fontWeight, FontWeight.w700);
      expect(style.color, _lightForeground);

      expect(
        tester.getSemantics(find.text('Behavior')),
        isSemantics(label: 'Behavior', isHeader: true),
      );
    });

    testWidgets('margin and titlePadding replace the defaults', (tester) async {
      await _pump(tester, [
        SettingsSection(
          title: const Text('Group'),
          margin: const EdgeInsetsDirectional.only(start: 40, end: 30),
          titlePadding: const EdgeInsets.only(bottom: 20),
          tiles: _tiles(1),
        ),
      ], size: const Size(360, 800));

      expect(_card(tester).left, 40);
      expect(_card(tester).right, 330);
      expect(_card(tester).top, 24 + 34 + 20);
    });

    testWidgets('compact rows are 36 tall', (tester) async {
      await _pumpTiles(tester, [
        SettingsTile(title: const Text('Compact'), compact: true),
      ]);
      expect(
        tester
            .getSize(
              find.ancestor(
                of: find.text('Compact'),
                matching: find.byType(AdwaitaSettingsTile),
              ),
            )
            .height,
        36,
      );
    });

    testWidgets('empty sections render nothing', (tester) async {
      await _pump(tester, [
        const SettingsSection(title: Text('Empty'), tiles: []),
        SettingsSection(tiles: _tiles(1)),
      ]);
      expect(find.text('Empty'), findsNothing);
      expect(find.byType(AdwaitaBoxedList), findsOneWidget);
      expect(_card(tester).top, 24);
    });

    testWidgets('custom tiles and sections', (tester) async {
      await _pump(tester, [
        SettingsSection(
          tiles: [
            const CustomSettingsTile(child: SizedBox(height: 80)),
            SettingsTile(title: const Text('After')),
          ],
        ),
        const CustomSettingsSection(child: Text('Custom section')),
      ]);

      // A custom tile sits in the card like a row, with a separator.
      expect(
        find.descendant(
          of: find.byType(AdwaitaBoxedList),
          matching: find.byType(CustomSettingsTile),
        ),
        findsOneWidget,
      );
      final separators = find.descendant(
        of: find.byType(AdwaitaBoxedList),
        matching: find.byWidgetPredicate((w) => w is SizedBox && w.height == 1),
      );
      expect(separators, findsOneWidget);
      expect(find.text('Custom section'), findsOneWidget);
      expect(find.byType(AdwaitaBoxedList), findsOneWidget);
    });
  });

  group('tiles', () {
    testWidgets('titles are 14.67 px and subtitles 12.22 px, dimmed', (
      tester,
    ) async {
      await _pumpTiles(tester, [
        SettingsTile(
          title: const Text('Title'),
          titleDescription: const Text('Title description'),
          description: const Text('Description'),
        ),
      ]);

      final title = _styleOf(tester, 'Title');
      expect(title.fontSize, closeTo(14.67, 0.01));
      expect(title.fontWeight, FontWeight.w400);
      expect(title.color, _lightForeground);
      for (final text in ['Title description', 'Description']) {
        final style = _styleOf(tester, text);
        expect(style.fontSize, closeTo(12.22, 0.01));
        expect(style.color!.a, closeTo(0.8 * 0.55, 1e-3));
      }
      // Both subtitles go under the title, the title description first.
      final t = tester.getRect(find.text('Title'));
      final td = tester.getRect(find.text('Title description'));
      final d = tester.getRect(find.text('Description'));
      expect(td.top - t.bottom, 3);
      expect(d.top - td.bottom, 3);
      expect(td.left, t.left);
      expect(d.left, t.left);
    });

    testWidgets('navigation rows end with go-next, others do not', (
      tester,
    ) async {
      await _pumpTiles(tester, [
        SettingsTile.navigation(title: const Text('Next'), onPressed: (_) {}),
        SettingsTile(title: const Text('Simple')),
        SettingsTile.switchTile(
          title: const Text('Switch'),
          initialValue: false,
          onToggle: (_) {},
        ),
      ], size: const Size(600, 800));

      expect(find.byType(AdwaitaGoNextIcon), findsOneWidget);
      final arrow = tester.getRect(find.byType(AdwaitaGoNextIcon));
      expect(arrow.size, const Size(16, 16));
      expect(_card(tester).right - arrow.right, 14);
      expect(
        arrow.center.dy,
        moreOrLessEquals(tester.getCenter(find.text('Next')).dy, epsilon: 0.5),
      );
    });

    testWidgets('a value is a dimmed label before the arrow', (tester) async {
      await _pumpTiles(tester, [
        SettingsTile.navigation(
          title: const Text('Language'),
          value: const Text('English'),
          onPressed: (_) {},
        ),
        SettingsTile(title: const Text('Version'), value: const Text('51.0')),
      ], size: const Size(600, 800));

      expect(_styleOf(tester, 'English').color!.a, closeTo(0.44, 1e-3));
      expect(_styleOf(tester, 'English').fontSize, closeTo(14.67, 0.01));
      final value = tester.getRect(find.text('English'));
      final arrow = tester.getRect(find.byType(AdwaitaGoNextIcon));
      expect(arrow.left - value.right, 6);
      expect(_card(tester).right - tester.getRect(find.text('51.0')).right, 14);
    });

    testWidgets('long titles and values share the row without overflow', (
      tester,
    ) async {
      await _pumpTiles(tester, [
        SettingsTile.navigation(
          leading: const Icon(Icons.language),
          title: const Text(
            'A very long title that needs to wrap onto more lines',
          ),
          value: const Text('A very long value that is cut with an ellipsis'),
          onPressed: (_) {},
        ),
      ], size: const Size(320, 800));

      expect(tester.takeException(), isNull);
      final value = tester.getRect(find.textContaining('A very long value'));
      final card = tester.getRect(find.byType(AdwaitaBoxedList));
      expect(value.width, lessThanOrEqualTo((card.width - 28) / 2));
    });

    testWidgets('no overflow at text scale 2.0', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pump(tester, [
        SettingsSection(
          title: const Text('A long group title for a narrow window'),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(Icons.language),
              title: const Text('Language and region settings'),
              description: const Text('The language of the whole system'),
              value: const Text('English (United States)'),
              trailing: const Icon(Icons.star),
              onPressed: (_) {},
            ),
            SettingsTile.switchTile(
              leading: const Icon(Icons.wifi),
              title: const Text('Automatic Suspend when idle'),
              description: const Text('Pause the computer when inactive'),
              initialValue: true,
              onToggle: (_) {},
            ),
            SettingsTile(
              title: const Text('Compact'),
              value: const Text('Value'),
              compact: true,
            ),
          ],
        ),
      ], size: const Size(320, 1600));

      expect(tester.takeException(), isNull);
      // Rows grow with the text.
      final row = tester.getSize(
        find.ancestor(
          of: find.text('Language and region settings'),
          matching: find.byType(AdwaitaSettingsTile),
        ),
      );
      expect(row.height, greaterThan(54));
    });

    testWidgets('paddings given to the tile are used', (tester) async {
      EdgeInsetsGeometry paddingAround(Finder finder) => tester
          .widget<Padding>(
            find.ancestor(of: finder, matching: find.byType(Padding)).first,
          )
          .padding;

      await _pumpTiles(tester, [
        SettingsTile(
          leading: const Icon(Icons.wifi),
          trailing: const Icon(Icons.star),
          title: const Text('Title'),
          titleDescription: const Text('Below'),
          description: const Text('Description'),
          titlePadding: const EdgeInsets.all(3),
          leadingPadding: const EdgeInsets.all(4),
          trailingPadding: const EdgeInsets.all(5),
          titleDescriptionPadding: const EdgeInsets.all(7),
          descriptionPadding: const EdgeInsets.all(11),
        ),
      ]);

      expect(paddingAround(find.text('Title')), const EdgeInsets.all(3));
      expect(paddingAround(find.byIcon(Icons.wifi)), const EdgeInsets.all(4));
      expect(paddingAround(find.byIcon(Icons.star)), const EdgeInsets.all(5));
      expect(paddingAround(find.text('Below')), const EdgeInsets.all(7));
      expect(paddingAround(find.text('Description')), const EdgeInsets.all(11));
    });

    testWidgets('text in trailing gets the title style', (tester) async {
      await _pumpTiles(tester, [
        SettingsTile(title: const Text('On'), trailing: const Text('Suspend')),
        SettingsTile(
          title: const Text('Off'),
          trailing: const Text('Hibernate'),
          enabled: false,
        ),
      ]);
      final style = _styleOf(tester, 'Suspend');
      expect(style.fontSize, closeTo(14.67, 0.01));
      expect(style.color, _lightForeground);
      expect(
        _styleOf(tester, 'Hibernate').color,
        _theme(tester).inactiveTitleColor,
      );
    });

    testWidgets('a combo row: value, 9 px, then pan-down 14 px from the edge', (
      tester,
    ) async {
      await _pumpTiles(tester, [
        SettingsTile(
          title: const Text('Screen Blank'),
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('5 minutes'),
              SizedBox(width: 9),
              AdwaitaPanDownIcon(),
            ],
          ),
          onPressed: (_) {},
        ),
      ], size: const Size(600, 800));

      final card = _card(tester);
      final arrow = tester.getRect(find.byType(AdwaitaPanDownIcon));
      expect(arrow.size, const Size(16, 16));
      expect(card.right - arrow.right, 14);
      expect(arrow.left - tester.getRect(find.text('5 minutes')).right, 9);
      expect(
        arrow.center.dy,
        moreOrLessEquals(
          tester.getCenter(find.text('Screen Blank')).dy,
          epsilon: 0.5,
        ),
      );
    });

    testWidgets('trailing widgets get the 16 px foreground icon theme', (
      tester,
    ) async {
      await _pumpTiles(tester, [
        SettingsTile(
          title: const Text('Title'),
          trailing: const Icon(Icons.star),
        ),
      ]);
      expect(tester.getSize(find.byIcon(Icons.star)), const Size(16, 16));
    });

    testWidgets('disabled rows are dimmed and ignore taps', (tester) async {
      var pressed = false;
      var toggled = false;
      await _pumpTiles(tester, [
        SettingsTile.navigation(
          leading: const Icon(Icons.mail),
          title: const Text('Email'),
          value: const Text('Value'),
          description: const Text('Subtitle'),
          enabled: false,
          onPressed: (_) => pressed = true,
        ),
        SettingsTile.switchTile(
          title: const Text('Switch'),
          initialValue: true,
          enabled: false,
          onToggle: (_) => toggled = true,
        ),
      ]);

      final theme = _theme(tester);
      expect(_styleOf(tester, 'Email').color, theme.inactiveTitleColor);
      expect(_styleOf(tester, 'Value').color, theme.inactiveSubtitleColor);
      expect(_styleOf(tester, 'Subtitle').color, theme.inactiveSubtitleColor);
      final icon = tester.widget<IconTheme>(
        find
            .ancestor(
              of: find.byIcon(Icons.mail),
              matching: find.byType(IconTheme),
            )
            .first,
      );
      expect(icon.data.color, theme.inactiveTitleColor);
      expect(
        tester.widget<AdwaitaGoNextIcon>(find.byType(AdwaitaGoNextIcon)).color,
        theme.inactiveTitleColor,
      );
      final sw = tester.widget<AdwaitaSettingsSwitch>(
        find.byType(AdwaitaSettingsSwitch),
      );
      expect(sw.onChanged, isNull);

      await tester.tap(find.text('Email'), warnIfMissed: false);
      await tester.tap(find.text('Switch'), warnIfMissed: false);
      await tester.tap(find.byType(AdwaitaSettingsSwitch), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(pressed, isFalse);
      expect(toggled, isFalse);
    });

    testWidgets('disabled switches use inactiveSwitchColor when it is set', (
      tester,
    ) async {
      final tiles = [
        SettingsTile.switchTile(
          title: const Text('Title'),
          initialValue: true,
          enabled: false,
          activeSwitchColor: Colors.green,
          onToggle: (_) {},
        ),
        SettingsTile.switchTile(
          title: const Text('Enabled'),
          initialValue: true,
          activeSwitchColor: Colors.green,
          onToggle: (_) {},
        ),
      ];
      const theme = SettingsThemeData(inactiveSwitchColor: Colors.pink);
      await _pumpTiles(tester, tiles, lightTheme: theme);
      final switches = tester
          .widgetList<AdwaitaSettingsSwitch>(find.byType(AdwaitaSettingsSwitch))
          .toList();
      expect(switches[0].activeTrackColor, Colors.pink);
      expect(switches[1].activeTrackColor, Colors.green);
    });

    testWidgets('an enabled switch without a color uses the GNOME accent', (
      tester,
    ) async {
      await _pumpTiles(tester, [
        SettingsTile.switchTile(
          title: const Text('Title'),
          initialValue: true,
          onToggle: (_) {},
        ),
      ]);
      expect(
        tester
            .widget<AdwaitaSettingsSwitch>(find.byType(AdwaitaSettingsSwitch))
            .activeTrackColor,
        isNull,
      );
      expect(find.byType(AdwaitaSettingsSwitch), paints..rrect(color: _accent));
    });
  });

  group('interaction', () {
    testWidgets('tapping a row calls onPressed', (tester) async {
      var count = 0;
      await _pumpTiles(tester, [
        SettingsTile(title: const Text('Simple'), onPressed: (_) => count++),
        SettingsTile.navigation(
          title: const Text('Next'),
          onPressed: (_) => count++,
        ),
      ]);
      await tester.tap(find.text('Simple'));
      await tester.tap(find.text('Next'));
      expect(count, 2);
    });

    testWidgets('a switch row toggles from anywhere, never onPressed', (
      tester,
    ) async {
      var value = false;
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SettingsList(
                platform: DevicePlatform.linux,
                sections: [
                  SettingsSection(
                    tiles: [
                      SettingsTile.switchTile(
                        title: const Text('Dim Screen'),
                        initialValue: value,
                        onPressed: (_) => pressed = true,
                        onToggle: (v) => setState(() => value = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Dim Screen'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      await tester.tap(find.byType(AdwaitaSettingsSwitch));
      await tester.pumpAndSettle();
      expect(value, isFalse);
      expect(pressed, isFalse);
    });

    testWidgets('rows without an action do not react', (tester) async {
      _useTraditionalHighlights();
      await _pumpTiles(tester, [SettingsTile(title: const Text('Static'))]);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: tester.getCenter(find.text('Static')));
      addTearDown(gesture.removePointer);
      await tester.pumpAndSettle();
      expect(_rowColor(tester, 'Static')!.a, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_rowOf(tester, 'Static').foregroundDecoration, isNull);
    });

    testWidgets('hover shows 3% and pressing 8% of the foreground', (
      tester,
    ) async {
      _useTraditionalHighlights();
      await _pumpTiles(tester, [
        SettingsTile.navigation(title: const Text('Row'), onPressed: (_) {}),
      ]);
      expect(_rowColor(tester, 'Row')!.a, 0);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.text('Row')));
      await tester.pumpAndSettle();
      expect(_rowColor(tester, 'Row')!.a, closeTo(0.8 * 0.03, 1e-3));

      await gesture.down(tester.getCenter(find.text('Row')));
      await tester.pumpAndSettle();
      expect(_rowColor(tester, 'Row')!.a, closeTo(0.8 * 0.08, 1e-3));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_rowColor(tester, 'Row')!.a, closeTo(0.8 * 0.03, 1e-3));

      await gesture.moveTo(const Offset(1, 1));
      await tester.pumpAndSettle();
      expect(_rowColor(tester, 'Row')!.a, 0);
    });

    testWidgets('the highlight fades in 200 ms, or at once with reduced '
        'motion', (tester) async {
      _useTraditionalHighlights();
      await _pumpTiles(tester, [
        SettingsTile.navigation(title: const Text('Row'), onPressed: (_) {}),
      ]);
      expect(_rowOf(tester, 'Row').duration, const Duration(milliseconds: 200));

      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pump();
      expect(_rowOf(tester, 'Row').duration, Duration.zero);
    });

    testWidgets('keyboard focus shows a 2 px accent ring', (tester) async {
      var pressed = 0;
      var value = false;
      await _pumpTiles(tester, [
        SettingsTile.navigation(
          title: const Text('First'),
          onPressed: (_) => pressed++,
        ),
        SettingsTile(title: const Text('Static')),
        SettingsTile.switchTile(
          title: const Text('Last'),
          initialValue: false,
          onToggle: (v) => value = v,
        ),
      ]);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final ring =
          _rowOf(tester, 'First').foregroundDecoration as BoxDecoration;
      expect(ring.border, isA<Border>());
      final border = ring.border! as Border;
      expect(border.top.width, 2);
      expect(border.top.color, const Color(0xFF0461BE).withValues(alpha: 0.5));
      // The first row's ring follows the top corners of the card.
      expect(
        ring.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(12)),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(pressed, 1);

      // The static row is skipped, and the switch itself takes no focus.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_rowOf(tester, 'First').foregroundDecoration, isNull);
      final last = _rowOf(tester, 'Last').foregroundDecoration as BoxDecoration;
      expect(
        last.borderRadius,
        const BorderRadius.vertical(bottom: Radius.circular(12)),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });

    testWidgets('the focus ring uses the dark accent in dark mode', (
      tester,
    ) async {
      await _pumpTiles(tester, [
        SettingsTile.navigation(title: const Text('Row'), onPressed: (_) {}),
      ], brightness: Brightness.dark);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final ring = _rowOf(tester, 'Row').foregroundDecoration as BoxDecoration;
      expect(
        (ring.border! as Border).top.color,
        const Color(0xFF81D0FF).withValues(alpha: 0.5),
      );
    });

    testWidgets('semantics: one node per row, with its action and state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pumpTiles(tester, [
        SettingsTile.navigation(
          title: const Text('Language'),
          value: const Text('English'),
          onPressed: (_) {},
        ),
        SettingsTile.switchTile(
          title: const Text('Dim Screen'),
          initialValue: true,
          onToggle: (_) {},
        ),
        SettingsTile.navigation(
          title: const Text('Disabled'),
          enabled: false,
          onPressed: (_) {},
        ),
      ]);

      expect(
        tester.getSemantics(find.text('Language')),
        isSemantics(
          label: 'Language\nEnglish',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Dim Screen')),
        isSemantics(
          label: 'Dim Screen',
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Disabled')),
        isSemantics(
          label: 'Disabled',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('right-to-left: mirrored row, arrow and switch', (
      tester,
    ) async {
      var value = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => SettingsList(
                  platform: DevicePlatform.linux,
                  sections: [
                    SettingsSection(
                      tiles: [
                        SettingsTile.navigation(
                          leading: const Icon(Icons.wifi),
                          title: const Text('Title'),
                          value: const Text('Value'),
                          onPressed: (_) {},
                        ),
                        SettingsTile.switchTile(
                          title: const Text('Switch'),
                          initialValue: value,
                          onToggle: (v) => setState(() => value = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final card = _card(tester);
      expect(card.right - tester.getRect(find.byIcon(Icons.wifi)).right, 14);
      expect(card.right - tester.getRect(find.text('Title')).right, 42);
      final arrow = tester.getRect(find.byType(AdwaitaGoNextIcon));
      expect(arrow.left - card.left, 14);
      expect(tester.getRect(find.text('Value')).left - arrow.right, 6);
      expect(
        tester.getRect(find.byType(AdwaitaSettingsSwitch)).left - card.left,
        14,
      );
      // The arrow points left.
      expect(
        find.byType(AdwaitaGoNextIcon),
        paints..path(
          includes: const [Offset(10, 4)],
          excludes: const [Offset(6, 4)],
        ),
      );

      // Dragging the knob to the left turns the switch on.
      await tester.drag(
        find.byType(AdwaitaSettingsSwitch),
        const Offset(-40, 0),
      );
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });
  });

  group('symbolic icons', () {
    Future<void> pumpIcon(
      WidgetTester tester,
      Widget icon, {
      TextDirection direction = TextDirection.ltr,
    }) => tester.pumpWidget(
      Directionality(
        textDirection: direction,
        child: IconTheme(
          data: const IconThemeData(color: Colors.pink),
          child: Center(child: icon),
        ),
      ),
    );

    testWidgets('AdwaitaPanDownIcon: 16 px box, 10x6 of ink, IconTheme color', (
      tester,
    ) async {
      await pumpIcon(tester, const AdwaitaPanDownIcon());
      expect(
        tester.getSize(find.byType(AdwaitaPanDownIcon)),
        const Size(16, 16),
      );
      expect(
        find.byType(AdwaitaPanDownIcon),
        paints..path(
          color: Colors.pink,
          strokeWidth: 2,
          style: PaintingStyle.stroke,
          // The stroke runs (4,6) -> (8,10) -> (12,6): with its 2 px round
          // stroke that is ink from x 3 to 13 and y 5 to 11.
          includes: const [Offset(4, 6), Offset(8, 10), Offset(12, 6)],
          excludes: const [Offset(2, 5), Offset(14, 5), Offset(8, 12)],
        ),
      );
    });

    testWidgets('AdwaitaPanDownIcon: color and size parameters', (
      tester,
    ) async {
      await pumpIcon(
        tester,
        const AdwaitaPanDownIcon(color: Colors.green, size: 32),
      );
      expect(
        tester.getSize(find.byType(AdwaitaPanDownIcon)),
        const Size(32, 32),
      );
      expect(
        find.byType(AdwaitaPanDownIcon),
        paints..path(
          color: Colors.green,
          strokeWidth: 4,
          includes: const [Offset(16, 20)],
        ),
      );
    });

    testWidgets('AdwaitaPanDownIcon is not mirrored in RTL', (tester) async {
      await pumpIcon(
        tester,
        const AdwaitaPanDownIcon(),
        direction: TextDirection.rtl,
      );
      expect(
        find.byType(AdwaitaPanDownIcon),
        paints..path(includes: const [Offset(4, 6), Offset(12, 6)]),
      );
    });

    testWidgets('AdwaitaGoNextIcon: 8x14 of ink, mirrored in RTL', (
      tester,
    ) async {
      await pumpIcon(tester, const AdwaitaGoNextIcon());
      expect(
        find.byType(AdwaitaGoNextIcon),
        paints..path(
          color: Colors.pink,
          includes: const [Offset(5, 2), Offset(11, 8), Offset(5, 14)],
          excludes: const [Offset(3, 8), Offset(13, 8)],
        ),
      );
      await pumpIcon(
        tester,
        const AdwaitaGoNextIcon(),
        direction: TextDirection.rtl,
      );
      expect(
        find.byType(AdwaitaGoNextIcon),
        paints..path(includes: const [Offset(11, 2), Offset(5, 8)]),
      );
    });

    test('AdwaitaPanDownIcon is part of the public library', () {
      // Compiles only while package:settings_ui/settings_ui.dart exports it.
      const Widget icon = settings_ui.AdwaitaPanDownIcon();
      expect(icon, isA<AdwaitaPanDownIcon>());
    });
  });

  group('AdwaitaSettingsSwitch', () {
    Future<void> pumpSwitch(
      WidgetTester tester, {
      required bool value,
      ValueChanged<bool>? onChanged,
      Brightness? brightness,
      Color? activeTrackColor,
      Color? inactiveTrackColor,
      TextDirection direction = TextDirection.ltr,
      bool stateful = false,
    }) async {
      var current = value;
      await tester.pumpWidget(
        CupertinoApp(
          theme: CupertinoThemeData(brightness: brightness),
          home: Directionality(
            textDirection: direction,
            child: Center(
              child: StatefulBuilder(
                builder: (context, setState) => AdwaitaSettingsSwitch(
                  value: current,
                  onChanged: onChanged == null
                      ? null
                      : (v) {
                          onChanged(v);
                          if (stateful) setState(() => current = v);
                        },
                  activeTrackColor: activeTrackColor,
                  inactiveTrackColor: inactiveTrackColor,
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('is 46x26 with a 20 px knob', (tester) async {
      await pumpSwitch(tester, value: false, onChanged: (_) {});
      expect(
        tester.getSize(find.byType(AdwaitaSettingsSwitch)),
        const Size(46, 26),
      );
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints
          ..rrect(
            rrect: RRect.fromRectAndRadius(
              const Rect.fromLTWH(0, 0, 46, 26),
              const Radius.circular(13),
            ),
          )
          // Knob shadow, then the knob, 3 px in from the start.
          ..circle(x: 13, y: 15, radius: 10)
          ..circle(x: 13, y: 13, radius: 10, color: _white),
      );
    });

    testWidgets('light colors: accent when on, rgba(0,0,6,0.12) when off', (
      tester,
    ) async {
      await pumpSwitch(tester, value: true, onChanged: (_) {});
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints
          ..rrect(color: _accent)
          ..circle()
          ..circle(x: 33, y: 13, color: _white),
      );

      await pumpSwitch(tester, value: false, onChanged: (_) {});
      await tester.pumpAndSettle();
      // The foreground, rgba(0, 0, 6, 0.8), at 15%: rgba(0, 0, 6, 0.12).
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints..rrect(color: _lightForeground.withValues(alpha: 0.8 * 0.15)),
      );
    });

    testWidgets('dark colors: white 15% off track, grey knob when off', (
      tester,
    ) async {
      await pumpSwitch(
        tester,
        value: false,
        onChanged: (_) {},
        brightness: Brightness.dark,
      );
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints
          ..rrect(color: _white.withValues(alpha: 0.15))
          ..circle()
          ..circle(color: const Color(0xFFD2D2D2)),
      );

      await pumpSwitch(
        tester,
        value: true,
        onChanged: (_) {},
        brightness: Brightness.dark,
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints
          ..rrect(color: _accent)
          ..circle()
          ..circle(color: _white),
      );
    });

    testWidgets('custom track colors', (tester) async {
      await pumpSwitch(
        tester,
        value: true,
        onChanged: (_) {},
        activeTrackColor: Colors.green,
      );
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints..rrect(color: Colors.green),
      );
      await pumpSwitch(
        tester,
        value: false,
        onChanged: (_) {},
        inactiveTrackColor: Colors.purple,
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints..rrect(color: Colors.purple),
      );
    });

    testWidgets('hovering lightens the track', (tester) async {
      _useTraditionalHighlights();
      await pumpSwitch(tester, value: true, onChanged: (_) {});
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(
        tester.getCenter(find.byType(AdwaitaSettingsSwitch)),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints..rrect(
          color: Color.alphaBlend(_white.withValues(alpha: 0.1), _accent),
        ),
      );
    });

    testWidgets('tapping toggles', (tester) async {
      final values = <bool>[];
      await pumpSwitch(tester, value: false, onChanged: values.add);
      await tester.tap(find.byType(AdwaitaSettingsSwitch));
      await tester.pumpAndSettle();
      expect(values, [true]);
    });

    testWidgets('dragging past the middle sets the value', (tester) async {
      final values = <bool>[];
      await pumpSwitch(
        tester,
        value: false,
        onChanged: values.add,
        stateful: true,
      );
      final center = tester.getCenter(find.byType(AdwaitaSettingsSwitch));

      // Less than half the 20 px travel: stays off.
      final short = await tester.startGesture(center);
      await short.moveBy(const Offset(20, 0));
      await short.moveBy(const Offset(-12, 0));
      await short.up();
      await tester.pumpAndSettle();
      expect(values, isEmpty);

      await tester.drag(
        find.byType(AdwaitaSettingsSwitch),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();
      expect(values, [true]);

      await tester.drag(
        find.byType(AdwaitaSettingsSwitch),
        const Offset(-40, 0),
      );
      await tester.pumpAndSettle();
      expect(values, [true, false]);
    });

    testWidgets('the knob returns if the parent keeps the value', (
      tester,
    ) async {
      await pumpSwitch(tester, value: false, onChanged: (_) {});
      await tester.drag(
        find.byType(AdwaitaSettingsSwitch),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints
          ..rrect()
          ..circle(x: 13),
      );
    });

    testWidgets('disabled: half opacity, no toggling', (tester) async {
      await pumpSwitch(tester, value: true);
      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(AdwaitaSettingsSwitch),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.5);
      await tester.tap(find.byType(AdwaitaSettingsSwitch));
      await tester.drag(
        find.byType(AdwaitaSettingsSwitch),
        const Offset(-40, 0),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('keyboard: focus ring and Space toggles', (tester) async {
      final values = <bool>[];
      await pumpSwitch(tester, value: false, onChanged: values.add);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints
          ..rrect()
          ..rrect(
            style: PaintingStyle.stroke,
            strokeWidth: 2,
            color: const Color(0xFF0461BE).withValues(alpha: 0.5),
          ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(values, [true]);
    });

    testWidgets('semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSwitch(tester, value: true, onChanged: (_) {});
      expect(
        tester.getSemantics(find.byType(AdwaitaSettingsSwitch)),
        isSemantics(
          hasToggledState: true,
          isToggled: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );
      await pumpSwitch(tester, value: false);
      expect(
        tester.getSemantics(find.byType(AdwaitaSettingsSwitch)),
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

    testWidgets('right-to-left: ON is on the left', (tester) async {
      await pumpSwitch(
        tester,
        value: true,
        onChanged: (_) {},
        direction: TextDirection.rtl,
      );
      // The canvas is mirrored, so the knob is drawn at x = 33 before the
      // flip, which is 13 px from the left edge.
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints
          ..rrect()
          ..circle()
          ..circle(x: 33),
      );
      final values = <bool>[];
      await pumpSwitch(
        tester,
        value: true,
        onChanged: values.add,
        direction: TextDirection.rtl,
      );
      await tester.drag(
        find.byType(AdwaitaSettingsSwitch),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();
      expect(values, [false]);
    });

    testWidgets('moves in 100 ms, or at once with reduced motion', (
      tester,
    ) async {
      await pumpSwitch(tester, value: false, onChanged: (_) {});
      await pumpSwitch(tester, value: true, onChanged: (_) {});
      await tester.pump(const Duration(milliseconds: 50));
      expect(
        find.byType(AdwaitaSettingsSwitch),
        isNot(
          paints
            ..rrect()
            ..circle()
            ..circle(x: 33),
        ),
      );
      await tester.pump(const Duration(milliseconds: 60));
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints
          ..rrect()
          ..circle()
          ..circle(x: 33),
      );

      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pump();
      await pumpSwitch(tester, value: false, onChanged: (_) {});
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints
          ..rrect()
          ..circle()
          ..circle(x: 13),
      );
    });

    testWidgets('follows the CupertinoTheme brightness by default', (
      tester,
    ) async {
      await pumpSwitch(
        tester,
        value: false,
        onChanged: (_) {},
        brightness: Brightness.dark,
      );
      expect(
        find.byType(AdwaitaSettingsSwitch),
        paints..rrect(color: _white.withValues(alpha: 0.15)),
      );
    });
  });
}
