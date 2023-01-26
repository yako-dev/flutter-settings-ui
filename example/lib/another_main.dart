import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _switchValue = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      title: 'Settings UI',
      theme: ThemeData(
          // useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey,
          colorScheme: ColorScheme.fromSwatch(
                  backgroundColor: Colors.grey, primarySwatch: Colors.yellow)
              .copyWith(secondary: Colors.blueAccent)),
      darkTheme: ThemeData(
          // useMaterial3: true,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
              .copyWith(secondary: Colors.blueAccent)),
      home: Scaffold(
        appBar: AppBar(title: Text('Settings UI')),
        body: SettingsList(
          applicationType: ApplicationType.both,
          // lightTheme: SettingsThemeData(settingsListBackground: Colors.yellow),
          // darkTheme: SettingsThemeData(settingsListBackground: Colors.black),
          platform: DevicePlatform.iOS,
          sections: [
            SettingsSection(
              title: Text('Common'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  // leading: Icon(Icons.language),
                  title: Text('Language'),
                  value: Text('English'),
                  titleDescription: Text('The item description'),
                ),
                SettingsTile.switchTile(
                  onToggle: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                  initialValue: _switchValue,
                  leading: Icon(Icons.format_paint),
                  title: Text('Enable custom theme'),
                ),
              ],
            ),
          ],
        ),
        // body: Center(
        //   child: Text('jasdfsld'),
        // ),
      ),
    );
  }
}
