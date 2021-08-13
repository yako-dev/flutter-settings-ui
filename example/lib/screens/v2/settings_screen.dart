import 'package:example/screens/v2/ios_developer_screen.dart';
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
    return CupertinoPageScaffold(
      child: ListView(
        children: [
          Material(
            child: ListTile(
              title: Text('IOS Developer Screen'),
              onTap: () {
                Navigator.push(context, CupertinoPageRoute(builder: (context) {
                  return IosDeveloperScreen();
                }));
              },
            ),
          ),
        ],
      ),
    );
  }
}
