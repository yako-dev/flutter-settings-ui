import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

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
}) {
  return MaterialApp(
    theme: ThemeData(platform: platform),
    routes: routes,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: textScaler ?? TextScaler.linear(textScale)),
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
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => view)),
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
              onPressed: (context) => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => page)),
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
}
