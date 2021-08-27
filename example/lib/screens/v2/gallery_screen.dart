import 'package:example/screens/v2/gallery/android_notifications_screen.dart';
import 'package:example/screens/v2/gallery/ios_developer_screen.dart';
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
              title: Text('The iOS Developer Screen'),
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
              title: Text('The Android Notifications Screen'),
              subtitle: Text('MaterialApp required'),
              onTap: () {
                Navigation.navigateTo(
                  context: context,
                  screen: AndroidNotificationsScreen(),
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
