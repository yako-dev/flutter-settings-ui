import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:example/screens/gallery_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
    final bool runCupertinoApp = !kIsWeb && Platform.isIOS;

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
        darkTheme: ThemeData.dark(),
        title: 'Settings UI Demo',
        home: GalleryScreen(),
      );
    }
  }
}
