import 'dart:ui' show Tristate;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/split/adwaita_split.dart';
import 'package:settings_ui/src/split/fluent_split.dart';
import 'package:settings_ui/src/split/macos_split.dart';
import 'package:settings_ui/src/tiles/platforms/fluent_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/macos_settings_tile.dart';

/// Regression tests for the split view bugs found in the 4.0.0 release
/// candidate: back and layout changes with routes pushed from the list pane,
/// the back swipe, apps without MaterialLocalizations, a controller moving
/// to a re-keyed view, stale destinations, keyboard focus and semantics in
/// the desktop sidebars, the Windows pane header and breadcrumb, and GNOME
/// text scaling.

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// A page with state, to check that it survives.
class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _count++),
        child: Text('Count $_count'),
      ),
    );
  }
}

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
                      builder: (context) => const _Counter(),
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
  double textScale = 1,
  TextScaler? textScaler,
  Map<String, WidgetBuilder> routes = const {},
  String? restorationScopeId,
}) {
  return MaterialApp(
    restorationScopeId: restorationScopeId,
    theme: ThemeData(platform: platform),
    routes: routes,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: textScaler ?? TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
  );
}

/// [view] pushed over a home page, so the settings screen can be left.
Widget _pushedFromHome(
  Widget view, {
  TargetPlatform? platform,
  Map<String, WidgetBuilder> routes = const {},
}) => _app(
  Builder(
    builder: (context) => Center(
      child: GestureDetector(
        onTap: () =>
            Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => view)),
        child: const Text('Open settings'),
      ),
    ),
  ),
  platform: platform,
  routes: routes,
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

/// Whether the sidebar row of [title] shows its focus ring.
bool _ringShown(WidgetTester tester, DevicePlatform platform, String title) {
  final type = switch (platform) {
    DevicePlatform.macOS => MacosSidebarItem,
    DevicePlatform.windows => FluentNavigationItem,
    _ => AdwaitaSidebarRow,
  };
  final row = find.ancestor(
    of: _inList(find.text(title)),
    matching: find.byType(type),
  );
  switch (platform) {
    case DevicePlatform.macOS:
      return find
          .descendant(
            of: row,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is DecoratedBox &&
                  widget.position == DecorationPosition.foreground &&
                  (widget.decoration as BoxDecoration).border != null,
            ),
          )
          .evaluate()
          .isNotEmpty;
    case DevicePlatform.windows:
      return find
          .descendant(
            of: row,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is CustomPaint &&
                  widget.foregroundPainter.runtimeType.toString() ==
                      '_FocusRingPainter',
            ),
          )
          .evaluate()
          .isNotEmpty;
    default:
      return tester
              .widget<AnimatedContainer>(
                find.descendant(
                  of: row,
                  matching: find.byType(AnimatedContainer),
                ),
              )
              .foregroundDecoration !=
          null;
  }
}

