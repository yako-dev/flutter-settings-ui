import 'package:example/screens/v2/gallery/android_settings_screen.dart';
import 'package:example/screens/v2/gallery/cross_platform_settings_screen.dart';
import 'package:example/screens/v2/gallery/ios_developer_screen.dart';
import 'package:example/screens/v2/gallery/web_chrome_settings.dart';
import 'package:example/utils/navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key key}) : super(key: key);

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gallery')),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 20),
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              leading: Icon(CupertinoIcons.settings, size: 34),
              trailing: Icon(CupertinoIcons.right_chevron),
              title: Text('iOS Developer Screen'),
              subtitle: Text('CupertinoApp required'),
              onTap: () {
                Navigation.navigateTo(
                  context: context,
                  screen: IosDeveloperScreen(),
                  style: NavigationRouteStyle.cupertino,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, size: 34),
              trailing: Icon(CupertinoIcons.right_chevron),
              title: Text('Android Settings Screen'),
              subtitle: Text('MaterialApp required'),
              onTap: () {
                Navigation.navigateTo(
                  context: context,
                  screen: AndroidSettingsScreen(),
                  style: NavigationRouteStyle.material,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.web, size: 34),
              trailing: Icon(CupertinoIcons.right_chevron),
              title: Text('Web Settings'),
              onTap: () {
                Navigation.navigateTo(
                  context: context,
                  screen: WebChromeSettings(),
                  style: NavigationRouteStyle.material,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.devices, size: 34),
              trailing: Icon(CupertinoIcons.right_chevron),
              title: Text('Cross Platform Settings Screen'),
              onTap: () {
                Navigation.navigateTo(
                  context: context,
                  screen: CrossPlatformSettingsScreen(),
                  style: NavigationRouteStyle.material,
                );
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}
