import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Tests that each padding and switch color given to [SettingsTile] reaches
/// the platform tile.

Future<void> _pump(
  WidgetTester tester,
  DevicePlatform platform,
  AbstractSettingsTile tile, {
  SettingsThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SettingsList(
          platform: platform,
          lightTheme: theme,
          sections: [
            SettingsSection(tiles: [tile]),
          ],
        ),
      ),
    ),
  );
}

EdgeInsetsGeometry _paddingAround(WidgetTester tester, Finder finder) => tester
    .widget<Padding>(
      find.ancestor(of: finder, matching: find.byType(Padding)).first,
    )
    .padding;

void tilePaddingTests() {
  testWidgets('iOS: titleDescriptionPadding pads the title description', (
    tester,
  ) async {
    await _pump(
      tester,
      DevicePlatform.iOS,
      SettingsTile(
        title: const Text('Title'),
        titleDescription: const Text('Below'),
        titlePadding: const EdgeInsets.all(3),
        titleDescriptionPadding: const EdgeInsets.all(7),
      ),
    );

    expect(_paddingAround(tester, find.text('Title')), const EdgeInsets.all(3));
    expect(_paddingAround(tester, find.text('Below')), const EdgeInsets.all(7));
  });

  testWidgets('iOS: trailingPadding pads the trailing widget', (tester) async {
    await _pump(
      tester,
      DevicePlatform.iOS,
      SettingsTile(
        title: const Text('Title'),
        trailing: const Icon(Icons.star),
        trailingPadding: const EdgeInsets.all(5),
      ),
    );

    expect(
      _paddingAround(tester, find.byIcon(Icons.star)),
      const EdgeInsets.all(5),
    );
  });

  testWidgets('iOS: descriptionPadding pads the description', (tester) async {
    await _pump(
      tester,
      DevicePlatform.iOS,
      SettingsTile(
        title: const Text('Title'),
        description: const Text('Footer'),
        descriptionPadding: const EdgeInsets.all(11),
      ),
    );

    expect(
      _paddingAround(tester, find.text('Footer')),
      const EdgeInsets.all(11),
    );
  });

  for (final platform in [DevicePlatform.android, DevicePlatform.web]) {
    testWidgets('$platform: titlePadding pads the title', (tester) async {
      await _pump(
        tester,
        platform,
        SettingsTile(
          title: const Text('Title'),
          titlePadding: const EdgeInsets.all(9),
        ),
      );

      expect(
        _paddingAround(tester, find.text('Title')),
        const EdgeInsets.all(9),
      );
    });

    for (final withTrailing in [false, true]) {
      final label = withTrailing ? 'with' : 'without';

      testWidgets(
        '$platform: a disabled switch $label trailing uses inactiveSwitchColor',
        (tester) async {
          await _pump(
            tester,
            platform,
            SettingsTile.switchTile(
              title: const Text('Title'),
              initialValue: true,
              onToggle: null,
              enabled: false,
              trailing: withTrailing ? const Icon(Icons.star) : null,
            ),
            theme: const SettingsThemeData(inactiveSwitchColor: Colors.pink),
          );

          expect(
            tester.widget<Switch>(find.byType(Switch)).activeThumbColor,
            Colors.pink,
          );
        },
      );

      testWidgets(
        '$platform: an enabled switch $label trailing has no default active '
        'color, so SwitchTheme applies',
        (tester) async {
          await _pump(
            tester,
            platform,
            SettingsTile.switchTile(
              title: const Text('Title'),
              initialValue: true,
              onToggle: (_) {},
              trailing: withTrailing ? const Icon(Icons.star) : null,
            ),
          );

          expect(
            tester.widget<Switch>(find.byType(Switch)).activeThumbColor,
            isNull,
          );
        },
      );
    }
  }
}
