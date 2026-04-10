import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/sections/platforms/android_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/ios_settings_section.dart';
import 'package:settings_ui/src/sections/platforms/web_settings_section.dart';

import '../test_widget_screen.dart';

void devicePlatformTest(TargetPlatform targetPlatform) {
  testWidgets('Device Platform Test', (tester) async {
    debugDefaultTargetPlatformOverride = targetPlatform;

    await tester.pumpWidget(
      MaterialApp(
        home: TestWidgetScreen(
          settingsTiles: [
            SettingsTile.navigation(
              title: const Text('Abstract settings screen'),
              leading: const Icon(CupertinoIcons.wrench),
              description:
                  const Text('UI created to show plugin\'s possibilities'),
              onPressed: (context) {},
            ),
            SettingsTile.navigation(
              title: const Text('Abstract settings screen'),
              leading: const Icon(CupertinoIcons.wrench),
              description:
                  const Text('UI created to show plugin\'s possibilities'),
              onPressed: (context) {},
            ),
          ],
        ),
      ),
    );
    expect(find.text('General'), findsOneWidget);
    if (targetPlatform == TargetPlatform.android ||
        targetPlatform == TargetPlatform.fuchsia ||
        targetPlatform == TargetPlatform.linux) {
      expect(find.byType(AndroidSettingsSection), findsOneWidget);
      expect(find.byType(IOSSettingsSection), findsNothing);
      expect(find.byType(WebSettingsSection), findsNothing);
    }
    if (targetPlatform == TargetPlatform.iOS ||
        targetPlatform == TargetPlatform.macOS ||
        targetPlatform == TargetPlatform.windows) {
      expect(find.byType(IOSSettingsSection), findsOneWidget);
      expect(find.byType(AndroidSettingsSection), findsNothing);
      expect(find.byType(WebSettingsSection), findsNothing);
    }
    debugDefaultTargetPlatformOverride = null;
  });
}
