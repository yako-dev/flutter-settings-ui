import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';

import '../test_widget_screen.dart';

void settingsTileOnTapTests(DevicePlatform platform) {
  testWidgets('Settings Tile onPressed is called', (tester) async {
    bool isPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: TestWidgetScreen(
          platform: platform,
          settingsTiles: [
            SettingsTile(
              title: const Text('Abstract settings tile'),
              value: const Text('Tile Value'),
              onPressed: (context) {
                isPressed = true;
              },
              trailing: const Icon(
                Icons.ac_unit,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(SettingsTile));
    await tester.pump(const Duration(milliseconds: 300));
    expect(isPressed, true);
  });

  testWidgets('Settings Switch Tile onPressed is called', (tester) async {
    bool isPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: TestWidgetScreen(
          platform: platform,
          settingsTiles: [
            SettingsTile.switchTile(
              title: const Text('Abstract settings tile'),
              trailing: const Icon(Icons.ac_unit, size: 24),
              initialValue: isPressed,
              onToggle: (bool value) {
                isPressed = value;
              },
            ),
          ],
        ),
      ),
    );
    if (platform == DevicePlatform.iOS ||
        platform == DevicePlatform.macOS ||
        platform == DevicePlatform.windows) {
      await tester.tap(find.byType(CupertinoSwitch));
    } else {
      await tester.tap(find.byType(Switch));
    }

    await tester.pump(const Duration(milliseconds: 300));
    expect(isPressed, true);
  });
}
