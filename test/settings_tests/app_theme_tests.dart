import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// Tests that SettingsList follows the theme of a material_ui /
/// cupertino_ui app (Issue #206).

const _seed = Color(0xFFD32F2F);

Widget _settingsList({DevicePlatform? platform, ApplicationType? type}) {
  return SettingsList(
    platform: platform,
    applicationType: type ?? ApplicationType.material,
    sections: [
      SettingsSection(
        title: const Text('Section'),
        tiles: [SettingsTile(title: const Text('Tile'))],
      ),
    ],
  );
}

Widget _materialApp(
  Brightness brightness, {
  TargetPlatform? targetPlatform,
  DevicePlatform? platform,
}) {
  return MaterialApp(
    theme: ThemeData(
      platform: targetPlatform,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: brightness,
      ),
    ),
    home: Scaffold(body: _settingsList(platform: platform)),
  );
}

SettingsTheme _settingsTheme(WidgetTester tester) =>
    SettingsTheme.of(tester.element(find.text('Tile')));

void appThemeTests() {
  for (final brightness in Brightness.values) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    for (final platform in [DevicePlatform.android, DevicePlatform.web]) {
      testWidgets('$platform, $brightness: colors follow the app ColorScheme', (
        tester,
      ) async {
        await tester.pumpWidget(_materialApp(brightness, platform: platform));

        final data = _settingsTheme(tester).themeData;
        expect(data.settingsListBackground, scheme.surfaceContainerLow);
        expect(data.titleTextColor, scheme.primary);
        expect(data.settingsTileTextColor, scheme.onSurface);
        expect(data.leadingIconsColor, scheme.onSurfaceVariant);
      });
    }
  }

  testWidgets('ThemeData.platform picks the tile style', (tester) async {
    await tester.pumpWidget(
      _materialApp(
        Brightness.light,
        targetPlatform: TargetPlatform.iOS,
        platform: DevicePlatform.device,
      ),
    );

    expect(_settingsTheme(tester).platform, DevicePlatform.iOS);
  });

  testWidgets('Dark CupertinoApp gives a dark iOS list', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        theme: const CupertinoThemeData(brightness: Brightness.dark),
        home: _settingsList(
          platform: DevicePlatform.iOS,
          type: ApplicationType.cupertino,
        ),
      ),
    );

    expect(
      _settingsTheme(tester).themeData.settingsListBackground,
      CupertinoColors.black,
    );
  });

  group('Missing theme warning', () {
    // debugPrint must be restored before the test body ends, or the test
    // binding reports a changed foundation debug variable.
    Future<List<String?>> capturePrints(Future<void> Function() body) async {
      final printed = <String?>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) => printed.add(message);
      try {
        await body();
      } finally {
        debugPrint = originalDebugPrint;
      }
      return printed;
    }

    setUp(SettingsList.debugResetMissingThemeWarning);

    testWidgets('is printed once when no app theme is found', (tester) async {
      Widget bare() => MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: _settingsList(platform: DevicePlatform.iOS),
        ),
      );

      final printed = await capturePrints(() async {
        await tester.pumpWidget(bare());
        await tester.pumpWidget(bare());
      });

      expect(printed, hasLength(1));
      expect(printed.single, contains('settings_ui ^3.0.1'));
    });

    testWidgets('is not printed inside a MaterialApp', (tester) async {
      final printed = await capturePrints(
        () => tester.pumpWidget(_materialApp(Brightness.light)),
      );
      expect(printed, isEmpty);
    });

    testWidgets('is not printed inside a CupertinoApp', (tester) async {
      final printed = await capturePrints(
        () => tester.pumpWidget(
          CupertinoApp(home: _settingsList(type: ApplicationType.cupertino)),
        ),
      );
      expect(printed, isEmpty);
    });
  });
}
