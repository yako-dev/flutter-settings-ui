// The split view demo and the showcase in every style, at the size of the
// device or window they run on: select pages, open a nested page, go back,
// toggle switches, and resize across the breakpoints with a nested page open.
// Any FlutterError (an overflow, an exception) fails the test.
//
//   cd example && flutter test integration_test/split_view_flows_test.dart -d <device>
import 'package:example/screens/gallery/showcase_screen.dart';
import 'package:example/screens/gallery/split_view_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Per style: a page, a tile in it that opens a nested page, a text on that
/// nested page, and another page.
const _flows = <DevicePlatform, (String, String, String, String)>{
  DevicePlatform.iOS: (
    'accessibility',
    'Display & Text Size',
    'Bold Text',
    'wifi',
  ),
  DevicePlatform.android: ('display', 'Lock screen', 'Show wallet', 'network'),
  DevicePlatform.web: ('privacy', 'Security', 'Safe Browsing', 'appearance'),
  DevicePlatform.macOS: ('general', 'About', 'Name', 'wifi'),
  DevicePlatform.windows: ('system', 'Display', 'Night light', 'bluetooth'),
  DevicePlatform.linux: ('sound', 'Volume Levels', 'Outputs', 'network'),
};

/// Window sizes that cross every style's two-pane breakpoint, both ways.
const _sizes = [
  Size(1280, 800),
  Size(900, 700),
  Size(700, 700),
  Size(540, 800),
  Size(420, 800),
  Size(1280, 800),
  Size(420, 800),
];

Widget _app(Widget home, {ThemeMode mode = ThemeMode.light}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData.light(useMaterial3: true),
  darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
  themeMode: mode,
  home: home,
);

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 300));
}

SettingsSplitController _controller(WidgetTester tester) =>
    SettingsSplitView.of(tester.element(find.byType(SettingsList).first));

/// Scrolls the shown page until [text] is on screen and returns its finder.
/// The page is the last list in the tree (after the list pane).
Future<Finder> _scrollTo(WidgetTester tester, String text) async {
  final finder = find.text(text);
  if (finder.evaluate().isEmpty) {
    // Not built yet: below the end of a lazy list (large text, short window).
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find
          .descendant(
            of: find.byType(SettingsList).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  // To the middle: a pinned page header (Android) covers the top.
  await Scrollable.ensureVisible(tester.element(finder.last), alignment: 0.5);
  await _settle(tester);
  return finder.last;
}

bool _isSettingsSwitch(Widget widget) =>
    widget is Switch ||
    widget is CupertinoSettingsSwitch ||
    widget is MacosSettingsSwitch ||
    widget is FluentSettingsSwitch ||
    widget is AdwaitaSettingsSwitch;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // A missed tap would make the back steps below pop the app's own route
  // (and quit a desktop app): fail at the tap instead.
  WidgetController.hitTestWarningShouldBeFatal = true;

  for (final MapEntry(key: platform, value: flow) in _flows.entries) {
    final (page, nestedTile, nestedText, otherPage) = flow;

    for (final (mode, scale) in [
      (ThemeMode.light, 1.0),
      (ThemeMode.dark, 2.0),
    ]) {
      testWidgets('split view, ${platform.name}, ${mode.name}, text x$scale: '
          'select, nested page, back', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          _app(SplitViewScreen(platform: platform), mode: mode),
        );
        await _settle(tester);

        final controller = _controller(tester);
        controller.select(page);
        await _settle(tester);
        expect(controller.selectedId, page);

        await tester.tap(await _scrollTo(tester, nestedTile));
        await _settle(tester);
        expect(find.textContaining(nestedText), findsWidgets);

        // Back closes the nested page; the page stays selected.
        await tester.binding.handlePopRoute();
        await _settle(tester);
        expect(controller.selectedId, page);

        // The same page again, then another one.
        controller.select(page);
        await _settle(tester);
        controller.select(otherPage);
        await _settle(tester);
        expect(controller.selectedId, otherPage);

        if (!controller.isSplit) {
          await tester.binding.handlePopRoute();
          await _settle(tester);
          expect(controller.selectedId, isNull);
        }
      });
    }

    testWidgets('showcase, ${platform.name}: pages and switches', (
      tester,
    ) async {
      await tester.pumpWidget(_app(ShowcaseScreen(platform: platform)));
      await _settle(tester);
      final controller = _controller(tester);
      for (final id in [
        'account',
        'appearance',
        'notifications',
        'privacy',
        'sync',
        'storage',
        'about',
      ]) {
        controller.select(id);
        await _settle(tester);
        expect(controller.selectedId, id);
      }

      // Toggle each switch on the Privacy page on screen, and back.
      controller.select('privacy');
      await _settle(tester);
      final switches = find.byWidgetPredicate(_isSettingsSwitch).hitTestable();
      final count = switches.evaluate().length;
      expect(count, greaterThan(0));
      for (var i = 0; i < count; i++) {
        await tester.tap(switches.at(i));
        await _settle(tester);
        await tester.tap(switches.at(i));
        await _settle(tester);
      }
    });

    testWidgets(
      'split view, ${platform.name}: resize with a nested page open',
      (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.binding.setSurfaceSize(_sizes.first);
        await tester.pumpWidget(_app(SplitViewScreen(platform: platform)));
        await _settle(tester);
        final controller = _controller(tester);
        controller.select(page);
        await _settle(tester);
        await tester.tap(await _scrollTo(tester, nestedTile));
        await _settle(tester);

        for (final size in _sizes) {
          await tester.binding.setSurfaceSize(size);
          await _settle(tester);
          expect(controller.selectedId, page, reason: '$size');
          expect(
            find.textContaining(nestedText).hitTestable(),
            findsWidgets,
            reason: 'the nested page is still shown at $size',
          );
        }

        // Back (one pane at 420): the nested page, then the page.
        await tester.binding.handlePopRoute();
        await _settle(tester);
        expect(controller.selectedId, page);
        await tester.binding.handlePopRoute();
        await _settle(tester);
        expect(controller.selectedId, isNull);
      },
    );
  }
}
