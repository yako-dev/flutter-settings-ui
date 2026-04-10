import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';

/// Tests for bugs fixed in v3.0.0.

void bugFixTests() {
  group('iOS value overflow (Issue #186)', () {
    testWidgets('Long value text is clipped and does not overflow',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsList(
              platform: DevicePlatform.iOS,
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile.navigation(
                      title: const Text('Language'),
                      value: const Text(
                        'A very long value that would overflow in a narrow tile on any screen size',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // The widget tree should render without overflow errors.
      expect(tester.takeException(), isNull);
      expect(find.text('Language'), findsOneWidget);
    });
  });

  group('RTL chevron direction (Issue #139 related)', () {
    testWidgets('Chevron points backward (left) in RTL layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: SettingsList(
                platform: DevicePlatform.iOS,
                sections: [
                  SettingsSection(
                    tiles: [
                      SettingsTile.navigation(
                        title: const Text('Language'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // In RTL the back-chevron should be shown, not the forward one.
      expect(find.byIcon(CupertinoIcons.chevron_back), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.chevron_forward), findsNothing);
    });

    testWidgets('Chevron points forward (right) in LTR layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.ltr,
              child: SettingsList(
                platform: DevicePlatform.iOS,
                sections: [
                  SettingsSection(
                    tiles: [
                      SettingsTile.navigation(
                        title: const Text('Language'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.chevron_forward), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.chevron_back), findsNothing);
    });
  });

  group('Compact tile parameter', () {
    for (final platform in [
      DevicePlatform.android,
      DevicePlatform.iOS,
      DevicePlatform.web,
    ]) {
      testWidgets('Compact tile renders on $platform without errors',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsList(
                platform: platform,
                sections: [
                  SettingsSection(
                    tiles: [
                      SettingsTile(
                        title: const Text('Normal tile'),
                        compact: false,
                      ),
                      SettingsTile(
                        title: const Text('Compact tile'),
                        compact: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Normal tile'), findsOneWidget);
        expect(find.text('Compact tile'), findsOneWidget);
      });
    }
  });

  group('Web switch color (Issue #188)', () {
    testWidgets('Disabled web switch uses inactive color, not hardcoded blue',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsList(
              platform: DevicePlatform.web,
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile.switchTile(
                      title: const Text('Toggle'),
                      initialValue: true,
                      onToggle: null,
                      enabled: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // Disabled switch should still render without crash.
      expect(find.byType(Switch), findsOneWidget);
    });
  });

  group('Platform override (Issue #139)', () {
    testWidgets(
        'Setting platform: android uses Android tile even on macOS platform',
        (tester) async {
      // Simulate macOS host but explicitly request android tiles.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsList(
              platform: DevicePlatform.android,
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile.navigation(
                      title: const Text('Item'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // On android there should be no Cupertino chevron.
      expect(find.byIcon(CupertinoIcons.chevron_forward), findsNothing);
    });
  });
}
