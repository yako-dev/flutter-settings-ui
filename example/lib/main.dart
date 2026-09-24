import 'package:example/screens/gallery/macos_notifications_screen.dart';
import 'package:example/screens/gallery_screen.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Screenshot scripts can open a screen directly and force light or dark:
/// `?screen=macos&theme=dark` on the web, or
/// `--dart-define=SCREEN=macos --dart-define=THEME=dark` elsewhere.
final String _screen =
    Uri.base.queryParameters['screen'] ??
    const String.fromEnvironment('SCREEN');
final String _theme =
    Uri.base.queryParameters['theme'] ?? const String.fromEnvironment('THEME');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      themeMode: switch (_theme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      title: 'Settings UI Demo',
      home: switch (_screen) {
        'macos' => const MacosNotificationsScreen(),
        _ => const GalleryScreen(),
      },
    );
  }
}
