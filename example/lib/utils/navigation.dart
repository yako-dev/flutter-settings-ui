import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum NavigationRouteStyle {
  cupertino,
  material,
}

class Navigation {
  static void navigateTo({
    @required BuildContext context,
    @required Widget screen,
    @required NavigationRouteStyle style,
  }) {
    Route route;
    if (style == NavigationRouteStyle.cupertino) {
      route = CupertinoPageRoute(builder: (_) => screen);
    } else if (style == NavigationRouteStyle.material) {
      route = MaterialPageRoute(builder: (_) => screen);
    }

    Navigator.push(context, route);
  }
}
