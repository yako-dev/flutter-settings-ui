import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:example/screens/gallery_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Flutter Demo');
    setWindowMinSize(const Size(400, 300));
    setWindowMaxSize(Size.infinite);
  }
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
    /// Set to `true` to see the full possibilities of the iOS Developer Screen
    final bool runCupertinoApp = false;

    if (runCupertinoApp) {
      return CupertinoApp(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        title: 'Settings UI Demo',
        home: GalleryScreen(),
      );
    } else {
      return MaterialApp(
        useInheritedMediaQuery: true,
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        theme: ThemeData.light(),
        darkTheme: ThemeData(
            cupertinoOverrideTheme: CupertinoThemeData(
                barBackgroundColor: Color(0xFF1b1b1b),
                brightness: Brightness.dark,
                textTheme: CupertinoTextThemeData(primaryColor: Colors.white)),
            brightness: Brightness.dark),
        title: 'Settings UI Demo',
        home: GalleryScreen(),
      );
    }
  }
}
