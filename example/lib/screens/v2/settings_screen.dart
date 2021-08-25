import 'package:example/screens/v2/gallery/ios_developer_screen.dart';
import 'package:example/utils/navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                );
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}
