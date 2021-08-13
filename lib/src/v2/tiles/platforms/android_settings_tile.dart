import 'package:flutter/material.dart';

class AndroidSettingsTile extends StatelessWidget {
  const AndroidSettingsTile({
    this.leading,
    this.title,
    Key? key,
  }) : super(key: key);

  final Widget? leading;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    // final myInheritedWidget = SettingsTheme.of(context);
    return Container(
      // color: myInheritedWidget.tileBackgroundColor,
      child: Text('android tile'),
    );
  }
}
