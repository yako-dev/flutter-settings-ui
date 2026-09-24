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
      title: 'Settings UI Demo',
      home: const GalleryScreen(),
    );
  }
}
