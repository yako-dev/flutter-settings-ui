import 'package:device_preview/device_preview.dart';
// import 'package:example/screens/settings_screen.dart';
import 'package:example/screens/v2/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    DevicePreview(
      // enabled: kIsWeb ? false : !kReleaseMode,
      enabled: false,
      builder: (_) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool runMaterialApp = false;

    if (runMaterialApp) {
      return MaterialApp(
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        title: 'Settings UI Demo',
        home: SettingsScreen(),
      );
    } else {
      return CupertinoApp(
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(),
        title: 'Settings UI Demo',
        home: SettingsScreen(),
      );
    }
  }
}
