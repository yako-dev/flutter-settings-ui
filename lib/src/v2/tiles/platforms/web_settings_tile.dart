import 'package:flutter/material.dart';

class WebSettingsTile extends StatelessWidget {
  const WebSettingsTile({
    this.leading,
    this.title,
    Key? key,
  }) : super(key: key);

  final Widget? leading;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    return Text('web tile');
  }
}
