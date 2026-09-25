import 'package:example/screens/gallery/split_view_screen.dart';
import 'package:example/screens/gallery_screen.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The initial route can open a demo and pick the theme, for screenshots:
    // `flutter run --route '/split-view?style=ios&theme=dark'`, or
    // `#/split-view?style=web` in the web app's URL.
    final initialRoute = Uri.parse(
      WidgetsBinding.instance.platformDispatcher.defaultRouteName,
    );
    final themeMode = switch (initialRoute.queryParameters['theme']) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      themeMode: themeMode,
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        if (uri.path == '/split-view') {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => SplitViewScreen.fromQuery(uri.queryParameters),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData(
        useMaterial3: true,
        cupertinoOverrideTheme: const CupertinoThemeData(
          barBackgroundColor: Color(0xFF1b1b1b),
          brightness: Brightness.dark,
          textTheme: CupertinoTextThemeData(primaryColor: Colors.white),
        ),
        brightness: Brightness.dark,
      ),
      title: 'Settings UI Demo',
      home: const GalleryScreen(),
    );
  }
}
