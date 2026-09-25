import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/split/adwaita_split.dart';
import 'package:settings_ui/src/split/fluent_split.dart';
import 'package:settings_ui/src/split/macos_split.dart';
import 'package:settings_ui/src/split/split_geometry.dart';
import 'package:settings_ui/src/tiles/platforms/adwaita_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/fluent_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/ios_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/macos_settings_tile.dart';
import 'package:settings_ui/src/utils/fluent_tokens.dart';
import 'package:settings_ui/src/utils/settings_style.dart';
import 'package:settings_ui/src/utils/theme_provider.dart';

/// Tests for the native split view looks of the macOS (System Settings),
/// Windows (Windows Settings) and GNOME (GNOME Settings) styles: their
/// breakpoints, sidebars, selection, page headers, keyboard navigation,
/// right-to-left layouts and large text.

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Two groups of pages like the platform apps': a page with a nested page
/// (Display › Text size), a switch without a page, and a titled group.
List<AbstractSettingsSection> _sections() => [
  SettingsSection(
    tiles: [
      SettingsTile.navigation(
        leading: const Icon(Icons.wifi),
        title: const Text('Network'),
        destination: SettingsDestination(
          id: 'network',
          builder: (context) => SettingsList(
            sections: [
              SettingsSection(
                tiles: [SettingsTile(title: const Text('Network body'))],
              ),
            ],
          ),
        ),
      ),
      SettingsTile.switchTile(
        leading: const Icon(Icons.airplanemode_active),
        title: const Text('Airplane mode'),
        initialValue: false,
        onToggle: (_) {},
      ),
    ],
  ),
  SettingsSection(
    title: const Text('Device'),
    tiles: [
      SettingsTile.navigation(
        leading: const Icon(Icons.brightness_6),
        title: const Text('Display'),
        destination: SettingsDestination(
          id: 'display',
          title: const Text('Display & brightness'),
          builder: (context) => SettingsList(
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile.navigation(
                    title: const Text('Text size'),
                    destination: SettingsDestination(
                      id: 'text-size',
                      builder: (context) => SettingsList(
                        sections: [
                          SettingsSection(
                            tiles: [SettingsTile(title: const Text('Larger'))],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      SettingsTile.navigation(
        leading: const Icon(Icons.volume_up),
        title: const Text('Sound'),
        destination: SettingsDestination(
          id: 'sound',
          builder: (context) => const Center(child: Text('Sound body')),
        ),
      ),
    ],
  ),
];

Widget _app(
  Widget home, {
  required TargetPlatform platform,
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
  double textScale = 1,
}) {
  return MaterialApp(
    theme: ThemeData(platform: platform, brightness: brightness),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: Directionality(textDirection: textDirection, child: child!),
    ),
    home: home,
  );
}

SettingsSplitView _view(
  DevicePlatform platform, {
  double? listPaneWidth,
  SettingsSplitLayout layout = SettingsSplitLayout.auto,
  SettingsSplitController? controller,
}) => SettingsSplitView(
  platform: platform,
  title: const Text('Settings'),
  listPaneWidth: listPaneWidth,
  layout: layout,
  controller: controller,
  sections: _sections(),
);

TargetPlatform _targetOf(DevicePlatform platform) => switch (platform) {
  DevicePlatform.macOS => TargetPlatform.macOS,
  DevicePlatform.windows => TargetPlatform.windows,
  _ => TargetPlatform.linux,
};

Future<void> _pump(
  WidgetTester tester,
  DevicePlatform platform, {
  Size size = const Size(1280, 800),
  Brightness brightness = Brightness.light,
  TextDirection textDirection = TextDirection.ltr,
  double textScale = 1,
  double? listPaneWidth,
  SettingsSplitController? controller,
}) async {
  await _setSize(tester, size);
  await tester.pumpWidget(
    _app(
      _view(platform, listPaneWidth: listPaneWidth, controller: controller),
      platform: _targetOf(platform),
      brightness: brightness,
      textDirection: textDirection,
      textScale: textScale,
    ),
  );
  await tester.pumpAndSettle();
}

final Finder _listPane = find.byKey(const ValueKey('settings_split_list_pane'));

bool _isSplit(WidgetTester tester) => SettingsSplitView.of(
  tester.element(
    find
        .descendant(
          of: find.byType(SettingsSplitView),
          matching: find.byType(SettingsTheme),
        )
        .first,
  ),
).isSplit;

String? _selectedId(WidgetTester tester) => SettingsSplitView.of(
  tester.element(
    find
        .descendant(
          of: find.byType(SettingsSplitView),
          matching: find.byType(SettingsTheme),
        )
        .first,
  ),
).selectedId;

Finder _inList(Finder finder) =>
    find.descendant(of: _listPane, matching: finder);

/// The sidebar row of [title], as a widget of [type].
Finder _row(Type type, String title) =>
    find.ancestor(of: _inList(find.text(title)), matching: find.byType(type));

/// The background of a sidebar row: its first [DecoratedBox].
Finder _fillOf(Type type, String title) =>
    find.descendant(of: _row(type, title), matching: find.byType(DecoratedBox));

BoxDecoration _fillDecoration(WidgetTester tester, Type type, String title) =>
    tester.widget<DecoratedBox>(_fillOf(type, title).first).decoration
        as BoxDecoration;

TextStyle _textStyle(WidgetTester tester, Finder text) => tester
    .widget<DefaultTextStyle>(
      find.ancestor(of: text, matching: find.byType(DefaultTextStyle)).first,
    )
    .style;

SettingsThemeData _theme(
  WidgetTester tester,
  DevicePlatform platform,
  Brightness brightness,
) => ThemeProvider.getTheme(
  context: tester.element(find.byType(SettingsSplitView)),
  platform: platform,
  brightness: brightness,
);

/// Titles of the list pane tiles drawn selected (their semantics say so).
List<String> _selectedTitles(WidgetTester tester) => [
  for (final element in find.byType(SettingsTile).evaluate())
    if (_isSelectedTile(element))
      ((element.widget as SettingsTile).title as Text).data!,
];

bool _isSelectedTile(Element element) {
  var selected = false;
  element.visitChildElements((child) {
    final widget = child.widget;
    if (widget is Semantics && widget.properties.selected == true) {
      selected = true;
    }
  });
  return selected;
}

/// Presses Tab until the focus is in the sidebar row of [title] (a widget
/// of [type]). Fails if it never gets there.
Future<void> _tabTo(WidgetTester tester, Type type, String title) async {
  bool focused() {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return false;
    var found = false;
    context.visitAncestorElements((element) {
      if (element.widget.runtimeType == type) {
        found = find
            .descendant(
              of: find.byElementPredicate((e) => e == element),
              matching: find.text(title),
            )
            .evaluate()
            .isNotEmpty;
        return false;
      }
      return true;
    });
    return found;
  }

  for (var i = 0; i < 30 && !focused(); i++) {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
  }
  expect(focused(), isTrue, reason: 'Tab never reached "$title"');
}

void desktopSplitViewTests() {
  group('breakpoints and pane widths', () {
    test('macOS: two panes from 560, a 232pt sidebar', () {
      SplitGeometry geometry(double width) => computeSplitGeometry(
        family: SettingsStyleFamily.macos,
        forceSingle: false,
        forceSplit: false,
        width: width,
        shortestSide: 400,
        desktop: false,
        textDirection: TextDirection.ltr,
      );
      expect(geometry(559).isSplit, isFalse);
      expect(geometry(560).isSplit, isTrue);
      expect(geometry(560).listWidth, 232);
      expect(geometry(1280).listWidth, 232);
      // Only the width counts, also on a phone-sized screen.
      expect(geometry(874).isSplit, isTrue);
    });

    test('Windows: compact rail from 641, open pane from 1008', () {
      SplitGeometry geometry(double width, {double? listPaneWidth}) =>
          computeSplitGeometry(
            family: SettingsStyleFamily.fluent,
            forceSingle: false,
            forceSplit: false,
            width: width,
            shortestSide: 400,
            desktop: false,
            textDirection: TextDirection.ltr,
            listPaneWidth: listPaneWidth,
          );
      expect(geometry(640).isSplit, isFalse);
      for (final width in <double>[641, 900, 1007]) {
        final g = geometry(width);
        expect(g.isSplit, isTrue, reason: '$width');
        expect(g.compactPane, isTrue, reason: '$width');
        expect(g.listWidth, 48, reason: '$width');
      }
      final open = geometry(1008);
      expect(open.compactPane, isFalse);
      expect(open.listWidth, 300);
      // listPaneWidth sets the open pane only.
      expect(geometry(1280, listPaneWidth: 320).listWidth, 320);
      expect(geometry(900, listPaneWidth: 320).listWidth, 48);
    });

    test('GNOME: collapses at 550sp, sidebar 25% within 180-280sp', () {
      SplitGeometry geometry(double width, {double scale = 1}) =>
          computeSplitGeometry(
            family: SettingsStyleFamily.adwaita,
            forceSingle: false,
            forceSplit: false,
            width: width,
            shortestSide: 800,
            desktop: true,
            textDirection: TextDirection.ltr,
            textScaler: TextScaler.linear(scale),
          );
      expect(geometry(550).isSplit, isFalse);
      expect(geometry(551).isSplit, isTrue);
      expect(geometry(551).listWidth, 180);
      expect(geometry(980).listWidth, 245);
      expect(geometry(1083).listWidth, closeTo(270.75, 0.01));
      expect(geometry(1280).listWidth, 280);
      // Everything scales with the text.
      expect(geometry(1100, scale: 2).isSplit, isFalse);
      expect(geometry(1280, scale: 2).isSplit, isTrue);
      expect(geometry(1280, scale: 2).listWidth, 360);
    });

    final widgetCases = <(DevicePlatform, Size, bool, double?)>[
      (DevicePlatform.macOS, const Size(1280, 800), true, 232),
      (DevicePlatform.macOS, const Size(900, 700), true, 232),
      (DevicePlatform.macOS, const Size(520, 800), false, null),
      (DevicePlatform.windows, const Size(1280, 800), true, 300),
      (DevicePlatform.windows, const Size(1008, 700), true, 300),
      (DevicePlatform.windows, const Size(1007, 700), true, 48),
      (DevicePlatform.windows, const Size(900, 700), true, 48),
      (DevicePlatform.windows, const Size(641, 700), true, 48),
      (DevicePlatform.windows, const Size(640, 700), false, null),
      (DevicePlatform.windows, const Size(520, 800), false, null),
      (DevicePlatform.linux, const Size(1280, 800), true, 280),
      (DevicePlatform.linux, const Size(900, 700), true, 225),
      (DevicePlatform.linux, const Size(551, 700), true, 180),
      (DevicePlatform.linux, const Size(550, 700), false, null),
      (DevicePlatform.linux, const Size(520, 800), false, null),
    ];
    for (final (platform, size, split, paneWidth) in widgetCases) {
      testWidgets('$platform at ${size.width.toInt()}: '
          '${split ? 'a ${paneWidth!.toInt()} list pane' : 'one pane'}', (
        tester,
      ) async {
        await _pump(tester, platform, size: size);
        expect(tester.takeException(), isNull);
        expect(_isSplit(tester), split);
        if (paneWidth != null) {
          expect(tester.getRect(_listPane).width, paneWidth);
        }
      });
    }

    testWidgets('listPaneWidth sets the macOS and GNOME sidebars', (
      tester,
    ) async {
      await _pump(tester, DevicePlatform.macOS, listPaneWidth: 260);
      expect(tester.getRect(_listPane).width, 260);
      await _pump(tester, DevicePlatform.linux, listPaneWidth: 200);
      expect(tester.getRect(_listPane).width, 200);
    });
  });

  group('macOS sidebar', () {
    for (final brightness in Brightness.values) {
      testWidgets('rows, selection and headers (${brightness.name})', (
        tester,
      ) async {
        await _pump(tester, DevicePlatform.macOS, brightness: brightness);
        final theme = _theme(tester, DevicePlatform.macOS, brightness);
        final dark = brightness == Brightness.dark;

        // Sidebar rows in the list pane, cards in the page.
        expect(_inList(find.byType(MacosSidebarItem)), findsNWidgets(4));
        expect(_inList(find.byType(MacosSettingsTile)), findsNothing);
        expect(_inList(find.byType(IOSSettingsTile)), findsNothing);
        expect(
          find.ancestor(
            of: find.text('Network body'),
            matching: find.byType(MacosSettingsTile),
          ),
          findsOneWidget,
        );
        expect(
          tester.widget<Material>(_inList(find.byType(Material)).first).color,
          theme.listPaneBackground,
        );
        expect(
          theme.listPaneBackground,
          dark ? const Color(0xFF282828) : const Color(0xFFEDEDED),
        );

        // The selected row: an accent rounded rect inset 10pt, 32pt tall,
        // with a white semibold label.
        expect(_selectedTitles(tester), ['Network']);
        final selected = _fillDecoration(tester, MacosSidebarItem, 'Network');
        expect(selected.color, theme.selectedTileColor);
        expect(
          selected.color,
          dark ? const Color(0xFF007AFF) : const Color(0xFF0070F5),
        );
        expect(selected.borderRadius, BorderRadius.circular(8));
        final rect = tester.getRect(_fillOf(MacosSidebarItem, 'Network').first);
        expect(rect.left, 10);
        expect(rect.width, 232 - 20);
        expect(rect.height, 32);
        final label = _textStyle(tester, _inList(find.text('Network')));
        expect(label.color, const Color(0xFFFFFFFF));
        expect(label.fontWeight, FontWeight.w600);
        expect(label.fontSize, 13);
        // A plain Icon turns white on the accent.
        expect(
          IconTheme.of(tester.element(_inList(find.byIcon(Icons.wifi)))).color,
          const Color(0xFFFFFFFF),
        );

        // Other rows: no fill, a plain black or white label and an
        // accent-tinted icon.
        expect(_fillDecoration(tester, MacosSidebarItem, 'Sound').color, null);
        final other = _textStyle(tester, _inList(find.text('Sound')));
        expect(
          other.color,
          dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
        );
        expect(other.fontWeight, isNot(FontWeight.w600));
        expect(
          IconTheme.of(
            tester.element(_inList(find.byIcon(Icons.volume_up))),
          ).color,
          dark ? const Color(0xFF008FFF) : const Color(0xFF0077FF),
        );
        expect(
          IconTheme.of(
            tester.element(_inList(find.byIcon(Icons.volume_up))),
          ).size,
          20,
        );

        // Label 46pt in with an icon, icon at 19.
        expect(tester.getRect(_inList(find.text('Sound'))).left, 46);
        expect(tester.getRect(_inList(find.byIcon(Icons.volume_up))).left, 19);

        // Section header: 11pt bold in the tertiary color, 13pt below the
        // group above.
        final header = _textStyle(tester, _inList(find.text('Device')));
        expect(header.fontSize, 11);
        expect(header.fontWeight, FontWeight.w700);
        expect(
          header.color,
          dark ? const Color(0xFF5A5A5A) : const Color(0xFFA0A0A0),
        );
        expect(tester.getRect(_inList(find.text('Device'))).left, 14);
        expect(_inList(find.byType(MacosSidebarSectionGap)), findsOneWidget);

        // Selecting another row moves the selection.
        await tester.tap(_inList(find.text('Sound')));
        await tester.pumpAndSettle();
        expect(_selectedTitles(tester), ['Sound']);
        expect(find.text('Sound body'), findsOneWidget);
        expect(
          _fillDecoration(tester, MacosSidebarItem, 'Sound').color,
          theme.selectedTileColor,
        );
        expect(
          _fillDecoration(tester, MacosSidebarItem, 'Network').color,
          null,
        );
      });

      testWidgets('an inactive window greys the selection '
          '(${brightness.name})', (tester) async {
        addTearDown(
          () => tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          ),
        );
        await _pump(tester, DevicePlatform.macOS, brightness: brightness);
        final dark = brightness == Brightness.dark;

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        await tester.pump();
        expect(
          _fillDecoration(tester, MacosSidebarItem, 'Network').color,
          dark ? const Color(0xFF464646) : const Color(0xFFD7D7D7),
        );
        final label = _textStyle(tester, _inList(find.text('Network')));
        expect(
          label.color,
          dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
        );
        expect(label.fontWeight, FontWeight.w600);
        // The plain icon keeps the accent tint.
        expect(
          IconTheme.of(tester.element(_inList(find.byIcon(Icons.wifi)))).color,
          dark ? const Color(0xFF008FFF) : const Color(0xFF0077FF),
        );

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        expect(
          _fillDecoration(tester, MacosSidebarItem, 'Network').color,
          _theme(tester, DevicePlatform.macOS, brightness).selectedTileColor,
        );
      });
    }

    testWidgets('no hover highlight', (tester) async {
      await _pump(tester, DevicePlatform.macOS);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(_inList(find.text('Sound'))));
      await tester.pumpAndSettle();
      expect(_fillDecoration(tester, MacosSidebarItem, 'Sound').color, null);
    });

    testWidgets('the sidebar runs under a 52pt toolbar strip', (tester) async {
      await _pump(tester, DevicePlatform.macOS);
      expect(
        tester.getRect(_inList(find.byType(MacosSidebarTopBar))).height,
        52,
      );
      // No title in the sidebar: System Settings shows none.
      expect(_inList(find.text('Settings')), findsNothing);
      expect(
        tester.getRect(_fillOf(MacosSidebarItem, 'Network').first).top,
        52,
      );
    });
  });

  group('macOS detail header', () {
    testWidgets('the toolbar title, and the back capsule on a nested page', (
      tester,
    ) async {
      await _pump(tester, DevicePlatform.macOS);
      await tester.tap(_inList(find.text('Display')));
      await tester.pumpAndSettle();

      // A 52pt toolbar with the 15pt semibold grey title at 20pt, and no
      // large title in the content.
      final toolbar = find.byType(MacosToolbar);
      expect(toolbar, findsOneWidget);
      expect(tester.getRect(toolbar).height, 52);
      final title = find.text('Display & brightness');
      expect(title, findsOneWidget);
      final style = _textStyle(tester, title);
      expect(style.fontSize, 15);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.color, const Color(0xFF4C4C4C));
      expect(tester.getRect(title).left, 232 + 20);
      expect(find.byType(MacosNavigationCapsule), findsNothing);

      // A page opened from the page gets the ‹ › capsule; the title moves
      // 13pt after it.
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();
      final capsule = find.byType(MacosNavigationCapsule);
      expect(capsule, findsOneWidget);
      final capsuleRect = tester.getRect(capsule);
      expect(capsuleRect.size, const Size(73, 36));
      expect(capsuleRect.left, 232 + 8);
      expect(capsuleRect.top, 8);
      expect(
        tester.getRect(find.text('Text size').last).left,
        capsuleRect.right + 13,
      );

      // Forward is disabled; back goes back.
      expect(
        tester.getSemantics(
          find.descendant(of: capsule, matching: find.bySemanticsLabel('Back')),
        ),
        matchesSemantics(
          label: 'Back',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      expect(
        tester.getSemantics(
          find.descendant(
            of: capsule,
            matching: find.bySemanticsLabel('Forward'),
          ),
        ),
        matchesSemantics(
          label: 'Forward',
          isButton: true,
          hasEnabledState: true,
        ),
      );
      await tester.tap(
        find.descendant(of: capsule, matching: find.bySemanticsLabel('Back')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Larger'), findsNothing);
      expect(find.byType(MacosNavigationCapsule), findsNothing);
    });

    testWidgets('dark title color', (tester) async {
      await _pump(tester, DevicePlatform.macOS, brightness: Brightness.dark);
      expect(
        _textStyle(
          tester,
          find.descendant(
            of: find.byType(MacosToolbar),
            matching: find.text('Network'),
          ),
        ).color,
        const Color(0xFFE9E9E9),
      );
    });

    testWidgets('one pane: grouped cards, and pages with a back capsule', (
      tester,
    ) async {
      await _pump(tester, DevicePlatform.macOS, size: const Size(520, 800));
      expect(_isSplit(tester), isFalse);
      expect(find.byType(MacosSidebarItem), findsNothing);
      expect(find.byType(MacosSettingsTile), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(MacosToolbar),
          matching: find.text('Settings'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Display'));
      await tester.pumpAndSettle();
      final capsule = find.byType(MacosNavigationCapsule);
      expect(capsule, findsOneWidget);
      await tester.tap(
        find.descendant(of: capsule, matching: find.bySemanticsLabel('Back')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Display & brightness'), findsNothing);
      expect(_selectedId(tester), isNull);
    });
  });

  group('Windows pane', () {
    for (final brightness in Brightness.values) {
      testWidgets('items, selection pill and header (${brightness.name})', (
        tester,
      ) async {
        await _pump(tester, DevicePlatform.windows, brightness: brightness);
        final theme = _theme(tester, DevicePlatform.windows, brightness);
        final tokens = FluentTokens.of(brightness);
        final dark = brightness == Brightness.dark;

        expect(_inList(find.byType(FluentNavigationItem)), findsNWidgets(4));
        expect(_inList(find.byType(FluentSettingsTile)), findsNothing);
        expect(
          find.ancestor(
            of: find.text('Network body'),
            matching: find.byType(FluentSettingsTile),
          ),
          findsOneWidget,
        );
        // Pane and content share the Mica fallback page color.
        expect(theme.listPaneBackground, theme.settingsListBackground);
        expect(
          theme.listPaneBackground,
          dark ? const Color(0xFF202020) : const Color(0xFFF3F3F3),
        );

        // The selected item: the neutral fill, 4 corners, 36 tall, 4,2
        // margins inside the 12 gutter (16 from the edge), text at 48.
        expect(_selectedTitles(tester), ['Network']);
        final fill = _fillDecoration(tester, FluentNavigationItem, 'Network');
        expect(fill.color, theme.selectedTileColor);
        expect(
          fill.color,
          dark ? const Color(0xFF2D2D2D) : const Color(0xFFEAEAEA),
        );
        expect(fill.borderRadius, BorderRadius.circular(4));
        final rect = tester.getRect(
          _fillOf(FluentNavigationItem, 'Network').first,
        );
        expect(rect.left, 16);
        expect(rect.width, 300 - 12 - 8);
        expect(rect.height, 36);
        expect(tester.getRect(_inList(find.text('Network'))).left, 12 + 48);
        expect(
          tester.getCenter(_inList(find.byIcon(Icons.wifi))).dx,
          12 + 4 + 20,
        );
        expect(
          IconTheme.of(tester.element(_inList(find.byIcon(Icons.wifi)))).size,
          16,
        );
        final label = _textStyle(tester, _inList(find.text('Network')));
        expect(label.fontSize, 14);
        expect(label.color, tokens.textPrimary);

        // The accent pill: 3x16 with 2 corners at the item's start edge.
        expect(
          _pillRect(tester, 'Network', tokens.accent),
          const Rect.fromLTRB(4, 12, 7, 28),
        );
        expect(_pillRect(tester, 'Sound', tokens.accent), isNull);
        expect(
          _fillDecoration(tester, FluentNavigationItem, 'Sound').color!.a,
          0,
        );

        // The section header: BodyStrong in the secondary color.
        final header = _textStyle(tester, _inList(find.text('Device')));
        expect(header.fontSize, 14);
        expect(header.fontWeight, FontWeight.w600);
        expect(header.color, tokens.textSecondary);

        // The pane shows the view's title like Settings' title bar.
        final paneTitle = _textStyle(tester, _inList(find.text('Settings')));
        expect(paneTitle.fontSize, 12);
      });
    }

    testWidgets('the pill slides to the new item', (tester) async {
      await _pump(tester, DevicePlatform.windows);
      final accent = FluentTokens.light.accent;
      await tester.tap(_inList(find.text('Sound')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      // On its way down from Network: above Sound's own place.
      final moving = _pillRect(tester, 'Sound', accent);
      expect(moving, isNotNull);
      expect(moving!.top, lessThan(12));
      expect(_pillRect(tester, 'Network', accent), isNull);
      await tester.pumpAndSettle();
      expect(
        _pillRect(tester, 'Sound', accent),
        const Rect.fromLTRB(4, 12, 7, 28),
      );
      expect(_selectedTitles(tester), ['Sound']);
    });

    testWidgets('hover, pressed and selected-hover colors', (tester) async {
      await _pump(tester, DevicePlatform.windows);
      final tokens = FluentTokens.light;
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(_inList(find.text('Sound'))));
      await tester.pumpAndSettle();
      expect(
        _fillDecoration(tester, FluentNavigationItem, 'Sound').color,
        const Color(0xFFEAEAEA),
      );

      await gesture.down(tester.getCenter(_inList(find.text('Sound'))));
      await tester.pumpAndSettle();
      expect(
        _fillDecoration(tester, FluentNavigationItem, 'Sound').color,
        const Color(0xFFEDEDED),
      );
      expect(
        _textStyle(tester, _inList(find.text('Sound'))).color,
        tokens.textSecondary,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      // Now selected and still hovered: the lighter SubtleFillTertiary.
      expect(_selectedTitles(tester), ['Sound']);
      expect(
        _fillDecoration(tester, FluentNavigationItem, 'Sound').color,
        const Color(0xFFEDEDED),
      );
      await gesture.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(
        _fillDecoration(tester, FluentNavigationItem, 'Sound').color,
        const Color(0xFFEAEAEA),
      );
    });

    testWidgets('the focus ring', (tester) async {
      await _pump(tester, DevicePlatform.windows);
      await _tabTo(tester, FluentNavigationItem, 'Sound');
      await tester.pumpAndSettle();
      expect(
        tester.renderObject(_row(FluentNavigationItem, 'Sound')),
        paints
          ..drrect(color: FluentTokens.light.focusOuter)
          ..drrect(color: FluentTokens.light.focusInner),
      );
    });

    testWidgets('compact rail: icons, tooltips, separators, the pane toggle', (
      tester,
    ) async {
      await _pump(tester, DevicePlatform.windows, size: const Size(900, 700));
      expect(tester.getRect(_listPane).width, 48);
      // Icons only: labels move to tooltips, headers make way for a line.
      expect(_inList(find.text('Network')), findsNothing);
      expect(_inList(find.text('Device')), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Tooltip && widget.message == 'Display',
        ),
        findsOneWidget,
      );
      expect(_inList(find.byType(FluentPaneSeparator)), findsOneWidget);
      final fill = tester.getRect(
        find
            .descendant(
              of: find.ancestor(
                of: _inList(find.byIcon(Icons.wifi)),
                matching: find.byType(FluentNavigationItem),
              ),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(fill.width, 40);
      expect(fill.left, 4);
      expect(tester.getCenter(_inList(find.byIcon(Icons.wifi))).dx, 24);

      // A tap on an icon selects.
      await tester.tap(_inList(find.byIcon(Icons.volume_up)));
      await tester.pumpAndSettle();
      expect(_selectedId(tester), 'sound');
      expect(find.text('Sound body'), findsOneWidget);

      // The toggle opens the pane over the content, with the labels.
      await tester.tap(find.bySemanticsLabel('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(_inList(find.text('Display')), findsOneWidget);
      expect(tester.getRect(_listPane).width, 320);
      // The content stays where it was, under the pane.
      expect(find.text('Sound body'), findsOneWidget);
      // Picking a page closes it.
      await tester.tap(_inList(find.text('Display')));
      await tester.pumpAndSettle();
      expect(_selectedId(tester), 'display');
      expect(_inList(find.text('Display')), findsNothing);

      // A click outside and Escape close it too.
      await tester.tap(find.bySemanticsLabel('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(800, 600));
      await tester.pumpAndSettle();
      expect(_inList(find.text('Display')), findsNothing);
      expect(_selectedId(tester), 'display');
    });
  });

  group('Windows page header', () {
    testWidgets('the Title aligned with the content, and a breadcrumb', (
      tester,
    ) async {
      await _pump(tester, DevicePlatform.windows);
      await tester.tap(_inList(find.text('Display')));
      await tester.pumpAndSettle();

      final title = find.text('Display & brightness');
      expect(title, findsOneWidget);
      final style = _textStyle(tester, title);
      expect(style.fontSize, 28);
      expect(style.height, 36 / 28);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.color, FluentTokens.light.textPrimary);
      // The detail pane is 980 wide: 24 margins, like the cards.
      expect(tester.getRect(title).left, 300 + 24);
      expect(tester.getRect(title).top, 24);
      expect(find.byType(FluentSubtleButton), findsNothing);

      // A nested page: "Display & brightness › Text size", the parent in the
      // secondary color.
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();
      final header = find.byType(FluentPageHeader);
      final parent = find.descendant(
        of: header,
        matching: find.text('Display & brightness'),
      );
      final current = find.descendant(
        of: header,
        matching: find.text('Text size'),
      );
      expect(parent, findsOneWidget);
      expect(current, findsOneWidget);
      expect(
        _textStyle(tester, parent).color,
        FluentTokens.light.textSecondary,
      );
      expect(_textStyle(tester, current).color, FluentTokens.light.textPrimary);
      expect(
        tester.getRect(current).left,
        greaterThan(tester.getRect(parent).right),
      );
      expect(tester.getRect(parent).left, 300 + 24);

      // The parent crumb goes back.
      await tester.tap(parent);
      await tester.pumpAndSettle();
      expect(find.text('Larger'), findsNothing);
      expect(find.text('Text size'), findsOneWidget);
    });

    testWidgets('the first group header sits 19 below the title', (
      tester,
    ) async {
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: DevicePlatform.windows,
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile.navigation(
                    title: const Text('Page'),
                    destination: SettingsDestination(
                      id: 'page',
                      title: const Text('Page title'),
                      builder: (context) => SettingsList(
                        sections: [
                          SettingsSection(
                            title: const Text('First group'),
                            tiles: [SettingsTile(title: const Text('A'))],
                          ),
                          SettingsSection(
                            title: const Text('Second group'),
                            tiles: [SettingsTile(title: const Text('B'))],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          platform: TargetPlatform.windows,
        ),
      );
      await tester.pumpAndSettle();
      final title = tester.getRect(find.text('Page title'));
      final first = tester.getRect(find.text('First group'));
      expect(first.top - title.bottom, 19);
      // Later groups keep their 30 (+ 3 after a card).
      final card = tester.getRect(
        find
            .ancestor(
              of: find.text('A'),
              matching: find.byType(FluentSettingsTile),
            )
            .first,
      );
      expect(tester.getRect(find.text('Second group')).top - card.bottom, 33);
    });

    testWidgets('one pane: cards under a Title, a back button on pages', (
      tester,
    ) async {
      await _pump(tester, DevicePlatform.windows, size: const Size(520, 800));
      expect(_isSplit(tester), isFalse);
      expect(find.byType(FluentNavigationItem), findsNothing);
      expect(find.byType(FluentSettingsTile), findsWidgets);
      final listTitle = find.descendant(
        of: find.byType(FluentPageHeader),
        matching: find.text('Settings'),
      );
      expect(_textStyle(tester, listTitle).fontSize, 28);
      // 16 margins below 641.
      expect(tester.getRect(listTitle).left, 16);

      await tester.tap(find.text('Display'));
      await tester.pumpAndSettle();
      final back = find.byType(FluentSubtleButton);
      expect(back, findsOneWidget);
      expect(tester.getSize(back), const Size(40, 36));
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();
      // The nested page has the breadcrumb instead.
      expect(
        find.descendant(
          of: find.byType(FluentPageHeader).last,
          matching: find.text('Display & brightness'),
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(FluentPageHeader).last,
          matching: find.text('Display & brightness'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FluentSubtleButton));
      await tester.pumpAndSettle();
      expect(_selectedId(tester), isNull);
      expect(find.text('Display & brightness'), findsNothing);
    });
  });

  group('GNOME sidebar', () {
    for (final brightness in Brightness.values) {
      testWidgets('rows, selection and separators (${brightness.name})', (
        tester,
      ) async {
        await _pump(tester, DevicePlatform.linux, brightness: brightness);
        final theme = _theme(tester, DevicePlatform.linux, brightness);
        final dark = brightness == Brightness.dark;
        final foreground = theme.settingsTileTextColor!;

        expect(_inList(find.byType(AdwaitaSidebarRow)), findsNWidgets(4));
        expect(_inList(find.byType(AdwaitaSettingsTile)), findsNothing);
        expect(
          find.ancestor(
            of: find.text('Network body'),
            matching: find.byType(AdwaitaSettingsTile),
          ),
          findsOneWidget,
        );
        expect(
          theme.listPaneBackground,
          dark ? const Color(0xFF2E2E32) : const Color(0xFFEBEBED),
        );

        // The selected row: a neutral grey (10% of the foreground), 9
        // corners, 43 tall, 6 from the sidebar sides; the label keeps the
        // foreground color.
        expect(_selectedTitles(tester), ['Network']);
        final selected = _fillDecoration(tester, AdwaitaSidebarRow, 'Network');
        expect(selected.color, theme.selectedTileColor);
        if (!dark) expect(selected.color, const Color(0xFFD8D8DB));
        expect(selected.borderRadius, BorderRadius.circular(9));
        final rect = tester.getRect(
          _fillOf(AdwaitaSidebarRow, 'Network').first,
        );
        expect(rect.left, 6);
        expect(rect.width, 280 - 12);
        expect(rect.height, 43);
        // 6 list padding below the 46 header bar.
        expect(rect.top, 46 + 6);
        final label = _textStyle(tester, _inList(find.text('Network')));
        expect(label.color, foreground);
        expect(label.fontSize, closeTo(14.67, 0.01));
        expect(label.fontWeight, FontWeight.w400);
        expect(tester.getRect(_inList(find.text('Network'))).left, 48);
        expect(tester.getRect(_inList(find.byIcon(Icons.wifi))).left, 20);
        expect(
          IconTheme.of(tester.element(_inList(find.byIcon(Icons.wifi)))).size,
          16,
        );
        // Rows are 45 apart.
        expect(
          tester.getRect(_fillOf(AdwaitaSidebarRow, 'Airplane mode').first).top,
          rect.top + 45,
        );

        expect(_fillDecoration(tester, AdwaitaSidebarRow, 'Sound').color!.a, 0);
        // Groups are split by a line of the foreground at 15%.
        final separator = _inList(find.byType(AdwaitaSidebarSeparator));
        expect(separator, findsOneWidget);
        final line = tester.widget<ColoredBox>(
          find.descendant(of: separator, matching: find.byType(ColoredBox)),
        );
        expect(line.color, foreground.withValues(alpha: foreground.a * 0.15));
        expect(tester.getRect(separator).height, 6 + 1 + 6);
        // Rows on both sides of it are 58 apart, as in GNOME Settings,
        // plus the 30 of the next group's heading (6 + an 18 line + 6).
        expect(tester.getRect(_inList(find.text('Device'))).height, 18);
        expect(
          tester.getRect(_fillOf(AdwaitaSidebarRow, 'Display').first).top -
              tester
                  .getRect(_fillOf(AdwaitaSidebarRow, 'Airplane mode').first)
                  .top,
          58 + 30,
        );

        // The sidebar's border on its content side.
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).border ==
                    BorderDirectional(
                      end: BorderSide(
                        color: dark
                            ? const Color.fromRGBO(0, 0, 6, 0.36)
                            : const Color.fromRGBO(0, 0, 6, 0.07),
                      ),
                    ),
          ),
          findsOneWidget,
        );
      });
    }

    testWidgets('hover 7%, pressed 16%, selected and hovered 13%', (
      tester,
    ) async {
      await _pump(tester, DevicePlatform.linux);
      final foreground = _theme(
        tester,
        DevicePlatform.linux,
        Brightness.light,
      ).settingsTileTextColor!;
      Color share(double value) =>
          foreground.withValues(alpha: foreground.a * value);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(_inList(find.text('Sound'))));
      await tester.pumpAndSettle();
      expect(
        _fillDecoration(tester, AdwaitaSidebarRow, 'Sound').color,
        share(0.07),
      );
      await gesture.down(tester.getCenter(_inList(find.text('Sound'))));
      await tester.pumpAndSettle();
      expect(
        _fillDecoration(tester, AdwaitaSidebarRow, 'Sound').color,
        share(0.16),
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_selectedTitles(tester), ['Sound']);
      expect(
        _fillDecoration(tester, AdwaitaSidebarRow, 'Sound').color,
        share(0.13),
      );
    });

    testWidgets('a header bar with the title over the sidebar and the page', (
      tester,
    ) async {
      await _pump(tester, DevicePlatform.linux);
      final bars = find.byType(AdwaitaHeaderBar);
      expect(bars, findsNWidgets(2));
      for (final bar in bars.evaluate()) {
        expect(tester.getSize(find.byWidget(bar.widget)).height, 46);
      }
      final sidebarTitle = _inList(find.text('Settings'));
      final style = _textStyle(tester, sidebarTitle);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.fontSize, closeTo(14.67, 0.01));
      // Centered over the sidebar, and the page title over the page.
      expect(tester.getCenter(sidebarTitle).dx, closeTo(140, 0.5));
      final pageTitle = find.descendant(
        of: find.byType(AdwaitaHeaderBar).last,
        matching: find.text('Network'),
      );
      expect(
        tester.getCenter(pageTitle).dx,
        closeTo(280 + (1280 - 280) / 2, 0.5),
      );
      expect(find.byType(AdwaitaFlatButton), findsNothing);

      // A nested page gets the flat 34x34 back button.
      await tester.tap(_inList(find.text('Display')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();
      final back = find.byType(AdwaitaFlatButton);
      expect(back, findsOneWidget);
      expect(tester.getSize(back), const Size(34, 34));
      expect(tester.getRect(back).left, 280 + 6);
      expect(
        ModalRoute.of(tester.element(find.text('Larger'))),
        isA<CupertinoPageRoute<void>>(),
      );
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(find.text('Larger'), findsNothing);
    });

    testWidgets('collapsed: the sidebar is the first page, nothing selected', (
      tester,
    ) async {
      await _pump(tester, DevicePlatform.linux, size: const Size(520, 800));
      expect(_isSplit(tester), isFalse);
      expect(find.byType(AdwaitaSidebarRow), findsNWidgets(4));
      expect(find.byType(AdwaitaSettingsTile), findsNothing);
      expect(_selectedTitles(tester), isEmpty);
      for (final title in ['Network', 'Display', 'Sound']) {
        expect(_fillDecoration(tester, AdwaitaSidebarRow, title).color!.a, 0);
      }
      expect(
        tester.widget<Material>(_inList(find.byType(Material)).first).color,
        const Color(0xFFEBEBED),
      );
      expect(find.byType(AdwaitaFlatButton), findsNothing);

      await tester.tap(find.text('Display'));
      await tester.pumpAndSettle();
      expect(find.byType(AdwaitaFlatButton), findsOneWidget);
      await tester.tap(find.byType(AdwaitaFlatButton));
      await tester.pumpAndSettle();
      expect(_selectedId(tester), isNull);
      expect(_selectedTitles(tester), isEmpty);
    });

    testWidgets('a switch row toggles when the row is clicked', (tester) async {
      var value = false;
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => SettingsSplitView(
              platform: DevicePlatform.linux,
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile.switchTile(
                      title: const Text('Airplane mode'),
                      initialValue: value,
                      onToggle: (v) => setState(() => value = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          platform: TargetPlatform.linux,
        ),
      );
      await tester.tap(find.text('Airplane mode'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });
  });

  group('keyboard', () {
    for (final (platform, type) in [
      (DevicePlatform.macOS, MacosSidebarItem),
      (DevicePlatform.windows, FluentNavigationItem),
      (DevicePlatform.linux, AdwaitaSidebarRow),
    ]) {
      testWidgets('$platform: Tab to a row, Enter selects it', (tester) async {
        await _pump(tester, platform);
        await _tabTo(tester, type, 'Sound');
        expect(_selectedId(tester), 'network');
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(_selectedId(tester), 'sound');
        expect(find.text('Sound body'), findsOneWidget);
      });

      testWidgets('$platform: the arrow keys move between rows', (
        tester,
      ) async {
        await _pump(tester, platform);
        await _tabTo(tester, type, 'Display');
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        final macos = platform == DevicePlatform.macOS;
        // macOS: the selection follows the arrow keys, like System
        // Settings. Elsewhere Enter selects the focused row.
        expect(_selectedId(tester), macos ? 'sound' : 'network');
        if (!macos) {
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pumpAndSettle();
          expect(_selectedId(tester), 'sound');
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(_selectedId(tester), 'display');
      });
    }

    for (final platform in [
      DevicePlatform.macOS,
      DevicePlatform.windows,
      DevicePlatform.linux,
    ]) {
      for (final direction in TextDirection.values) {
        testWidgets(
          '$platform ${direction.name}: Tab starts in the list pane, then '
          'the page',
          (tester) async {
            await _setSize(tester, const Size(1280, 800));
            SettingsTile row(String name) => SettingsTile.navigation(
              title: Text('Row $name'),
              destination: SettingsDestination(
                id: name,
                builder: (context) => SettingsList(
                  sections: [
                    SettingsSection(
                      tiles: [
                        SettingsTile(
                          title: Text('Body $name'),
                          onPressed: (_) {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
            await tester.pumpWidget(
              _app(
                SettingsSplitView(
                  platform: platform,
                  title: const Text('Settings'),
                  sections: [
                    SettingsSection(tiles: [row('A'), row('B')]),
                  ],
                ),
                platform: _targetOf(platform),
                textDirection: direction,
              ),
            );
            await tester.pumpAndSettle();

            String? focusedText() {
              final context = FocusManager.instance.primaryFocus?.context;
              if (context == null) return null;
              final texts = find
                  .descendant(
                    of: find.byElementPredicate((e) => e == context),
                    matching: find.byType(Text),
                  )
                  .evaluate()
                  .map((e) => (e.widget as Text).data);
              return texts.isEmpty ? null : texts.first;
            }

            final order = <String?>[];
            for (var i = 0; i < 4; i++) {
              await tester.sendKeyEvent(LogicalKeyboardKey.tab);
              await tester.pump();
              order.add(focusedText());
            }
            expect(order, ['Row A', 'Row B', 'Body A', 'Row A']);
          },
        );
      }
    }

    testWidgets('macOS: the focus ring follows the selection shape', (
      tester,
    ) async {
      await _pump(tester, DevicePlatform.macOS);
      await _tabTo(tester, MacosSidebarItem, 'Sound');
      await tester.pumpAndSettle();
      final ring = find.descendant(
        of: _row(MacosSidebarItem, 'Sound'),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.position == DecorationPosition.foreground &&
              (widget.decoration as BoxDecoration).border != null,
        ),
      );
      expect(ring, findsOneWidget);
      final decoration =
          tester.widget<DecoratedBox>(ring).decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(8));
      expect((decoration.border! as Border).top.width, 3);
    });

    testWidgets('GNOME: the 2px accent focus ring', (tester) async {
      await _pump(tester, DevicePlatform.linux);
      await _tabTo(tester, AdwaitaSidebarRow, 'Sound');
      await tester.pumpAndSettle();
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: _row(AdwaitaSidebarRow, 'Sound'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final ring = container.foregroundDecoration! as BoxDecoration;
      expect(ring.borderRadius, BorderRadius.circular(9));
      expect(
        (ring.border! as Border).top,
        BorderSide(
          color: const Color(0xFF0461BE).withValues(alpha: 0.5),
          width: 2,
        ),
      );
    });
  });

  group('right to left', () {
    testWidgets('macOS: the sidebar on the right, the capsule mirrored', (
      tester,
    ) async {
      await _pump(
        tester,
        DevicePlatform.macOS,
        textDirection: TextDirection.rtl,
      );
      expect(
        tester.getRect(_listPane),
        const Rect.fromLTWH(1280 - 232, 0, 232, 800),
      );
      final fill = tester.getRect(_fillOf(MacosSidebarItem, 'Network').first);
      expect(fill.left, 1280 - 232 + 10);
      expect(fill.right, 1280 - 10);
      // The label starts 46 from the sidebar's right edge.
      expect(tester.getRect(_inList(find.text('Network'))).right, 1280 - 46);
      final title = find.descendant(
        of: find.byType(MacosToolbar),
        matching: find.text('Network'),
      );
      expect(tester.getRect(title).right, 1280 - 232 - 20);
    });

    testWidgets('Windows: the pane on the right, the pill at its start', (
      tester,
    ) async {
      await _pump(
        tester,
        DevicePlatform.windows,
        textDirection: TextDirection.rtl,
      );
      final pane = tester.getRect(_listPane);
      expect(pane, const Rect.fromLTWH(1280 - 300, 0, 300, 800));
      final fill = tester.getRect(
        _fillOf(FluentNavigationItem, 'Network').first,
      );
      expect(fill.right, 1280 - 16);
      final row = tester.getRect(_row(FluentNavigationItem, 'Network'));
      expect(
        _pillRect(tester, 'Network', FluentTokens.light.accent),
        Rect.fromLTRB(row.width - 7, 12, row.width - 4, 28),
      );
      // The page title aligns with the content's right edge.
      final title = find.descendant(
        of: find.byType(FluentPageHeader),
        matching: find.text('Network'),
      );
      expect(tester.getRect(title).right, 1280 - 300 - 24);
    });

    testWidgets('Windows compact rail: the pane opens from the right', (
      tester,
    ) async {
      await _pump(
        tester,
        DevicePlatform.windows,
        size: const Size(900, 700),
        textDirection: TextDirection.rtl,
      );
      expect(
        tester.getRect(_listPane),
        const Rect.fromLTWH(900 - 48, 0, 48, 700),
      );
      await tester.tap(find.bySemanticsLabel('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(_listPane),
        const Rect.fromLTWH(900 - 320, 0, 320, 700),
      );
    });

    testWidgets('GNOME: the sidebar and its border on the right', (
      tester,
    ) async {
      await _pump(
        tester,
        DevicePlatform.linux,
        textDirection: TextDirection.rtl,
      );
      expect(
        tester.getRect(_listPane),
        const Rect.fromLTWH(1280 - 280, 0, 280, 800),
      );
      final fill = tester.getRect(_fillOf(AdwaitaSidebarRow, 'Network').first);
      expect(fill.left, 1280 - 280 + 6);
      expect(tester.getRect(_inList(find.text('Network'))).right, 1280 - 48);
    });
  });

  group('large text', () {
    for (final platform in [
      DevicePlatform.macOS,
      DevicePlatform.windows,
      DevicePlatform.linux,
    ]) {
      for (final size in [
        const Size(1280, 800),
        const Size(900, 700),
        const Size(520, 800),
      ]) {
        testWidgets('$platform at 2x text, ${size.width.toInt()} wide: '
            'no overflow', (tester) async {
          await _pump(tester, platform, size: size, textScale: 2);
          expect(tester.takeException(), isNull);
          // Open a page and a nested page.
          SettingsSplitView.of(
            tester.element(find.byType(SettingsList).first),
          ).select('display');
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Text size').last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('rows grow with the text', (tester) async {
      await _pump(tester, DevicePlatform.macOS, textScale: 2);
      expect(
        tester.getRect(_fillOf(MacosSidebarItem, 'Network').first).height,
        greaterThan(32),
      );
      await _pump(tester, DevicePlatform.windows, textScale: 2);
      expect(
        tester.getRect(_fillOf(FluentNavigationItem, 'Network').first).height,
        greaterThan(36),
      );
      await _pump(tester, DevicePlatform.linux, textScale: 2);
      expect(
        tester.getRect(_fillOf(AdwaitaSidebarRow, 'Network').first).height,
        greaterThan(43),
      );
    });
  });

  group('pages in the detail pane', () {
    testWidgets('keep their column rules', (tester) async {
      ListView detailList() => tester.widget<ListView>(
        find
            .descendant(
              of: find
                  .ancestor(
                    of: find.text('Network body'),
                    matching: find.byType(SettingsList),
                  )
                  .first,
              matching: find.byType(ListView),
            )
            .first,
      );
      double detailWidth() => tester
          .getSize(
            find
                .ancestor(
                  of: find.text('Network body'),
                  matching: find.byType(SettingsList),
                )
                .first,
          )
          .width;

      // macOS: the 640pt column, centered in the pane.
      await _pump(tester, DevicePlatform.macOS);
      var padding = detailList().padding! as EdgeInsets;
      expect(detailWidth(), 1280 - 232);
      expect(padding.left, (detailWidth() - 640) / 2);
      expect(padding.right, (detailWidth() - 640) / 2);

      // Windows: 24 margins.
      await _pump(tester, DevicePlatform.windows);
      padding = detailList().padding! as EdgeInsets;
      expect(padding.left, 24);
      expect(padding.right, 24);

      // GNOME: the AdwClamp column, at most 600.
      await _pump(tester, DevicePlatform.linux);
      padding = detailList().padding! as EdgeInsets;
      expect(detailWidth() - padding.horizontal, 600);
    });

    testWidgets('macOS: 30pt after a footer', (tester) async {
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: DevicePlatform.macOS,
            title: const Text('Settings'),
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile.navigation(
                    title: const Text('Page'),
                    destination: SettingsDestination(
                      id: 'page',
                      builder: (context) => SettingsList(
                        sections: [
                          SettingsSection(
                            tiles: [
                              SettingsTile(
                                title: const Text('A'),
                                description: const Text('F1'),
                              ),
                            ],
                          ),
                          SettingsSection(
                            tiles: [SettingsTile(title: const Text('B'))],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          platform: TargetPlatform.macOS,
        ),
      );
      await tester.pumpAndSettle();
      final footer = tester.getRect(find.text('F1'));
      final next = tester.getRect(
        find
            .ancestor(
              of: find.text('B'),
              matching: find.byType(MacosSettingsTile),
            )
            .first,
      );
      expect(next.top - footer.bottom, 30);
    });

    testWidgets('the styles define the split view tokens', (tester) async {
      await tester.pumpWidget(
        _app(const SizedBox(), platform: TargetPlatform.macOS),
      );
      final context = tester.element(find.byType(SizedBox));
      for (final platform in [
        DevicePlatform.macOS,
        DevicePlatform.windows,
        DevicePlatform.linux,
      ]) {
        for (final brightness in Brightness.values) {
          final theme = ThemeProvider.getTheme(
            context: context,
            platform: platform,
            brightness: brightness,
          );
          final reason = '$platform ${brightness.name}';
          expect(theme.listPaneBackground, isNotNull, reason: reason);
          expect(theme.selectedTileColor, isNotNull, reason: reason);
          expect(theme.selectedTileTextColor, isNotNull, reason: reason);
          expect(theme.selectedTileIconColor, isNotNull, reason: reason);
        }
      }
    });

    test('pages slide in on iOS, macOS and GNOME', () {
      expect(
        settingsUsesCupertinoRoutes(settingsStyleFamily(DevicePlatform.macOS)),
        isTrue,
      );
      expect(
        settingsUsesCupertinoRoutes(settingsStyleFamily(DevicePlatform.linux)),
        isTrue,
      );
      expect(
        settingsUsesCupertinoRoutes(
          settingsStyleFamily(DevicePlatform.windows),
        ),
        isFalse,
      );
    });
  });
}

/// The pill that the Windows item [title] paints, in its coordinates.
Rect? _pillRect(WidgetTester tester, String title, Color accent) {
  final recorder = _RRectRecorder(accent);
  final renderObject = tester.renderObject<RenderBox>(
    _row(FluentNavigationItem, title),
  );
  expect(renderObject, paints..everything(recorder.call));
  return recorder.rect;
}

class _RRectRecorder {
  _RRectRecorder(this.color);

  final Color color;
  Rect? rect;

  bool call(Symbol method, List<dynamic> arguments) {
    if (method == #drawRRect &&
        arguments.length > 1 &&
        (arguments[1] as Paint).color.toARGB32() == color.toARGB32()) {
      rect = (arguments[0] as RRect).outerRect;
    }
    return true;
  }
}
