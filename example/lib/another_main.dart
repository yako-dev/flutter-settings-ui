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
    // return _materialApp();
    return _cupertinoApp();
  }

  MaterialApp _materialApp() {
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
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.yellow),
      ),
      darkTheme: ThemeData(
        // useMaterial3: true,
        scaffoldBackgroundColor: Colors.red,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Settings UI')),
        body: _settings(),
        // body: _cupertinoTiles(),
        // body: Center(
        //   child: Text('jasdfsld'),
        // ),
      ),
    );
  }

  CupertinoApp _cupertinoApp() {
    return CupertinoApp(
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      title: 'Settings UI',
      theme: CupertinoThemeData(
        // scaffoldBackgroundColor: CupertinoDynamicColor.withBrightness(
        //     color: CupertinoColors.activeBlue,
        //     darkColor: CupertinoColors.activeOrange),
        // primaryColor: CupertinoDynamicColor.withBrightness(
        //     color: Colors.yellow, darkColor: Colors.purple),
        barBackgroundColor: CupertinoDynamicColor.withBrightness(
            color: Colors.yellow, darkColor: Colors.purple),
        // textTheme: CupertinoTextThemeData(
        //   primaryColor: Colors.black,
        // ),
      ),
      home: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Cupertino app'),
        ),
        child: _settings(),
        // child: _cupertinoTiles(),
        // child: Center(
        //   child: Text('jasdfsld'),
        // ),
      ),
    );
  }

  Widget _settings() {
    return SettingsList(
      lightTheme: SettingsThemeData(
        sectionTitleColor: Colors.green,
      ),
      darkTheme: SettingsThemeData(
        sectionTitleColor: Colors.purple,
      ),
      // useSystemTheme: true,
      // platform: DevicePlatform.iOS,
      sections: [
        SettingsSection(
          // margin: EdgeInsetsDirectional.symmetric(horizontal: 0, vertical: 20),
          title: Text('COMMON'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Icon(Icons.language),
              title: Text('Language'),
              value: Text('English'),
              // enabled: false,
              // onPressed: (context) {},
              subtitle: Text('The item description'),
            ),
            SettingsTile.switchTile(
              activeSwitchColor: Colors.red,
              onToggle: (value) {
                setState(() {
                  _switchValue = value;
                });
              },
              initialValue: _switchValue,
              leading: Icon(Icons.format_paint),
              title: Text('Enable custom theme'),
              description: Text('Enable custom theme'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cupertinoTiles() {
    return CupertinoListSection.insetGrouped(
      header: const Text('My Reminders'),
      footer: const Text('Footer'),
      // decoration: BoxDecoration(
      // color: CupertinoColors.activeBlue,
      // borderRadius: BorderRadius.circular(20),
      // ),
      children: <CupertinoListTile>[
        // CupertinoListTile(
        //   title: const Text('Open pull request'),
        //   leading: Container(
        //     width: double.infinity,
        //     height: double.infinity,
        //     color: CupertinoColors.activeGreen,
        //   ),
        //   trailing: const CupertinoListTileChevron(),
        //   onTap: () {},
        // ),
        CupertinoListTile(
          title: const Text('Push to master'),
          leading: Container(
            width: double.infinity,
            height: double.infinity,
            color: CupertinoColors.systemRed,
          ),
          additionalInfo: const Text('Not available'),
        ),
        CupertinoListTile(
          title: const Text('View last commit'),
          leading: Container(
            width: double.infinity,
            height: double.infinity,
            color: CupertinoColors.activeOrange,
          ),
          additionalInfo: const Text('12 days ago'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {},
        ),
      ],
    );
  }
}
