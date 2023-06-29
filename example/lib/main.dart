import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/settings_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: kIsWeb ? false : !kReleaseMode,
      builder: (_) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Settings UI Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: SettingsScreen(),
    );
  }
}
