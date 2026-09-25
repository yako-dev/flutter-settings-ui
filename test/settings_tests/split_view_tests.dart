import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/tiles/platforms/adwaita_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/android_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/fluent_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/ios_settings_tile.dart';
import 'package:settings_ui/src/tiles/platforms/macos_settings_tile.dart';
import 'package:settings_ui/src/utils/theme_provider.dart';

/// Tests for SettingsSplitView, SettingsDestination and the selected-tile
/// theme tokens.

// Sizes (logical pixels) of the devices the breakpoints are checked on.
const _iPhone = Size(402, 874);
const _iPhoneLandscape = Size(874, 402);
const _iPadMiniPortrait = Size(744, 1133);
const _iPadMiniLandscape = Size(1133, 744);
const _iPadPro11Portrait = Size(834, 1210);
const _iPadPro11Landscape = Size(1210, 834);
const _iPadAir11Landscape = Size(1194, 834);
const _iPadPro13Landscape = Size(1366, 1024);
const _pixelPhone = Size(412, 915);
const _pixelPhoneLandscape = Size(915, 412);
const _pixelTabletLandscape = Size(1280, 800);
const _pixelTabletPortrait = Size(800, 1280);
// Pixel Fold inner display: 2208x1840 px at 420 dpi.
const _pixelFoldInner = Size(841, 701);
const _pixelFoldInnerPortrait = Size(701, 841);
// Pixel 9 Pro Fold inner display: 2076x2152 px at 390 dpi.
const _pixel9ProFoldInner = Size(852, 883);
const _pixel9ProFoldOuter = Size(443, 994);

