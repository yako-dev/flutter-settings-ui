import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui_v2.dart';

class WebChromeSettings extends StatelessWidget {
  const WebChromeSettings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SettingsList(
        sections: [],
      ),
    );
  }
}
