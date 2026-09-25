import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

/// The values of the split view demo's switches, by title, so that they
/// toggle. Switches with the same title share a value, like one setting shown
/// in two places. `SplitViewScreen` clears the values when it opens.
class DemoSwitches extends ChangeNotifier {
  DemoSwitches._();

  static final instance = DemoSwitches._();

  final _values = <String, bool>{};

  /// The value of the switch titled [title]; [initial] until it is toggled.
  bool valueOf(String title, {required bool initial}) =>
      _values[title] ?? initial;

  void set(String title, bool value) {
    _values[title] = value;
    notifyListeners();
  }

  /// Forgets every toggled value.
  void reset() => _values.clear();
}

/// A switch tile whose value lives in [DemoSwitches]. Build it in a page
/// builder wrapped with [demoLive] (or in a widget that listens to
/// [DemoSwitches]) so it rebuilds.
///
/// With [showState], the tile also shows "On" or "Off" before the switch,
/// like Windows Settings.
SettingsTile demoSwitch(
  String title, {
  bool value = false,
  Widget? leading,
  Widget? description,
  Widget? titleDescription,
  bool showState = false,
}) {
  final on = DemoSwitches.instance.valueOf(title, initial: value);
  return SettingsTile.switchTile(
    leading: leading,
    title: Text(title),
    titleDescription: titleDescription,
    description: description,
    trailing: showState ? Text(on ? 'On' : 'Off') : null,
    initialValue: on,
    onToggle: (value) => DemoSwitches.instance.set(title, value),
  );
}

/// Wraps a page builder so that the page is built again when a [demoSwitch]
/// changes.
WidgetBuilder demoLive(WidgetBuilder builder) =>
    (context) => ListenableBuilder(
      listenable: DemoSwitches.instance,
      builder: (context, _) => builder(context),
    );