void splitViewRegressionTests() {
  group('one pane: routes pushed from the list pane', () {
    SettingsSplitView view(
      DevicePlatform platform, {
      Widget page = const Scaffold(body: Text('About page')),
    }) => SettingsSplitView(
      platform: platform,
      title: const Text('Settings'),
      sections: [
        SettingsSection(
          tiles: [
            // The settings_ui 3.x way to open a page, still common for
            // "About", licenses and so on.
            SettingsTile.navigation(
              title: const Text('About'),
              onPressed: (context) =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => page)),
            ),
            SettingsTile.navigation(
              title: const Text('Licenses'),
              onPressed: (context) =>
                  Navigator.of(context).pushNamed('/licenses'),
            ),
            SettingsTile.navigation(
              title: const Text('Sheet'),
              onPressed: (context) => showModalBottomSheet<void>(
                context: context,
                builder: (_) => const SizedBox(
                  height: 200,
                  child: Center(child: Text('Sheet body')),
                ),
              ),
            ),
            ...(_sections().first as SettingsSection).tiles,
          ],
        ),
      ],
    );

    for (final platform in [
      DevicePlatform.android,
      DevicePlatform.iOS,
      DevicePlatform.linux,
    ]) {
      testWidgets('$platform: back closes the pushed page, then the screen', (
        tester,
      ) async {
        await _setSize(tester, const Size(412, 915));
        await tester.pumpWidget(
          _pushedFromHome(view(platform), platform: _targetOf(platform)),
        );
        await tester.tap(find.text('Open settings'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('About'));
        await tester.pumpAndSettle();
        expect(find.text('About page'), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('About page'), findsNothing);
        expect(find.text('Open settings'), findsNothing);
        expect(find.text('Airplane mode'), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Open settings'), findsOneWidget);
      });
    }

    testWidgets('a pushed page can veto back', (tester) async {
      var vetoed = 0;
      await _setSize(tester, const Size(412, 915));
      await tester.pumpWidget(
        _pushedFromHome(
          view(
            DevicePlatform.android,
            page: PopScope<Object?>(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) vetoed++;
              },
              child: const Scaffold(body: Text('About page')),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(vetoed, 1);
      expect(find.text('About page'), findsOneWidget);
    });

    testWidgets('a bottom sheet closes first', (tester) async {
      await _setSize(tester, const Size(412, 915));
      await tester.pumpWidget(_pushedFromHome(view(DevicePlatform.android)));
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sheet'));
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Sheet body'), findsNothing);
      expect(find.text('Airplane mode'), findsOneWidget);
    });

    testWidgets('named routes come from the app', (tester) async {
      await _setSize(tester, const Size(412, 915));
      await tester.pumpWidget(
        _pushedFromHome(
          view(DevicePlatform.android),
          routes: {
            '/licenses': (_) => const Scaffold(body: Text('Licenses page')),
          },
        ),
      );
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Licenses'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Licenses page'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Licenses page'), findsNothing);
      expect(find.text('Airplane mode'), findsOneWidget);
    });

    testWidgets('widening keeps the pushed page, and one pane until it '
        'closes', (tester) async {
      await _setSize(tester, const Size(402, 874));
      await tester.pumpWidget(
        _app(view(DevicePlatform.iOS), platform: TargetPlatform.iOS),
      );
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      await _setSize(tester, const Size(1194, 834));
      await tester.pumpAndSettle();
      expect(find.text('About page'), findsOneWidget);
      expect(_controllerOf(tester).isSplit, isFalse);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('About page'), findsNothing);
      // Two panes once the page is gone, on the first page.
      expect(_controllerOf(tester).isSplit, isTrue);
      expect(find.text('Network body'), findsOneWidget);
    });
  });

  group('one pane: the back swipe', () {
    for (final platform in [
      DevicePlatform.iOS,
      DevicePlatform.macOS,
      DevicePlatform.linux,
    ]) {
      Future<void> swipeBack(WidgetTester tester) async {
        final gesture = await tester.startGesture(const Offset(5, 400));
        await gesture.moveBy(const Offset(50, 0));
        await tester.pump();
        await gesture.moveBy(const Offset(300, 0));
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();
      }

      testWidgets('$platform: respects a page that vetoes back', (
        tester,
      ) async {
        var vetoed = 0;
        await _setSize(tester, const Size(400, 800));
        await tester.pumpWidget(
          _app(
            SettingsSplitView(
              platform: platform,
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile.navigation(
                      title: const Text('Form'),
                      destination: SettingsDestination(
                        id: 'form',
                        builder: (_) => PopScope<Object?>(
                          canPop: false,
                          onPopInvokedWithResult: (didPop, _) {
                            if (!didPop) vetoed++;
                          },
                          child: const Center(child: Text('Unsaved changes')),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            platform: _targetOf(platform),
          ),
        );
        await tester.tap(find.text('Form'));
        await tester.pumpAndSettle();

        await swipeBack(tester);
        expect(find.text('Unsaved changes'), findsOneWidget);

        // Back asks the page, which vetoes.
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(vetoed, 1);
        expect(find.text('Unsaved changes'), findsOneWidget);
      });

      testWidgets('$platform: closes a page, then a nested page first', (
        tester,
      ) async {
        await _setSize(tester, const Size(400, 800));
        await tester.pumpWidget(
          _app(
            SettingsSplitView(platform: platform, sections: _sections()),
            platform: _targetOf(platform),
          ),
        );
        await tester.tap(_inList(find.text('Sound')));
        await tester.pumpAndSettle();
        await swipeBack(tester);
        expect(find.text('Sound body'), findsNothing);
        expect(_controllerOf(tester).selectedId, isNull);

        await tester.tap(_inList(find.text('Display')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Text size'));
        await tester.pumpAndSettle();
        expect(find.text('Count 0'), findsOneWidget);
        // The nested page's own swipe closes it, not the page under it.
        await swipeBack(tester);
        expect(find.text('Count 0'), findsNothing);
        expect(find.text('Text size'), findsOneWidget);
        expect(_controllerOf(tester).selectedId, 'display');
      });
    }
  });

  group('apps without MaterialLocalizations', () {
    Widget cupertinoApp(Widget home) => CupertinoApp(home: home);
    Widget widgetsApp(Widget home) => WidgetsApp(
      color: const Color(0xFF2196F3),
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, _, _) => builder(context),
          ),
      home: home,
    );

    for (final (name, wrap) in [
      ('CupertinoApp', cupertinoApp),
      ('WidgetsApp', widgetsApp),
    ]) {
      for (final platform in [
        DevicePlatform.iOS,
        DevicePlatform.android,
        DevicePlatform.web,
        DevicePlatform.macOS,
        DevicePlatform.windows,
        DevicePlatform.linux,
      ]) {
        testWidgets('$name, $platform: every layout, pages, back and the '
            'Windows pane', (tester) async {
          for (final size in const [
            Size(400, 800),
            Size(800, 700),
            Size(1280, 800),
          ]) {
            await _setSize(tester, size);
            await tester.pumpWidget(
              wrap(
                SettingsSplitView(
                  key: ValueKey(size),
                  platform: platform,
                  applicationType: ApplicationType.cupertino,
                  title: const Text('Settings'),
                  sections: _sections(),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '$size');

            final controller = _controllerOf(tester);
            if (platform == DevicePlatform.windows &&
                controller.isSplit &&
                size.width < 1008) {
              // The compact rail: its tooltips and the pane over the page.
              final mouse = await tester.createGesture(
                kind: PointerDeviceKind.mouse,
              );
              await mouse.addPointer(location: Offset.zero);
              await mouse.moveTo(
                tester.getCenter(_inList(find.byIcon(Icons.volume_up))),
              );
              await tester.pump(const Duration(seconds: 1));
              await mouse.moveTo(Offset.zero);
              await mouse.removePointer();
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull, reason: '$size');
              await tester.tap(find.bySemanticsLabel('Open navigation menu'));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull, reason: '$size');
            }

            await tester.tap(_inList(find.text('Display')).first);
            await tester.pumpAndSettle();
            await tester.tap(find.text('Text size'));
            await tester.pumpAndSettle();
            expect(find.text('Count 0'), findsOneWidget, reason: '$size');
            expect(tester.takeException(), isNull, reason: '$size');

            await tester.binding.handlePopRoute();
            await tester.pumpAndSettle();
            await tester.binding.handlePopRoute();
            await tester.pumpAndSettle();
            expect(find.text('Count 0'), findsNothing, reason: '$size');
            expect(tester.takeException(), isNull, reason: '$size');
          }
        });
      }
    }
  });

  group('controller', () {
    testWidgets('a re-keyed view with the same controller takes it over', (
      tester,
    ) async {
      final controller = SettingsSplitController();
      addTearDown(controller.dispose);
      await _setSize(tester, const Size(1280, 800));
      Widget app(DevicePlatform platform) => _app(
        SettingsSplitView(
          key: ValueKey(platform),
          platform: platform,
          controller: controller,
          sections: _sections(),
        ),
      );

      await tester.pumpWidget(app(DevicePlatform.android));
      await tester.pumpAndSettle();
      controller.select('sound');
      await tester.pumpAndSettle();
      expect(find.text('Sound body'), findsOneWidget);

      await tester.pumpWidget(app(DevicePlatform.macOS));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(controller.isSplit, isTrue);
      expect(controller.selectedId, 'network');
      controller.select('display');
      await tester.pumpAndSettle();
      expect(find.text('Text size'), findsOneWidget);
      expect(controller.selectedId, 'display');
    });

    testWidgets('two views at once with one controller still report it', (
      tester,
    ) async {
      final controller = SettingsSplitController();
      addTearDown(controller.dispose);
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _app(
          Row(
            children: [
              for (final platform in [
                DevicePlatform.android,
                DevicePlatform.iOS,
              ])
                Expanded(
                  child: SettingsSplitView(
                    platform: platform,
                    controller: controller,
                    layout: SettingsSplitLayout.single,
                    sections: _sections(),
                  ),
                ),
            ],
          ),
        ),
      );
      expect(
        tester.takeException().toString(),
        contains('can only be used by one SettingsSplitView at a time'),
      );
    });
  });
  group('destinations', () {
    /// A list with a conditional page, like "Developer options" that shows
    /// only while enabled.
    Widget conditional(
      ValueNotifier<bool> show,
      DevicePlatform platform, {
      ValueChanged<String?>? onDestinationChanged,
    }) => ValueListenableBuilder<bool>(
      valueListenable: show,
      builder: (context, value, _) => SettingsSplitView(
        platform: platform,
        onDestinationChanged: onDestinationChanged,
        sections: [
          SettingsSection(
            tiles: [
              (_sections().first as SettingsSection).tiles.first,
              if (value)
                SettingsTile.navigation(
                  title: const Text('Developer'),
                  destination: SettingsDestination(
                    id: 'dev',
                    builder: (_) => const Center(child: Text('Dev body')),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    testWidgets('two panes: a removed page does not come back with its tile', (
      tester,
    ) async {
      final show = ValueNotifier<bool>(true);
      addTearDown(show.dispose);
      final changes = <String?>[];
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _app(
          conditional(
            show,
            DevicePlatform.macOS,
            onDestinationChanged: changes.add,
          ),
          platform: TargetPlatform.macOS,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Developer'));
      await tester.pumpAndSettle();
      expect(find.text('Dev body'), findsOneWidget);

      show.value = false;
      await tester.pumpAndSettle();
      expect(find.text('Network body'), findsOneWidget);
      expect(_controllerOf(tester).selectedId, 'network');

      show.value = true;
      await tester.pumpAndSettle();
      expect(find.text('Network body'), findsOneWidget);
      expect(find.text('Dev body'), findsNothing);
      expect(_controllerOf(tester).selectedId, 'network');
      expect(changes, ['dev', 'network']);
    });

    testWidgets('one pane: a removed page is not pushed again with its tile', (
      tester,
    ) async {
      final show = ValueNotifier<bool>(true);
      addTearDown(show.dispose);
      await _setSize(tester, const Size(402, 874));
      await tester.pumpWidget(
        _app(
          conditional(show, DevicePlatform.iOS),
          platform: TargetPlatform.iOS,
        ),
      );
      await tester.tap(find.text('Developer'));
      await tester.pumpAndSettle();
      show.value = false;
      await tester.pumpAndSettle();
      expect(find.text('Dev body'), findsNothing);
      expect(_controllerOf(tester).selectedId, isNull);

      show.value = true;
      await tester.pumpAndSettle();
      expect(find.text('Dev body'), findsNothing);
      expect(_controllerOf(tester).selectedId, isNull);
    });

    Widget customSection(
      ValueNotifier<int> version, {
      DevicePlatform platform = DevicePlatform.macOS,
      String? restorationId,
    }) => ValueListenableBuilder<int>(
      valueListenable: version,
      builder: (context, v, _) => SettingsSplitView(
        platform: platform,
        restorationId: restorationId,
        sections: [
          SettingsSection(
            tiles: [(_sections().first as SettingsSection).tiles.first],
          ),
          CustomSettingsSection(
            child: SettingsTile.navigation(
              title: const Text('Account'),
              destination: SettingsDestination(
                id: 'account',
                title: Text('Account title v$v'),
                builder: (_) => Center(child: Text('Account v$v')),
              ),
            ),
          ),
        ],
      ),
    );

    testWidgets('a page opened from a custom section follows its tile', (
      tester,
    ) async {
      final version = ValueNotifier<int>(1);
      addTearDown(version.dispose);
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _app(customSection(version), platform: TargetPlatform.macOS),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      expect(find.text('Account v1'), findsOneWidget);
      expect(find.text('Account title v1'), findsOneWidget);

      version.value = 2;
      await tester.pumpAndSettle();
      expect(find.text('Account v2'), findsOneWidget);
      expect(find.text('Account title v2'), findsOneWidget);
      expect(find.text('Account v1'), findsNothing);
    });

    testWidgets('a page opened from a custom section is restored', (
      tester,
    ) async {
      final version = ValueNotifier<int>(1);
      addTearDown(version.dispose);
      await _setSize(tester, const Size(402, 874));
      await tester.pumpWidget(
        _app(
          customSection(
            version,
            platform: DevicePlatform.iOS,
            restorationId: 'settings',
          ),
          platform: TargetPlatform.iOS,
          restorationScopeId: 'app',
        ),
      );
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      expect(find.text('Account v1'), findsOneWidget);

      await tester.restartAndRestore();
      await tester.pumpAndSettle();
      expect(find.text('Account v1'), findsOneWidget);
      expect(_controllerOf(tester).selectedId, 'account');
    });
  });
  group('sidebar semantics', () {
    Tristate selectedOf(WidgetTester tester, Finder finder) => tester
        .getSemantics(finder)
        .getSemanticsData()
        .flagsCollection
        .isSelected;

    for (final platform in [
      DevicePlatform.macOS,
      DevicePlatform.windows,
      DevicePlatform.linux,
    ]) {
      testWidgets('$platform: the selected row says so, not its section', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _setSize(tester, const Size(1280, 900));
        await tester.pumpWidget(
          _app(
            SettingsSplitView(
              platform: platform,
              title: const Text('Settings'),
              sections: _sections(),
            ),
            platform: _targetOf(platform),
          ),
        );
        await tester.pumpAndSettle();

        final network = _inList(find.text('Network'));
        expect(selectedOf(tester, network), Tristate.isTrue);
        expect(
          tester
              .getSemantics(network)
              .parent!
              .getSemanticsData()
              .flagsCollection
              .isSelected,
          isNot(Tristate.isTrue),
        );
        expect(
          selectedOf(tester, _inList(find.text('Sound'))),
          Tristate.isFalse,
        );
        // A row without a page has no selected state.
        expect(
          selectedOf(tester, _inList(find.text('Airplane mode'))),
          Tristate.none,
        );

        await tester.tap(_inList(find.text('Sound')));
        await tester.pumpAndSettle();
        expect(
          selectedOf(tester, _inList(find.text('Sound'))),
          Tristate.isTrue,
        );
        expect(selectedOf(tester, network), Tristate.isFalse);
        handle.dispose();
      });
    }

    testWidgets('Windows compact rail: the selected item says so', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _setSize(tester, const Size(800, 700));
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: DevicePlatform.windows,
            sections: _sections(),
          ),
          platform: TargetPlatform.windows,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        selectedOf(tester, _inList(find.bySemanticsLabel('Network'))),
        Tristate.isTrue,
      );
      expect(
        selectedOf(tester, _inList(find.bySemanticsLabel('Sound'))),
        Tristate.isFalse,
      );
      handle.dispose();
    });

    testWidgets('GNOME one pane: no row is selected', (tester) async {
      final handle = tester.ensureSemantics();
      await _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: DevicePlatform.linux,
            sections: _sections(),
          ),
          platform: TargetPlatform.linux,
        ),
      );
      await tester.pumpAndSettle();
      for (final title in ['Network', 'Display', 'Sound']) {
        expect(
          selectedOf(tester, _inList(find.text(title))),
          Tristate.none,
          reason: title,
        );
      }
      handle.dispose();
    });
  });
  group('sidebar keyboard', () {
    for (final platform in [
      DevicePlatform.macOS,
      DevicePlatform.windows,
      DevicePlatform.linux,
    ]) {
      testWidgets('$platform: the arrow keys stay in the sidebar', (
        tester,
      ) async {
        await _setSize(tester, const Size(1280, 800));
        SettingsTile row(String name, {required int controls}) =>
            SettingsTile.navigation(
              leading: const Icon(Icons.list),
              title: Text(name),
              destination: SettingsDestination(
                id: name,
                builder: (_) => SettingsList(
                  sections: [
                    SettingsSection(
                      tiles: [
                        for (var i = 0; i < controls; i++)
                          SettingsTile(
                            title: Text('$name row $i'),
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
              initialDestinationId: 'Long',
              sections: [
                SettingsSection(
                  tiles: [
                    row('Short', controls: 1),
                    // Its page has controls lower than the last row, and
                    // to the side of the first one.
                    row('Long', controls: 20),
                  ],
                ),
              ],
            ),
            platform: _targetOf(platform),
          ),
        );
        await tester.pumpAndSettle();
        await _tabTo(tester, _tile('Long'));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(_focusIn(_tile('Long')), isTrue);
        expect(_controllerOf(tester).selectedId, 'Long');

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(_focusIn(_tile('Short')), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(_focusIn(_listPane), isTrue);
      });

      testWidgets('$platform: a click focuses the row, without a ring until '
          'a key is pressed', (tester) async {
        await _setSize(tester, const Size(1280, 800));
        await tester.pumpWidget(
          _app(
            SettingsSplitView(platform: platform, sections: _sections()),
            platform: _targetOf(platform),
          ),
        );
        await tester.pumpAndSettle();
        // Keyboard use first, so the focus rings would show.
        await tester.sendKeyEvent(LogicalKeyboardKey.shift);
        await tester.tap(
          _inList(find.text('Display')),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pumpAndSettle();
        expect(_controllerOf(tester).selectedId, 'display');
        expect(_focusIn(_tile('Display')), isTrue);
        expect(_ringShown(tester, platform, 'Display'), isFalse);

        // The keys go on from the clicked row.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(_focusIn(_tile('Sound')), isTrue);
        expect(_ringShown(tester, platform, 'Sound'), isTrue);
        expect(
          _controllerOf(tester).selectedId,
          platform == DevicePlatform.macOS ? 'sound' : 'display',
        );

        // Tab goes on from the clicked row too, not from the first one.
        await tester.tap(
          _inList(find.text('Display')),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pumpAndSettle();
        expect(_focusIn(_tile('Display')), isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(_focusIn(_tile('Sound')), isTrue);

        // A click on the focused row hides the ring again.
        await tester.tap(
          _inList(find.text('Network')),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pumpAndSettle();
        expect(_focusIn(_tile('Network')), isTrue);
        expect(_ringShown(tester, platform, 'Network'), isFalse);
        await tester.sendKeyEvent(LogicalKeyboardKey.shift);
        await tester.pump();
        expect(_ringShown(tester, platform, 'Network'), isTrue);
      });
    }

    for (final platform in [DevicePlatform.macOS, DevicePlatform.windows]) {
      testWidgets('$platform: Tab and Space reach a switch without '
          'onPressed', (tester) async {
        var value = false;
        await _setSize(tester, const Size(1280, 800));
        await tester.pumpWidget(
          _app(
            StatefulBuilder(
              builder: (context, setState) => SettingsSplitView(
                platform: platform,
                sections: [
                  SettingsSection(
                    tiles: [
                      (_sections().first as SettingsSection).tiles.first,
                      SettingsTile.switchTile(
                        leading: const Icon(Icons.airplanemode_active),
                        title: const Text('Airplane mode'),
                        initialValue: value,
                        onToggle: (v) => setState(() => value = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            platform: _targetOf(platform),
          ),
        );
        await tester.pumpAndSettle();
        await _tabTo(tester, _tile('Airplane mode'));
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(value, isTrue);
        // Still one tab stop per row: a row with onPressed keeps the focus
        // and its switch stays out of the way.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(_focusIn(_tile('Airplane mode')), isFalse);
      });
    }

    testWidgets('macOS: the first row\'s focus ring is not clipped', (
      tester,
    ) async {
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: DevicePlatform.macOS,
            sections: _sections(),
          ),
          platform: TargetPlatform.macOS,
        ),
      );
      await tester.pumpAndSettle();
      await _tabTo(tester, _tile('Network'));
      await tester.pumpAndSettle();
      expect(_ringShown(tester, DevicePlatform.macOS, 'Network'), isTrue);
      final row = find.ancestor(
        of: _inList(find.text('Network')),
        matching: find.byType(MacosSidebarItem),
      );
      final selection = tester.getRect(
        find.descendant(of: row, matching: find.byType(DecoratedBox)).first,
      );
      // The row still starts under the 52pt toolbar strip...
      expect(selection.top, 52);
      // ...and the list's viewport leaves room for the 3pt ring above it.
      final viewport = tester.getRect(
        find.descendant(of: _listPane, matching: find.byType(Scrollable)).first,
      );
      expect(viewport.top, lessThanOrEqualTo(selection.top - 3));
      expect(viewport.bottom, 800);
    });
  });

  group('keyboard focus across layout changes', () {
    for (final platform in [DevicePlatform.linux, DevicePlatform.android]) {
      testWidgets('$platform one pane: Tab stays in a page shown over the '
          'list', (tester) async {
        await _setSize(tester, const Size(400, 800));
        await tester.pumpWidget(
          _app(
            SettingsSplitView(
              platform: platform,
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile.navigation(
                      title: const Text('First'),
                      destination: SettingsDestination(
                        id: 'first',
                        builder: (_) => SettingsList(
                          sections: [
                            SettingsSection(
                              tiles: [
                                SettingsTile(
                                  title: const Text('First control'),
                                  onPressed: (_) {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SettingsTile.navigation(
                      title: const Text('Second'),
                      destination: SettingsDestination(
                        id: 'second',
                        builder: (_) => const Text('Second body'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            platform: _targetOf(platform),
          ),
        );
        await tester.pumpAndSettle();
        await _tabTo(tester, _tile('First'));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.text('First control'), findsOneWidget);

        final control = find.ancestor(
          of: find.text('First control'),
          matching: find.byType(SettingsTile),
        );
        for (var i = 0; i < 4; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          // Never on the list under the page.
          expect(_focusIn(_listPane), isFalse, reason: 'Tab $i');
        }
        await _tabTo(tester, control, max: 3);
      });
    }

    for (final (platform, twoPanes, onePane) in [
      (DevicePlatform.macOS, MacosSidebarItem, MacosSettingsTile),
      (DevicePlatform.windows, FluentNavigationItem, FluentSettingsTile),
      (DevicePlatform.linux, AdwaitaSidebarRow, AdwaitaSidebarRow),
    ]) {
      testWidgets('$platform: the focused tile keeps the focus', (
        tester,
      ) async {
        await _setSize(tester, const Size(1280, 800));
        await tester.pumpWidget(
          _app(
            SettingsSplitView(platform: platform, sections: _sections()),
            platform: _targetOf(platform),
          ),
        );
        await tester.pumpAndSettle();
        await _tabTo(tester, _tile('Sound'));
        expect(_inList(find.byType(twoPanes)), findsWidgets);

        await _setSize(tester, const Size(400, 800));
        await tester.pumpAndSettle();
        expect(_controllerOf(tester).isSplit, isFalse);
        expect(_inList(find.byType(onePane)), findsWidgets);
        expect(
          _focusIn(_tile('Sound')),
          isTrue,
          reason: 'focus: ${FocusManager.instance.primaryFocus}',
        );

        await _setSize(tester, const Size(1280, 800));
        await tester.pumpAndSettle();
        expect(
          _focusIn(_tile('Sound')),
          isTrue,
          reason: 'focus: ${FocusManager.instance.primaryFocus}',
        );
        // And Tab goes on from there.
        await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pumpAndSettle();
        expect(_focusIn(_tile('Display')), isTrue);
      });
    }

    testWidgets('a control in a page keeps the focus, or gives it to the '
        'page\'s tile when one pane shows the list', (tester) async {
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: DevicePlatform.linux,
            sections: [
              SettingsSection(
                tiles: [
                  for (final name in ['First', 'Second'])
                    SettingsTile.navigation(
                      title: Text(name),
                      destination: SettingsDestination(
                        id: name,
                        builder: (_) => SettingsList(
                          sections: [
                            SettingsSection(
                              tiles: [
                                SettingsTile(
                                  title: Text('$name control'),
                                  onPressed: (_) {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          platform: TargetPlatform.linux,
        ),
      );
      await tester.pumpAndSettle();
      final control = find.ancestor(
        of: find.text('First control'),
        matching: find.byType(SettingsTile),
      );
      await _tabTo(tester, control);

      // The first page shows by default: one pane shows the list instead.
      await _setSize(tester, const Size(400, 800));
      await tester.pumpAndSettle();
      expect(find.text('First control'), findsNothing);
      expect(_focusIn(_tile('First')), isTrue);

      // A picked page stays, with its focused control.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await _tabTo(tester, control);
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpAndSettle();
      expect(_focusIn(control), isTrue);
      await _setSize(tester, const Size(400, 800));
      await tester.pumpAndSettle();
      expect(_focusIn(control), isTrue);
    });
  });
}
