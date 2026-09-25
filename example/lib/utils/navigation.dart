import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

enum NavigationRouteStyle { cupertino, material }

class Navigation {
  static Future<T?> navigateTo<T>({
    required BuildContext context,
    required Widget screen,
    required NavigationRouteStyle style,
  }) async {
    Route<T> route = MaterialPageRoute<T>(builder: (_) => screen);
    if (style == NavigationRouteStyle.cupertino) {
      route = CupertinoPageRoute<T>(builder: (_) => screen);
    }
    return await Navigator.push<T>(context, route);
  }
}
