import 'package:flutter/cupertino.dart';

class Navigation {
  static void navigateTo({
    @required BuildContext context,
    @required Widget screen,
  }) {
    Navigator.push(context, CupertinoPageRoute(builder: (_) => screen));
  }
}
