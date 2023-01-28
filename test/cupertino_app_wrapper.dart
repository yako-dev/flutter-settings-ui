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
      scaffoldBackgroundColor: const CupertinoDynamicColor.withBrightness(
          color: Colors.grey, darkColor: Colors.blue),
      barBackgroundColor: const CupertinoDynamicColor.withBrightness(
          color: Colors.yellow, darkColor: Colors.purple),
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

CupertinoDynamicColor getCupertinoScaffoldBackgroundColor(
    BuildContext context) {
  return const CupertinoDynamicColor.withBrightness(
          color: Colors.grey, darkColor: Colors.blue)
      .resolveFrom(context);
}
