import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Regression tests for the SettingsList and SettingsSection fixes in 4.0.0.

const _lightMarker = Color(0xFF00FF00);
const _darkMarker = Color(0xFFFF00FF);

const _platforms = [
  DevicePlatform.android,
  DevicePlatform.fuchsia,
  DevicePlatform.linux,
  DevicePlatform.iOS,
  DevicePlatform.macOS,
  DevicePlatform.windows,
  DevicePlatform.web,
];

List<AbstractSettingsSection> _sections() => [
  SettingsSection(tiles: [SettingsTile(title: const Text('Tile'))]),
];

SettingsThemeData _themeData(WidgetTester tester) =>
    SettingsTheme.of(tester.element(find.text('Tile'))).themeData;

/// The width of the content column on wide screens.
double _column(DevicePlatform platform) => switch (platform) {
  DevicePlatform.web => 680,
  DevicePlatform.macOS => 640,
  _ => 810,
};

Future<void> _setScreen(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void listFixTests() {
  group('SettingsList.brightness', () {
    for (final platform in [
      DevicePlatform.android,
      DevicePlatform.iOS,
      DevicePlatform.web,
    ]) {
      for (final brightness in Brightness.values) {
        final appBrightness = brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark;

        testWidgets(
          '$brightness overrides a $appBrightness app theme on $platform',
          (tester) async {
            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(brightness: appBrightness),
                home: Scaffold(
                  body: SettingsList(
                    platform: platform,
                    brightness: brightness,
                    lightTheme: const SettingsThemeData(
                      settingsListBackground: _lightMarker,
                    ),
                    darkTheme: const SettingsThemeData(
                      settingsListBackground: _darkMarker,
                    ),
                    sections: _sections(),
                  ),
                ),
              ),
            );

            expect(
              _themeData(tester).settingsListBackground,
              brightness == Brightness.dark ? _darkMarker : _lightMarker,
            );
          },
        );
      }
    }

    testWidgets('iOS default colors follow the override', (tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.light),
          home: SettingsList(
            platform: DevicePlatform.iOS,
            applicationType: ApplicationType.cupertino,
            brightness: Brightness.dark,
            sections: _sections(),
          ),
        ),
      );

      expect(_themeData(tester).settingsListBackground, CupertinoColors.black);
    });
  });

  group('ApplicationType.both', () {
    testWidgets(
      'CupertinoApp that follows the system: dark on Apple platforms',
      (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

        await tester.pumpWidget(
          CupertinoApp(
            home: SettingsList(
              applicationType: ApplicationType.both,
              sections: _sections(),
            ),
          ),
        );

        expect(
          _themeData(tester).settingsListBackground,
          defaultTargetPlatform == TargetPlatform.macOS
              // macOS windowBackgroundColor in dark mode.
              ? const Color(0xFF1E1E1E)
              : CupertinoColors.black,
        );
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      }),
    );

    testWidgets(
      'decides by the platform the app runs on, not the forced tile style',
      (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

        await tester.pumpWidget(
          CupertinoApp(
            home: SettingsList(
              platform: DevicePlatform.android,
              applicationType: ApplicationType.both,
              darkTheme: const SettingsThemeData(
                settingsListBackground: _darkMarker,
              ),
              sections: _sections(),
            ),
          ),
        );

        expect(_themeData(tester).settingsListBackground, _darkMarker);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    // A named callback keeps the formatters of Dart 3.12 and 3.13 in
    // agreement about this call.
    Future<void> followsMaterialTheme(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Scaffold(
            body: SettingsList(
              applicationType: ApplicationType.both,
              darkTheme: const SettingsThemeData(
                settingsListBackground: _darkMarker,
              ),
              sections: _sections(),
            ),
          ),
        ),
      );

      expect(_themeData(tester).settingsListBackground, _darkMarker);
    }

    testWidgets(
      'MaterialApp: follows the Material theme on every platform',
      followsMaterialTheme,
      variant: TargetPlatformVariant.all(),
    );
  });

  group('crossAxisAlignment', () {
    for (final platform in [
      DevicePlatform.android,
      DevicePlatform.iOS,
      DevicePlatform.macOS,
      DevicePlatform.web,
    ]) {
      final column = _column(platform);
      final edge = platform == DevicePlatform.web ? 16.0 : 0.0;

      for (final direction in TextDirection.values) {
        testWidgets(
          'start on $platform ($direction): the column sits at the start',
          (tester) async {
            await _setScreen(tester, const Size(1400, 900));
            await tester.pumpWidget(
              MaterialApp(
                home: Directionality(
                  textDirection: direction,
                  child: Scaffold(
                    body: SettingsList(
                      platform: platform,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      sections: _sections(),
                    ),
                  ),
                ),
              ),
            );

            final section = tester.getRect(find.byType(SettingsSection));
            expect(section.width, column);
            if (direction == TextDirection.ltr) {
              expect(section.left, edge);
            } else {
              expect(section.right, 1400 - edge);
            }
          },
        );
      }

      testWidgets('center on $platform: the column is centered', (
        tester,
      ) async {
        await _setScreen(tester, const Size(1400, 900));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsList(platform: platform, sections: _sections()),
            ),
          ),
        );

        final section = tester.getRect(find.byType(SettingsSection));
        expect(section.width, column);
        expect(section.left, (1400 - column) / 2);
      });

      testWidgets('start on $platform in a narrow window keeps the margins', (
        tester,
      ) async {
        await _setScreen(tester, const Size(400, 900));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsList(
                platform: platform,
                crossAxisAlignment: CrossAxisAlignment.start,
                sections: _sections(),
              ),
            ),
          ),
        );

        final section = tester.getRect(find.byType(SettingsSection));
        expect(section.left, edge);
        expect(section.right, 400 - edge);
      });
    }

    testWidgets('contentPadding still wins over start', (tester) async {
      await _setScreen(tester, const Size(1400, 900));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsList(
              platform: DevicePlatform.iOS,
              crossAxisAlignment: CrossAxisAlignment.start,
              contentPadding: const EdgeInsets.symmetric(horizontal: 100),
              sections: _sections(),
            ),
          ),
        ),
      );

      final section = tester.getRect(find.byType(SettingsSection));
      expect(section.left, 100);
      expect(section.right, 1300);
    });
  });

  group('Default padding in a pane', () {
    for (final platform in [
      DevicePlatform.android,
      DevicePlatform.iOS,
      DevicePlatform.macOS,
      DevicePlatform.web,
    ]) {
      final column = _column(platform);
      final edge = platform == DevicePlatform.web ? 16.0 : 0.0;

      Widget pane(double width) => MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: width,
                child: SettingsList(platform: platform, sections: _sections()),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );

      testWidgets('$platform: content fits a narrow pane of a wide window', (
        tester,
      ) async {
        await _setScreen(tester, const Size(1600, 900));
        await tester.pumpWidget(pane(400));

        expect(tester.takeException(), isNull);
        final section = tester.getRect(find.byType(SettingsSection));
        expect(section.left, edge);
        expect(section.right, 400 - edge);
      });

      testWidgets('$platform: content is centered in a wide pane', (
        tester,
      ) async {
        await _setScreen(tester, const Size(1600, 900));
        await tester.pumpWidget(pane(1000));

        final section = tester.getRect(find.byType(SettingsSection));
        expect(section.width, column);
        expect(section.left, (1000 - column) / 2);
      });
    }
  });

  group('Empty section', () {
    for (final platform in _platforms) {
      testWidgets('$platform: a section without tiles renders nothing', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsList(
                platform: platform,
                sections: [
                  const SettingsSection(title: Text('Empty'), tiles: []),
                  SettingsSection(
                    title: const Text('Full'),
                    tiles: [SettingsTile(title: const Text('Tile'))],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('Empty'), findsNothing);
        expect(find.text('Full'), findsOneWidget);
        expect(find.text('Tile'), findsOneWidget);
        if (platform == DevicePlatform.web) {
          expect(find.byType(Card), findsOneWidget);
        }
      });
    }
  });
}
