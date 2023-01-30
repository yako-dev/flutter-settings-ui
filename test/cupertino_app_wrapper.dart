import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

Widget wrapWithCupertinoApp(
  Widget settingsWidget,
  DevicePlatform platform,
  Brightness? brightness,
) {
  return CupertinoApp(
    theme: CupertinoThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: const CupertinoTextThemeData(
        primaryColor: Colors.black,
      ),
    ),
    home: CupertinoPageScaffold(
      navigationBar:
          const CupertinoNavigationBar(middle: Text('Cupertino app')),
      child: settingsWidget,
    ),
  );
}

// Resolved color that we need for successful color comparison in tests
CupertinoDynamicColor getCupertinoScaffoldBackgroundColor(
    BuildContext context) {
  return scaffoldBackgroundColor.resolveFrom(context);
}

CupertinoDynamicColor get scaffoldBackgroundColor =>
    const CupertinoDynamicColor.withBrightness(
        color: Colors.grey, darkColor: Colors.blue);
