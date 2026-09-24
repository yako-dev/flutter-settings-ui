import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Tests for where the value sits in iOS tiles (Issues #201, #203).

const _longTitle = 'Allow notifications while the app is in the background';
const _longValue = 'firstname.lastname@example-company.com';

Future<void> _pumpTiles(
  WidgetTester tester,
  List<AbstractSettingsTile> tiles, {
  TextDirection textDirection = TextDirection.ltr,
}) async {
  tester.view.physicalSize = const Size(1206, 2622);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: SettingsList(
            platform: DevicePlatform.iOS,
            sections: [SettingsSection(tiles: tiles)],
          ),
        ),
      ),
    ),
  );
}

void iosValueLayoutTests() {
  testWidgets('Navigation tile value is right-aligned next to the chevron '
      '(Issue #203)', (tester) async {
    await _pumpTiles(tester, [
      SettingsTile.navigation(
        title: const Text('Language'),
        value: const Text('English'),
      ),
      SettingsTile.navigation(title: const Text('About')),
    ]);

    final chevrons = find.byIcon(CupertinoIcons.chevron_forward);
    final withValue = tester.getRect(chevrons.at(0));
    final withoutValue = tester.getRect(chevrons.at(1));
    final value = tester.getRect(find.text('English'));
    expect(withValue.left, moreOrLessEquals(withoutValue.left));
    expect(withValue.left - value.right, moreOrLessEquals(6));
  });

  testWidgets('Simple tile shows its value (Issue #201)', (tester) async {
    await _pumpTiles(tester, [
      SettingsTile(title: const Text('Version'), value: const Text('1.0.0')),
    ]);

    expect(find.text('1.0.0'), findsOneWidget);
    expect(tester.getSize(find.text('1.0.0')).width, greaterThan(0));
  });

  testWidgets('A long title does not hide a short value', (tester) async {
    await _pumpTiles(tester, [
      SettingsTile.navigation(
        title: const Text(_longTitle),
        value: const Text('On'),
      ),
    ]);

    final title = tester.getRect(find.text(_longTitle));
    final value = tester.getRect(find.text('On'));
    final chevron = tester.getRect(find.byIcon(CupertinoIcons.chevron_forward));
    expect(value.width, greaterThan(0));
    expect(chevron.left - value.right, moreOrLessEquals(6));
    expect(title.right, lessThanOrEqualTo(value.left));
  });

  testWidgets('A long value uses at most half the row, on one line', (
    tester,
  ) async {
    await _pumpTiles(tester, [
      SettingsTile.navigation(
        title: const Text('Email'),
        value: const Text(_longValue),
      ),
    ]);

    final title = tester.getRect(find.text('Email'));
    final value = tester.getRect(find.text(_longValue));
    final chevron = tester.getRect(find.byIcon(CupertinoIcons.chevron_forward));
    final row = chevron.left - 6 - title.left;
    expect(value.width, lessThanOrEqualTo(row / 2));
    expect(value.height, lessThan(title.height * 1.5));
    expect(title.right, lessThanOrEqualTo(value.left));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Value sits at the start side in RTL', (tester) async {
    await _pumpTiles(tester, [
      SettingsTile.navigation(
        title: const Text('Language'),
        value: const Text('English'),
      ),
      SettingsTile.navigation(title: const Text('About')),
    ], textDirection: TextDirection.rtl);

    final title = tester.getRect(find.text('Language'));
    final value = tester.getRect(find.text('English'));
    final chevrons = find.byIcon(CupertinoIcons.chevron_back);
    final chevron = tester.getRect(chevrons.at(0));
    expect(
      chevron.right,
      moreOrLessEquals(tester.getRect(chevrons.at(1)).right),
    );
    expect(value.right, lessThanOrEqualTo(title.left));
    expect(value.left - chevron.right, moreOrLessEquals(6));
  });
}