Future<void> _setSize(
  WidgetTester tester,
  Size size, {
  List<DisplayFeature> displayFeatures = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.displayFeatures = displayFeatures;
  addTearDown(tester.view.reset);
}

class _Log {
  final List<String> events = [];
}

/// A settings tree like a real app's: two top-level pages (one with a nested
/// page and a counter to check that state survives layout changes), a switch
/// without a page, and a page with a custom header title.
List<AbstractSettingsSection> _sections({_Log? log}) => [
  SettingsSection(
    title: const Text('Connectivity'),
    tiles: [
      SettingsTile.navigation(
        leading: const Icon(Icons.wifi),
        title: const Text('Network'),
        onPressed: (_) => log?.events.add('network pressed'),
        destination: SettingsDestination(
          id: 'network',
          builder: (context) => SettingsList(
            sections: [
              SettingsSection(
                tiles: [SettingsTile(title: const Text('Wi-Fi body'))],
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

/// A page with state, to check that it survives layout changes.
class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => count++),
        child: Text('Count $count'),
      ),
    );
  }
}

Widget _app(
  Widget home, {
  TargetPlatform? platform,
  TextDirection textDirection = TextDirection.ltr,
  Brightness brightness = Brightness.light,
  String? restorationScopeId,
}) {
  return MaterialApp(
    restorationScopeId: restorationScopeId,
    theme: ThemeData(platform: platform, brightness: brightness),
    builder: (context, child) =>
        Directionality(textDirection: textDirection, child: child!),
    home: home,
  );
}

SettingsSplitView _view({
  DevicePlatform platform = DevicePlatform.iOS,
  SettingsSplitController? controller,
  ValueChanged<String?>? onDestinationChanged,
  SettingsSplitLayout layout = SettingsSplitLayout.auto,
  double? breakpoint,
  double? listPaneWidth,
  String? initialDestinationId,
  WidgetBuilder? emptyDetailBuilder,
  String? restorationId,
  _Log? log,
}) {
  return SettingsSplitView(
    platform: platform,
    title: const Text('Settings'),
    controller: controller,
    onDestinationChanged: onDestinationChanged,
    layout: layout,
    breakpoint: breakpoint,
    listPaneWidth: listPaneWidth,
    initialDestinationId: initialDestinationId,
    emptyDetailBuilder: emptyDetailBuilder,
    restorationId: restorationId,
    sections: _sections(log: log),
  );
}

/// Whether the view currently shows two panes.
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

Finder _listTile(String title) => find.text(title).first;

void splitViewTests() {
  group('breakpoints', () {
    final cases = <(DevicePlatform, Size, bool, String)>[
      (DevicePlatform.iOS, _iPhone, false, 'iPhone'),
      (DevicePlatform.iOS, _iPhoneLandscape, false, 'iPhone landscape'),
      (DevicePlatform.iOS, _iPadMiniPortrait, true, 'iPad mini portrait'),
      (DevicePlatform.iOS, _iPadMiniLandscape, true, 'iPad mini landscape'),
      (DevicePlatform.iOS, _iPadPro11Portrait, true, 'iPad Pro 11 portrait'),
      (DevicePlatform.iOS, _iPadPro11Landscape, true, 'iPad Pro 11 landscape'),
      (DevicePlatform.iOS, _iPadAir11Landscape, true, 'iPad Air 11 landscape'),
      (DevicePlatform.iOS, _iPadPro13Landscape, true, 'iPad Pro 13 landscape'),
      (DevicePlatform.iOS, const Size(444, 711), false, 'iPad 444pt window'),
      (DevicePlatform.iOS, const Size(600, 800), true, 'iOS at 600'),
      (DevicePlatform.iOS, const Size(599, 800), false, 'iOS at 599'),
      (DevicePlatform.android, _pixelPhone, false, 'Pixel'),
      (DevicePlatform.android, _pixelPhoneLandscape, false, 'Pixel landscape'),
      (
        DevicePlatform.android,
        _pixelTabletLandscape,
        true,
        'Pixel Tablet landscape',
      ),
      (
        DevicePlatform.android,
        _pixelTabletPortrait,
        true,
        'Pixel Tablet portrait',
      ),
      (DevicePlatform.android, _pixelFoldInner, true, 'Pixel Fold inner'),
      (
        DevicePlatform.android,
        _pixelFoldInnerPortrait,
        false,
        'Pixel Fold inner portrait',
      ),
      (
        DevicePlatform.android,
        _pixel9ProFoldInner,
        true,
        'Pixel 9 Pro Fold inner',
      ),
      (
        DevicePlatform.android,
        _pixel9ProFoldOuter,
        false,
        'Pixel 9 Pro Fold outer',
      ),
      (DevicePlatform.android, const Size(720, 600), true, 'Android at 720'),
      (DevicePlatform.android, const Size(719, 600), false, 'Android at 719'),
      (DevicePlatform.linux, const Size(1280, 800), true, 'Linux'),
      (DevicePlatform.web, const Size(980, 900), false, 'web at 980'),
      (DevicePlatform.web, const Size(981, 900), true, 'web at 981'),
      (DevicePlatform.web, const Size(1280, 800), true, 'web at 1280'),
      (DevicePlatform.web, const Size(800, 900), false, 'web at 800'),
    ];
    for (final (platform, size, split, name) in cases) {
      testWidgets('$name (${size.width}x${size.height}): '
          '${split ? 'two panes' : 'one pane'}', (tester) async {
        await _setSize(tester, size);
        await tester.pumpWidget(_app(_view(platform: platform)));
        await tester.pumpAndSettle();
        expect(_isSplit(tester), split);
      });
    }

    testWidgets('desktop windows only need the width', (tester) async {
      // Wide but short: the shortest side would say "phone".
      await _setSize(tester, const Size(1000, 500));
      await tester.pumpWidget(_app(_view(), platform: TargetPlatform.macOS));
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isTrue);

      await tester.pumpWidget(
        _app(
          _view(platform: DevicePlatform.linux),
          platform: TargetPlatform.linux,
        ),
      );
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isTrue);
    });

    testWidgets('breakpoint replaces the style rule', (tester) async {
      await _setSize(tester, _iPhoneLandscape);
      await tester.pumpWidget(_app(_view(breakpoint: 700)));
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isTrue);

      await tester.pumpWidget(_app(_view(breakpoint: 900)));
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isFalse);
    });

    testWidgets('layout forces one or two panes', (tester) async {
      await _setSize(tester, _iPadPro13Landscape);
      await tester.pumpWidget(_app(_view(layout: SettingsSplitLayout.single)));
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isFalse);

      await _setSize(tester, _iPhone);
      await tester.pumpWidget(_app(_view(layout: SettingsSplitLayout.split)));
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isTrue);
    });
  });

  group('list pane', () {
    testWidgets('pane widths follow the style', (tester) async {
      for (final (platform, size, width) in [
        (DevicePlatform.iOS, _iPadPro11Landscape, 320.0),
        (DevicePlatform.iOS, _iPadPro11Portrait, 320.0),
        (DevicePlatform.iOS, _iPadMiniPortrait, 320.0),
        (DevicePlatform.android, _pixelTabletLandscape, 1280 * 0.3636),
        (DevicePlatform.android, _pixelTabletPortrait, 800 * 0.3636),
        (DevicePlatform.web, const Size(1280, 800), 266.0),
      ]) {
        await _setSize(tester, size);
        await tester.pumpWidget(_app(_view(platform: platform)));
        await tester.pumpAndSettle();
        expect(
          _listPaneRect(tester).width,
          moreOrLessEquals(width, epsilon: 0.01),
          reason: '$platform at $size',
        );
      }
    });

    testWidgets('listPaneWidth overrides it, up to half the width', (
      tester,
    ) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view(listPaneWidth: 400)));
      await tester.pumpAndSettle();
      expect(_listPaneRect(tester).width, 400);

      await tester.pumpWidget(_app(_view(listPaneWidth: 1000)));
      await tester.pumpAndSettle();
      expect(_listPaneRect(tester).width, 1210 / 2);
    });

    testWidgets('Android hides the leading icons below 380dp', (tester) async {
      await _setSize(tester, _pixelTabletLandscape); // 465dp list pane
      await tester.pumpWidget(_app(_view(platform: DevicePlatform.android)));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.wifi), findsOneWidget);

      await _setSize(tester, _pixelTabletPortrait); // 291dp list pane
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.wifi), findsNothing);
      expect(find.text('Network'), findsWidgets);
    });

    testWidgets('iOS: sidebar rows without cards, separators or chevrons', (
      tester,
    ) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();

      final network = tester.getRect(
        find
            .ancestor(
              of: _listTile('Network'),
              matching: find.byType(ClipRRect),
            )
            .first,
      );
      // A 288x52 capsule, inset 16pt.
      expect(network.left, 16);
      expect(network.width, 288);
      // 16 + 17 + 16: 52pt with SF Pro's line height, 49 with the test font.
      expect(network.height, greaterThanOrEqualTo(49));
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('settings_split_list_pane')),
          matching: find.byIcon(CupertinoIcons.chevron_forward),
        ),
        findsNothing,
      );
    });
  });

  group('selection', () {
    testWidgets('two panes open on the first destination, highlighted', (
      tester,
    ) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();

      expect(find.text('Wi-Fi body'), findsOneWidget);
      expect(_selectedTitles(tester), ['Network']);
      expect(_tileColor(tester, 'Network'), const Color(0xFF0080F5));
      expect(_tileColor(tester, 'Sound'), isNull);
    });

    testWidgets('a tap shows the page, moves the highlight, and calls '
        'onPressed first', (tester) async {
      final log = _Log();
      final changes = <String?>[];
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(
        _app(_view(log: log, onDestinationChanged: changes.add)),
      );
      await tester.pumpAndSettle();

      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();
      expect(find.text('Display & brightness'), findsOneWidget);
      expect(find.text('Text size'), findsOneWidget);
      expect(find.text('Wi-Fi body'), findsNothing);
      expect(_selectedTitles(tester), ['Display']);
      expect(changes, ['display']);

      await tester.tap(_listTile('Network'));
      await tester.pumpAndSettle();
      expect(log.events, ['network pressed']);
      expect(changes, ['display', 'network']);
      expect(_selectedTitles(tester), ['Network']);
    });

    testWidgets('no highlight in one pane', (tester) async {
      await _setSize(tester, _iPhone);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();
      expect(_selectedTitles(tester), isEmpty);
      expect(find.text('Wi-Fi body'), findsNothing);
    });

    testWidgets('the detail root has no back button in two panes', (
      tester,
    ) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Back'), findsNothing);
    });

    testWidgets('initialDestinationId and emptyDetailBuilder', (tester) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view(initialDestinationId: 'sound')));
      await tester.pumpAndSettle();
      expect(find.text('Sound body'), findsOneWidget);
      expect(_selectedTitles(tester), ['Sound']);

      await tester.pumpWidget(
        _app(_view(emptyDetailBuilder: (_) => const Text('Pick a setting'))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pick a setting'), findsOneWidget);
      expect(_selectedTitles(tester), isEmpty);
    });

    testWidgets('pages opened inside a page push inside the detail pane', (
      tester,
    ) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();

      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();

      expect(find.text('Count 0'), findsOneWidget);
      // The list pane is still there, with Display still highlighted.
      expect(_selectedTitles(tester), ['Display']);
      final detail = tester.getRect(find.text('Count 0'));
      expect(detail.left, greaterThan(320));
      // The pushed page has a back button; it goes back to Display.
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Count 0'), findsNothing);
      expect(find.text('Text size'), findsOneWidget);
    });

    testWidgets('tapping the selected tile goes back to its first screen', (
      tester,
    ) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();
      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();
      expect(find.text('Count 0'), findsOneWidget);

      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();
      expect(find.text('Count 0'), findsNothing);
      expect(find.text('Text size'), findsOneWidget);
    });

    testWidgets('one pane pushes the page over the list with a back button', (
      tester,
    ) async {
      await _setSize(tester, _iPhone);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();

      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();
      expect(find.text('Display & brightness'), findsOneWidget);
      expect(find.text('Airplane mode'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Display & brightness'), findsNothing);
      expect(find.text('Airplane mode'), findsOneWidget);
    });
  });

  group('layout changes', () {
    testWidgets('collapsing drops the page two panes picked by default', (
      tester,
    ) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();
      expect(find.text('Wi-Fi body'), findsOneWidget);

      await _setSize(tester, _iPhone);
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isFalse);
      expect(find.text('Wi-Fi body'), findsNothing);
      expect(find.text('Airplane mode'), findsOneWidget);
    });

    testWidgets('collapsing keeps a page the user picked, with its state', (
      tester,
    ) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();
      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Count 0'));
      await tester.pump();
      expect(find.text('Count 1'), findsOneWidget);

      // Fold: one pane, the picked page on top, its pushed page and its
      // state kept.
      await _setSize(tester, _iPhone);
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isFalse);
      expect(find.text('Count 1'), findsOneWidget);
      expect(find.text('Airplane mode'), findsNothing);

      // Back: Display, then the list.
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Text size'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Airplane mode'), findsOneWidget);

      // Unfold: back to the default page.
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpAndSettle();
      expect(_selectedTitles(tester), ['Network']);
    });

    testWidgets('a page pushed inside the default page makes it stick', (
      tester,
    ) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view(initialDestinationId: 'display')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();

      await _setSize(tester, _iPhone);
      await tester.pumpAndSettle();
      expect(find.text('Count 0'), findsOneWidget);
    });

    testWidgets('expanding from a page shows both panes, highlighted', (
      tester,
    ) async {
      await _setSize(tester, _iPhone);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();
      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Count 0'));
      await tester.pump();

      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isTrue);
      expect(_selectedTitles(tester), ['Display']);
      expect(find.text('Count 1'), findsOneWidget);
      expect(find.text('Airplane mode'), findsOneWidget);
    });

    testWidgets('expanding from the list shows the default page', (
      tester,
    ) async {
      await _setSize(tester, _iPhone);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();

      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpAndSettle();
      expect(find.text('Wi-Fi body'), findsOneWidget);
      expect(_selectedTitles(tester), ['Network']);
    });

    testWidgets('the list keeps its scroll offset', (tester) async {
      await _setSize(tester, const Size(1210, 300));
      await tester.pumpWidget(_app(_view(), platform: TargetPlatform.macOS));
      await tester.pumpAndSettle();
      final scrollable = find
          .descendant(
            of: find.byKey(const ValueKey('settings_split_list_pane')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.drag(scrollable, const Offset(0, -100));
      await tester.pumpAndSettle();
      final offset = tester.state<ScrollableState>(scrollable).position.pixels;
      expect(offset, greaterThan(0));

      await _setSize(tester, const Size(500, 300));
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isFalse);
      await _setSize(tester, const Size(1210, 300));
      await tester.pumpAndSettle();
      final after = tester
          .state<ScrollableState>(
            find
                .descendant(
                  of: find.byKey(const ValueKey('settings_split_list_pane')),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position
          .pixels;
      expect(after, offset);
    });
  });

  group('back', () {
    Future<void> systemBack(WidgetTester tester) async {
      final handled = await tester.binding.handlePopRoute();
      expect(handled, isTrue);
      await tester.pumpAndSettle();
    }

    Widget pushedFromHome(Widget view) => _app(
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
    );

    testWidgets('one pane: nested page, then the page, then the screen', (
      tester,
    ) async {
      await _setSize(tester, _pixelPhone);
      await tester.pumpWidget(
        pushedFromHome(_view(platform: DevicePlatform.android)),
      );
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();
      expect(find.text('Count 0'), findsOneWidget);

      await systemBack(tester);
      expect(find.text('Text size'), findsOneWidget);
      await systemBack(tester);
      expect(find.text('Airplane mode'), findsOneWidget);
      await systemBack(tester);
      expect(find.text('Open settings'), findsOneWidget);
    });

    testWidgets('two panes: nested page, then the screen', (tester) async {
      await _setSize(tester, _pixelTabletLandscape);
      await tester.pumpWidget(
        pushedFromHome(_view(platform: DevicePlatform.android)),
      );
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();

      await systemBack(tester);
      expect(find.text('Text size'), findsOneWidget);
      expect(find.text('Count 0'), findsNothing);
      await systemBack(tester);
      expect(find.text('Open settings'), findsOneWidget);
    });

    testWidgets('the framework handles back while a page can pop', (
      tester,
    ) async {
      // Android 14+ predictive back: the engine must know that the app
      // handles back, or the system closes the app.
      final calls = <bool>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'SystemNavigator.setFrameworkHandlesBack') {
            calls.add(call.arguments as bool);
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
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await _setSize(tester, _pixelPhone);
      await tester.pumpWidget(_app(_view(platform: DevicePlatform.android)));
      await tester.pumpAndSettle();
      calls.clear();

      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();
      expect(calls.last, isTrue);

      await systemBack(tester);
      expect(calls.last, isFalse);
    });

    testWidgets('the list pane back button leaves from two panes', (
      tester,
    ) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(pushedFromHome(_view()));
      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();
      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Text size'));
      await tester.pumpAndSettle();

      // Two back buttons: the list pane's (leave) and the pushed page's.
      final backs = find.bySemanticsLabel('Back');

      expect(backs, findsNWidgets(2));
      final listBack = tester.getRect(backs.first).left < 320
          ? backs.first
          : backs.last;
      await tester.tap(listBack);
      await tester.pumpAndSettle();
      expect(find.text('Open settings'), findsOneWidget);
    });
  });

  group('back edge cases', () {
    SettingsSplitView guarded(ValueNotifier<int> attempts) => SettingsSplitView(
      platform: DevicePlatform.android,
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
                    if (!didPop) attempts.value++;
                  },
                  child: const Text('Unsaved changes'),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    testWidgets('a page can veto back with a PopScope', (tester) async {
      final attempts = ValueNotifier<int>(0);
      addTearDown(attempts.dispose);
      await _setSize(tester, _pixelPhone);
      await tester.pumpWidget(_app(guarded(attempts)));
      await tester.tap(find.text('Form'));
      await tester.pumpAndSettle();

      // System back.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Unsaved changes'), findsOneWidget);
      expect(attempts.value, 1);

      // The header's back button.
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Unsaved changes'), findsOneWidget);
      expect(attempts.value, 2);
    });

    testWidgets('opening a page while the last one animates out', (
      tester,
    ) async {
      // Taps are absorbed during route transitions, but a controller (a deep
      // link, a notification) can open a page at any time. The new page must
      // take the detail navigator from the one animating out.
      final controller = SettingsSplitController();
      addTearDown(controller.dispose);
      await _setSize(tester, _iPhone);
      await tester.pumpWidget(_app(_view(controller: controller)));
      await tester.pumpAndSettle();
      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pump(const Duration(milliseconds: 100));
      controller.select('sound');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Sound body'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Airplane mode'), findsOneWidget);
    });

    testWidgets('layout changes while a page animates in or out', (
      tester,
    ) async {
      await _setSize(tester, _iPhone);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();
      await tester.tap(_listTile('Display'));
      await tester.pump(const Duration(milliseconds: 100));
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_selectedTitles(tester), ['Display']);

      await _setSize(tester, _iPhone);
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pump(const Duration(milliseconds: 100));
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_selectedTitles(tester), ['Network']);
    });
  });

  group('controller', () {
    testWidgets('select, clearSelection, selectedId, isSplit and listeners', (
      tester,
    ) async {
      final controller = SettingsSplitController();
      addTearDown(controller.dispose);
      var notified = 0;
      controller.addListener(() => notified++);

      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view(controller: controller)));
      await tester.pumpAndSettle();
      expect(controller.isSplit, isTrue);
      expect(controller.selectedId, 'network');

      notified = 0;
      controller.select('sound');
      await tester.pumpAndSettle();
      expect(find.text('Sound body'), findsOneWidget);
      expect(controller.selectedId, 'sound');
      expect(_selectedTitles(tester), ['Sound']);
      expect(notified, 1);

      controller.clearSelection();
      await tester.pumpAndSettle();
      expect(controller.selectedId, 'network');

      await _setSize(tester, _iPhone);
      await tester.pumpAndSettle();
      expect(controller.isSplit, isFalse);
      expect(controller.selectedId, isNull);

      controller.select('sound');
      await tester.pumpAndSettle();
      expect(find.text('Sound body'), findsOneWidget);
      controller.clearSelection();
      await tester.pumpAndSettle();
      expect(find.text('Sound body'), findsNothing);
      expect(find.text('Airplane mode'), findsOneWidget);
    });

    testWidgets('select before the view is built opens that page, '
        'also in one pane (deep links)', (tester) async {
      final controller = SettingsSplitController()..select('display');
      addTearDown(controller.dispose);
      await _setSize(tester, _iPhone);
      await tester.pumpWidget(_app(_view(controller: controller)));
      await tester.pumpAndSettle();
      expect(find.text('Display & brightness'), findsOneWidget);
    });

    testWidgets('SettingsSplitView.of works inside pages', (tester) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view()));
      await tester.pumpAndSettle();
      SettingsSplitView.of(
        tester.element(find.text('Wi-Fi body')),
      ).select('display');
      await tester.pumpAndSettle();
      expect(find.text('Text size'), findsOneWidget);
      expect(
        SettingsSplitView.maybeOf(tester.element(find.text('Text size'))),
        isNotNull,
      );
    });

    testWidgets('onDestinationChanged follows layout changes', (tester) async {
      final changes = <String?>[];
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view(onDestinationChanged: changes.add)));
      await tester.pumpAndSettle();
      expect(changes, isEmpty);

      await _setSize(tester, _iPhone);
      await tester.pumpAndSettle();
      expect(changes, [null]);
      await tester.tap(_listTile('Sound'));
      await tester.pumpAndSettle();
      expect(changes, [null, 'sound']);
    });
  });

  group('direction and hinges', () {
    testWidgets('RTL puts the list pane on the right', (tester) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(_app(_view(), textDirection: TextDirection.rtl));
      await tester.pumpAndSettle();
      final list = _listPaneRect(tester);
      expect(list.right, 1210);
      expect(list.left, 1210 - 320);
      expect(tester.getRect(find.text('Wi-Fi body')).right, lessThan(890));
    });

    testWidgets('a hinge splits the panes on each side of it', (tester) async {
      // A Surface Duo-like hinge, 28 wide, in a window too narrow for the
      // style's rule.
      await _setSize(
        tester,
        const Size(1114, 720),
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTRB(540, 0, 568, 720),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.unknown,
          ),
        ],
      );
      await tester.pumpWidget(_app(_view(platform: DevicePlatform.android)));
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isTrue);
      expect(_listPaneRect(tester).width, 540);
      expect(tester.getRect(find.text('Wi-Fi body')).left, greaterThan(568));

      // RTL: the list goes right of the hinge.
      await tester.pumpWidget(
        _app(
          _view(platform: DevicePlatform.android),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      expect(_listPaneRect(tester).left, 568);
    });

    testWidgets('a half-opened fold splits even a narrow window', (
      tester,
    ) async {
      await _setSize(
        tester,
        _pixelFoldInnerPortrait,
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTRB(350.5, 0, 350.5, 841),
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
      );
      await tester.pumpWidget(_app(_view(platform: DevicePlatform.android)));
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isTrue);
      expect(_listPaneRect(tester).width, 350.5);
    });

    testWidgets('a flat fold and a horizontal fold are ignored', (
      tester,
    ) async {
      await _setSize(
        tester,
        _pixelFoldInner,
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTRB(420.5, 0, 420.5, 701),
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureFlat,
          ),
        ],
      );
      await tester.pumpWidget(_app(_view(platform: DevicePlatform.android)));
      await tester.pumpAndSettle();
      expect(_listPaneRect(tester).width, 841 * 0.3636);

      await _setSize(
        tester,
        _pixelFoldInnerPortrait,
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTRB(0, 420.5, 701, 420.5),
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
      );
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isFalse);
    });

    testWidgets('layout: single ignores the hinge', (tester) async {
      await _setSize(
        tester,
        const Size(1114, 720),
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTRB(540, 0, 568, 720),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.unknown,
          ),
        ],
      );
      await tester.pumpWidget(
        _app(
          _view(
            platform: DevicePlatform.android,
            layout: SettingsSplitLayout.single,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_isSplit(tester), isFalse);
    });
  });

  group('restoration', () {
    testWidgets('restores the picked page in two panes', (tester) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(
        _app(_view(restorationId: 'settings'), restorationScopeId: 'app'),
      );
      await tester.pumpAndSettle();
      await tester.tap(_listTile('Sound'));
      await tester.pumpAndSettle();

      await tester.restartAndRestore();
      expect(find.text('Sound body'), findsOneWidget);
      expect(_selectedTitles(tester), ['Sound']);
    });

    testWidgets('restores the page over the list in one pane', (tester) async {
      await _setSize(tester, _iPhone);
      await tester.pumpWidget(
        _app(_view(restorationId: 'settings'), restorationScopeId: 'app'),
      );
      await tester.pumpAndSettle();
      await tester.tap(_listTile('Display'));
      await tester.pumpAndSettle();

      await tester.restartAndRestore();
      expect(find.text('Display & brightness'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Airplane mode'), findsOneWidget);
    });
  });

  group('pane content', () {
    testWidgets('iPad and Android pages fill the detail pane', (tester) async {
      await _setSize(tester, _iPadPro13Landscape);
      await tester.pumpWidget(_app(_view(initialDestinationId: 'display')));
      await tester.pumpAndSettle();
      // No 810 column: 20pt margins in the 1046pt pane.
      final card = tester.getRect(
        find
            .ancestor(
              of: find.text('Text size'),
              matching: find.byType(ClipRSuperellipse),
            )
            .first,
      );
      expect(card.left, 320 + 20);
      expect(card.right, 1366 - 20);

      await tester.pumpWidget(
        _app(
          _view(
            platform: DevicePlatform.android,
            initialDestinationId: 'display',
          ),
        ),
      );
      await tester.pumpAndSettle();
      final androidCard = tester.getRect(
        find
            .ancestor(
              of: find.text('Text size'),
              matching: find.byType(ClipRRect),
            )
            .first,
      );
      final listWidth = 1366 * 0.3636;
      expect(androidCard.left, moreOrLessEquals(listWidth + 16));
      expect(androidCard.right, 1366 - 16);
    });

    testWidgets('web pages use Chrome\'s 680px column, nearer the menu', (
      tester,
    ) async {
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpWidget(
        _app(
          _view(platform: DevicePlatform.web, initialDestinationId: 'display'),
        ),
      );
      await tester.pumpAndSettle();
      final card = tester.getRect(find.byType(Card).last);
      expect(card.width, moreOrLessEquals(680));
      // Chrome at 1280px: menu 266, #main 708 + (1014 - 708) / 2 wide, the
      // column centered in it.
      const main = 680 / 0.96 + (1280 - 266 - 680 / 0.96) / 2;
      expect(card.left, moreOrLessEquals(266 + (main - 680) / 2));
      // The page title starts at the column's edge.
      expect(
        tester.getRect(find.text('Display & brightness')).left,
        moreOrLessEquals(card.left),
      );
    });

    testWidgets('web list pane is Chrome\'s menu', (tester) async {
      await _setSize(tester, const Size(1280, 800));
      await tester.pumpWidget(_app(_view(platform: DevicePlatform.web)));
      await tester.pumpAndSettle();

      final context = tester.element(_listTile('Network'));
      final theme = SettingsTheme.of(context).themeData;
      final colorScheme = Theme.of(context).colorScheme;
      final item = find
          .ancestor(of: _listTile('Network'), matching: find.byType(Material))
          .first;
      final material = tester.widget<Material>(item);
      expect(material.color, theme.selectedTileColor);
      expect(
        theme.selectedTileColor,
        Color.alphaBlend(
          colorScheme.primary.withValues(alpha: 0.1),
          colorScheme.surfaceContainerLowest,
        ),
      );
      final shape = material.shape! as RoundedRectangleBorder;
      // Rounded on the end side only.
      expect(
        shape.borderRadius,
        const BorderRadius.horizontal(right: Radius.circular(100)),
      );
      final rect = tester.getRect(item);
      expect(rect.left, 1);
      expect(rect.right, 264);
      expect(rect.height, 40);
      // No cards and no descriptions in the menu.
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('settings_split_list_pane')),
          matching: find.byType(Card),
        ),
        findsNothing,
      );
      final style = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: _listTile('Network'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(style.fontSize, 14);
      expect(style.fontWeight, FontWeight.w500);
      expect(style.color, colorScheme.primary);

      // RTL: rounded on the (left) end side.
      await tester.pumpWidget(
        _app(
          _view(platform: DevicePlatform.web),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      final rtlShape =
          tester
                  .widget<Material>(
                    find
                        .ancestor(
                          of: _listTile('Network'),
                          matching: find.byType(Material),
                        )
                        .first,
                  )
                  .shape!
              as RoundedRectangleBorder;
      expect(
        rtlShape.borderRadius,
        const BorderRadius.horizontal(left: Radius.circular(100)),
      );
    });

    testWidgets('Android: the selected card takes the detail pane color', (
      tester,
    ) async {
      await _setSize(tester, _pixelTabletLandscape);
      await tester.pumpWidget(_app(_view(platform: DevicePlatform.android)));
      await tester.pumpAndSettle();
      final context = tester.element(_listTile('Network'));
      final colorScheme = Theme.of(context).colorScheme;
      final selected = tester.widget<Material>(
        find
            .ancestor(of: _listTile('Network'), matching: find.byType(Material))
            .first,
      );
      expect(selected.color, colorScheme.surfaceContainer);
      final unselected = tester.widget<Material>(
        find
            .ancestor(of: _listTile('Sound'), matching: find.byType(Material))
            .first,
      );
      expect(unselected.color, Colors.transparent);
      // The list pane is surface dim.
      final pane = tester.widget<Material>(
        find
            .descendant(
              of: find.byKey(const ValueKey('settings_split_list_pane')),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(pane.color, colorScheme.surfaceDim);
    });

    testWidgets('iOS: sidebar and selection colors, light and dark', (
      tester,
    ) async {
      await _setSize(tester, _iPadPro11Landscape);
      for (final (brightness, sidebar, fill) in [
        (Brightness.light, const Color(0xFFE2E6F0), const Color(0xFF0080F5)),
        (Brightness.dark, const Color(0xFF181D20), const Color(0xFF13A4FF)),
      ]) {
        await tester.pumpWidget(_app(_view(), brightness: brightness));
        await tester.pumpAndSettle();
        expect(_tileColor(tester, 'Network'), fill);
        final theme = SettingsTheme.of(
          tester.element(_listTile('Network')),
        ).themeData;
        expect(theme.settingsListBackground, sidebar);
        final title = tester
            .widget<DefaultTextStyle>(
              find
                  .ancestor(
                    of: _listTile('Network'),
                    matching: find.byType(DefaultTextStyle),
                  )
                  .first,
            )
            .style;
        expect(title.color, CupertinoColors.white);
      }
    });

    testWidgets('selected tile colors come from the theme', (tester) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: DevicePlatform.iOS,
            lightTheme: const SettingsThemeData(
              selectedTileColor: Color(0xFF123456),
              selectedTileTextColor: Color(0xFF654321),
              listPaneBackground: Color(0xFFABCDEF),
            ),
            sections: _sections(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_tileColor(tester, 'Network'), const Color(0xFF123456));
      final title = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: _listTile('Network'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(title.color, const Color(0xFF654321));
      expect(
        SettingsTheme.of(
          tester.element(_listTile('Network')),
        ).themeData.settingsListBackground,
        const Color(0xFFABCDEF),
      );
    });

    testWidgets('tiles in custom sections can open pages too', (tester) async {
      await _setSize(tester, _iPadPro11Landscape);
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: DevicePlatform.iOS,
            emptyDetailBuilder: (_) => const Text('Empty'),
            sections: [
              CustomSettingsSection(
                child: SettingsSection(
                  tiles: [
                    SettingsTile.navigation(
                      title: const Text('Custom'),
                      destination: SettingsDestination(
                        id: 'custom',
                        builder: (_) => const Text('Custom body'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Empty'), findsOneWidget);
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      expect(find.text('Custom body'), findsOneWidget);
      expect(_selectedTitles(tester), ['Custom']);
    });

    testWidgets('Android pages have a large title that collapses', (
      tester,
    ) async {
      await _setSize(tester, _pixelPhone);
      await tester.pumpWidget(
        _app(
          SettingsSplitView(
            platform: DevicePlatform.android,
            sections: [
              SettingsSection(
                tiles: [
                  SettingsTile.navigation(
                    title: const Text('Display'),
                    destination: SettingsDestination(
                      id: 'display',
                      title: const Text('Display & touch'),
                      builder: (_) => SettingsList(
                        sections: [
                          SettingsSection(
                            tiles: [
                              for (var i = 0; i < 30; i++)
                                SettingsTile(title: Text('Row $i')),
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
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Display'));
      await tester.pumpAndSettle();

      // Two copies: the 36sp title and the 22sp one in the bar, hidden.
      final titles = find.text('Display & touch');
      expect(titles, findsNWidgets(2));
      double opacityOf(Finder finder) => tester
          .widget<Opacity>(
            find.ancestor(of: finder, matching: find.byType(Opacity)).first,
          )
          .opacity;
      final large = titles.first;
      final small = titles.last;
      expect(tester.getRect(large).left, 24);
      expect(opacityOf(large), 1);
      expect(opacityOf(small), 0);

      await tester.drag(find.text('Row 3'), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(opacityOf(small), 1);
      expect(opacityOf(large), 0);
    });
  });

  group('SettingsList destinations', () {
    for (final platform in [
      DevicePlatform.iOS,
      DevicePlatform.android,
      DevicePlatform.web,
    ]) {
      testWidgets('$platform: a tap pushes the page with a header and back', (
        tester,
      ) async {
        final log = _Log();
        await _setSize(tester, const Size(400, 800));
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: SettingsList(
                platform: platform,
                sections: _sections(log: log),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Network'));
        await tester.pumpAndSettle();

        expect(log.events, ['network pressed']);
        expect(find.text('Wi-Fi body'), findsOneWidget);
        // The header defaults to the tile's title.
        expect(find.text('Network'), findsWidgets);
        final route = ModalRoute.of(tester.element(find.text('Wi-Fi body')))!;
        expect(route.settings.name, 'network');
        expect(
          route,
          platform == DevicePlatform.iOS
              ? isA<CupertinoPageRoute<void>>()
              : isA<MaterialPageRoute<void>>(),
        );
        // The page's list inherits the forced style.
        expect(
          SettingsTheme.of(tester.element(find.text('Wi-Fi body'))).platform,
          platform,
        );

        await tester.tap(find.bySemanticsLabel('Back'));
        await tester.pumpAndSettle();
        expect(find.text('Wi-Fi body'), findsNothing);
      });
    }

    testWidgets('pages inherit themes and brightness', (tester) async {
      const marker = Color(0xFF00FF00);
      await _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: SettingsList(
              platform: DevicePlatform.android,
              brightness: Brightness.dark,
              darkTheme: const SettingsThemeData(
                settingsSectionBackground: marker,
              ),
              sections: _sections(),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Network'));
      await tester.pumpAndSettle();
      expect(
        SettingsTheme.of(
          tester.element(find.text('Wi-Fi body')),
        ).themeData.settingsSectionBackground,
        marker,
      );
    });

    testWidgets('a nested SettingsList still detects its own style', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: SettingsList(
              platform: DevicePlatform.iOS,
              sections: [
                CustomSettingsSection(
                  child: SizedBox(
                    height: 200,
                    child: SettingsList(
                      sections: [
                        SettingsSection(
                          tiles: [SettingsTile(title: const Text('Inner'))],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          platform: TargetPlatform.android,
        ),
      );
      expect(
        SettingsTheme.of(tester.element(find.text('Inner'))).platform,
        DevicePlatform.android,
      );
    });
  });

  group('theme tokens', () {
    test('merge and copyWith carry the split view tokens', () {
      const a = SettingsThemeData(
        selectedTileColor: Color(0xFF000001),
        selectedTileTextColor: Color(0xFF000002),
        selectedTileIconColor: Color(0xFF000003),
        listPaneBackground: Color(0xFF000004),
      );
      final merged = const SettingsThemeData().merge(theme: a);
      expect(merged.selectedTileColor, const Color(0xFF000001));
      expect(merged.selectedTileTextColor, const Color(0xFF000002));
      expect(merged.selectedTileIconColor, const Color(0xFF000003));
      expect(merged.listPaneBackground, const Color(0xFF000004));
      final copy = a.copyWith(selectedTileColor: const Color(0xFF000009));
      expect(copy.selectedTileColor, const Color(0xFF000009));
      expect(copy.listPaneBackground, const Color(0xFF000004));
    });
  });

  group('macOS, Windows and GNOME styles', () {
    // The style, and the tiles its list pane falls back to with two panes.
    final cases = [
      (
        DevicePlatform.macOS,
        TargetPlatform.macOS,
        MacosSettingsTile,
        IOSSettingsTile,
      ),
      (
        DevicePlatform.windows,
        TargetPlatform.windows,
        FluentSettingsTile,
        IOSSettingsTile,
      ),
      (
        DevicePlatform.linux,
        TargetPlatform.linux,
        AdwaitaSettingsTile,
        AndroidSettingsTile,
      ),
    ];

    for (final (platform, target, tileType, listPaneTileType) in cases) {
      for (final brightness in Brightness.values) {
        testWidgets('$platform (${brightness.name}): the list pane draws '
            'sidebar rows in the style colors, the page its own tiles', (
          tester,
        ) async {
          await _setSize(tester, const Size(1280, 800));
          await tester.pumpWidget(
            _app(
              _view(platform: platform),
              platform: target,
              brightness: brightness,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(_isSplit(tester), isTrue);

          final context = tester.element(find.byType(SettingsSplitView));
          final theme = ThemeProvider.getTheme(
            context: context,
            platform: platform,
            brightness: brightness,
          );
          final listPane = find.byKey(
            const ValueKey('settings_split_list_pane'),
          );
          expect(
            find.descendant(of: listPane, matching: find.byType(tileType)),
            findsNothing,
          );
          expect(
            find.descendant(
              of: listPane,
              matching: find.byType(listPaneTileType),
            ),
            findsWidgets,
          );
          expect(
            tester
                .widget<Material>(
                  find
                      .descendant(of: listPane, matching: find.byType(Material))
                      .first,
                )
                .color,
            theme.listPaneBackground,
          );
          expect(_selectedTitles(tester), ['Network']);
          if (listPaneTileType == IOSSettingsTile) {
            expect(_tileColor(tester, 'Network'), theme.selectedTileColor);
            expect(_tileColor(tester, 'Display'), isNull);
          } else {
            Color? fill(String title) => tester
                .widget<Material>(
                  find
                      .ancestor(
                        of: _listTile(title),
                        matching: find.byType(Material),
                      )
                      .first,
                )
                .color;
            expect(fill('Network'), theme.selectedTileColor);
            expect(fill('Display'), Colors.transparent);
          }

          // The page in the detail pane keeps the style.
          expect(
            find.ancestor(
              of: find.text('Wi-Fi body'),
              matching: find.byType(tileType),
            ),
            findsOneWidget,
          );
        });
      }

      testWidgets('$platform: one pane shows the style everywhere', (
        tester,
      ) async {
        await _setSize(tester, const Size(500, 800));
        await tester.pumpWidget(
          _app(_view(platform: platform), platform: target),
        );
        await tester.pumpAndSettle();
        expect(_isSplit(tester), isFalse);
        expect(find.byType(listPaneTileType), findsNothing);
        expect(find.byType(tileType), findsWidgets);

        await tester.tap(_listTile('Network'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.ancestor(
            of: find.text('Wi-Fi body'),
            matching: find.byType(tileType),
          ),
          findsOneWidget,
        );
      });
    }

    ListView detailList(WidgetTester tester) => tester.widget<ListView>(
      find
          .descendant(
            of: find
                .ancestor(
                  of: find.text('Wi-Fi body'),
                  matching: find.byType(SettingsList),
                )
                .first,
            matching: find.byType(ListView),
          )
          .first,
    );

    double detailWidth(WidgetTester tester) => tester
        .getSize(
          find
              .ancestor(
                of: find.text('Wi-Fi body'),
                matching: find.byType(SettingsList),
              )
              .first,
        )
        .width;

    testWidgets('pages keep their column rules in the detail pane', (
      tester,
    ) async {
      await _setSize(tester, const Size(1280, 800));

      // macOS: the 640pt column, centered in the pane.
      await tester.pumpWidget(
        _app(
          _view(platform: DevicePlatform.macOS),
          platform: TargetPlatform.macOS,
        ),
      );
      await tester.pumpAndSettle();
      var padding = detailList(tester).padding! as EdgeInsets;
      final macWidth = detailWidth(tester);
      expect(padding.left, (macWidth - 640) / 2);
      expect(padding.right, (macWidth - 640) / 2);

      // Windows: 24 margins (the pane is wider than 641), not iPad's none.
      await tester.pumpWidget(
        _app(
          _view(platform: DevicePlatform.windows),
          platform: TargetPlatform.windows,
        ),
      );
      await tester.pumpAndSettle();
      padding = detailList(tester).padding! as EdgeInsets;
      expect(padding.left, 24);
      expect(padding.right, 24);

      // iOS pages fill the pane.
      await tester.pumpWidget(
        _app(_view(platform: DevicePlatform.iOS), platform: TargetPlatform.iOS),
      );
      await tester.pumpAndSettle();
      padding = detailList(tester).padding! as EdgeInsets;
      expect(padding.left, 0);
      expect(padding.right, 0);
    });

    testWidgets('macOS: a page in the detail pane keeps 30pt after a footer', (
      tester,
    ) async {
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
      expect(_isSplit(tester), isTrue);
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
      await tester.pumpWidget(_app(const SizedBox()));
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
  });

  group('iOS tiles in a narrow pane', () {
    testWidgets('descriptions take the pane width, not the screen width', (
      tester,
    ) async {
      await _setSize(tester, const Size(1200, 800));
      await tester.pumpWidget(
        _app(
          Row(
            children: [
              SizedBox(
                width: 320,
                child: SettingsList(
                  platform: DevicePlatform.iOS,
                  sections: [
                    SettingsSection(
                      tiles: [
                        SettingsTile(
                          title: const Text('Tile'),
                          description: const Text('Footer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final footer = tester.getRect(
        find
            .ancestor(of: find.text('Footer'), matching: find.byType(Container))
            .first,
      );
      expect(footer.width, 320 - 40);
    });
  });
}

Rect _listPaneRect(WidgetTester tester) =>
    tester.getRect(find.byKey(const ValueKey('settings_split_list_pane')));

/// Titles of the tiles drawn selected.
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

/// The fill of a list pane tile (null when transparent).
Color? _tileColor(WidgetTester tester, String title) {
  final container = tester.widget<Container>(
    find.ancestor(of: _listTile(title), matching: find.byType(Container)).at(0),
  );
  return container.color;
}
