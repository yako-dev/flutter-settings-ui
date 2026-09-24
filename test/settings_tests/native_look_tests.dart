import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Tests for the 2026 native look: Android 16+ grouped cards, iOS 26+
/// rounded cards, and Chrome-style web cards.

Future<void> _pump(
  WidgetTester tester,
  DevicePlatform platform,
  List<AbstractSettingsTile> tiles, {
  Size size = const Size(400, 900),
  Widget? title,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SettingsList(
          platform: platform,
          sections: [SettingsSection(title: title, tiles: tiles)],
        ),
      ),
    ),
  );
}

List<SettingsTile> _tiles(int count) => [
  for (var i = 0; i < count; i++) SettingsTile(title: Text('Tile $i')),
];

void nativeLookTests() {
  testWidgets('Android: each tile is a card, rounder at the group ends', (
    tester,
  ) async {
    await _pump(tester, DevicePlatform.android, _tiles(3));

    final clips = tester
        .widgetList<ClipRRect>(find.byType(ClipRRect))
        .map((clip) => clip.borderRadius)
        .toList();
    expect(clips, [
      const BorderRadius.vertical(
        top: Radius.circular(20),
        bottom: Radius.circular(4),
      ),
      const BorderRadius.all(Radius.circular(4)),
      const BorderRadius.vertical(
        top: Radius.circular(4),
        bottom: Radius.circular(20),
      ),
    ]);

    final first = tester.getRect(find.byType(ClipRRect).at(0));
    final second = tester.getRect(find.byType(ClipRRect).at(1));
    expect(second.top - first.bottom, 2);
    expect(first.left, 16);
  });

  testWidgets('Android: cards use the section background color', (
    tester,
  ) async {
    await _pump(tester, DevicePlatform.android, _tiles(1));

    final context = tester.element(find.text('Tile 0'));
    final box = tester.widget<ColoredBox>(
      find
          .ancestor(of: find.text('Tile 0'), matching: find.byType(ColoredBox))
          .first,
    );
    expect(
      box.color,
      SettingsTheme.of(context).themeData.settingsSectionBackground,
    );
  });

  testWidgets('Android: switches show a check or a cross on the thumb', (
    tester,
  ) async {
    await _pump(tester, DevicePlatform.android, [
      SettingsTile.switchTile(
        title: const Text('On'),
        initialValue: true,
        onToggle: (_) {},
      ),
      SettingsTile.switchTile(
        title: const Text('Off'),
        initialValue: false,
        onToggle: (_) {},
      ),
    ]);

    final switches = tester.widgetList<Switch>(find.byType(Switch));
    expect(switches, hasLength(2));
    for (final widget in switches) {
      expect(
        widget.thumbIcon?.resolve({WidgetState.selected})?.icon,
        Icons.check,
      );
      expect(widget.thumbIcon?.resolve({})?.icon, Icons.close);
    }
  });

  testWidgets('iOS: cards have 26pt continuous corners and 20pt margins', (
    tester,
  ) async {
    await _pump(tester, DevicePlatform.iOS, _tiles(1));

    final clip = tester.widget<ClipRSuperellipse>(
      find.byType(ClipRSuperellipse),
    );
    expect(clip.borderRadius, BorderRadius.circular(26));
    expect(tester.getRect(find.byType(ClipRSuperellipse)).left, 20);
  });

  testWidgets('iOS: section headers are 17pt semibold', (tester) async {
    await _pump(
      tester,
      DevicePlatform.iOS,
      _tiles(1),
      title: const Text('Vision'),
    );

    final style = tester
        .widget<DefaultTextStyle>(
          find
              .ancestor(
                of: find.text('Vision'),
                matching: find.byType(DefaultTextStyle),
              )
              .first,
        )
        .style;
    expect(style.fontSize, 17);
    expect(style.fontWeight, FontWeight.w600);
  });

  testWidgets('Web: navigation tiles end with a chevron, simple tiles do not', (
    tester,
  ) async {
    await _pump(tester, DevicePlatform.web, [
      SettingsTile.navigation(title: const Text('Security')),
      SettingsTile(title: const Text('Version')),
    ]);

    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    final chevron = tester.getRect(find.byIcon(Icons.chevron_right));
    final security = tester.getRect(find.text('Security'));
    expect(chevron.center.dy, moreOrLessEquals(security.center.dy, epsilon: 1));
  });

  testWidgets('Web: content is a 680px column on wide screens', (tester) async {
    await _pump(
      tester,
      DevicePlatform.web,
      _tiles(1),
      size: const Size(1280, 900),
    );

    expect(tester.getSize(find.byType(Card)).width, 680);
  });
}
