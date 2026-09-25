import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/split/settings_destination.dart';
import 'package:settings_ui/src/split/settings_page_header.dart';
import 'package:settings_ui/src/split/split_scopes.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_style.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

/// A destination page: the package's header over the destination's body.
/// Internal.
class SettingsDestinationPage extends StatelessWidget {
  const SettingsDestinationPage({
    super.key,
    required this.destination,
    required this.title,
    required this.config,
    this.isDetailRoot = false,
  });

  final SettingsDestination destination;

  /// The header title: the destination's title or the tile's.
  final Widget title;

  /// The style of the list that opened the page, which the body inherits.
  final SettingsStyleConfig config;

  /// Whether the page is the root of a split view's detail pane. There it
  /// only gets a back button in one pane, and the button closes the page
  /// through the split view.
  final bool isDetailRoot;

  @override
  Widget build(BuildContext context) {
    final style = config.resolve(context);
    final VoidCallback? onBack;
    if (isDetailRoot) {
      final split = SettingsSplitScope.maybeOf(context);
      onBack = split == null || split.isSplit ? null : split.goBack;
    } else {
      final route = ModalRoute.of(context);
      onBack = route != null && route.impliesAppBarDismissal
          ? () => Navigator.maybePop(context)
          : null;
    }

    return SettingsStyleScope(
      config: style.resolvedConfig,
      inherit: true,
      child: SettingsTheme(
        themeData: style.themeData,
        platform: style.platform,
        child: Material(
          color: style.themeData.settingsListBackground,
          child:
              settingsStyleFamily(style.platform) ==
                  SettingsStyleFamily.material
              ? SettingsCollapsingTitleView(
                  title: title,
                  actions: destination.actions,
                  onBack: onBack,
                  body: Builder(builder: destination.builder),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsPageBar(
                      platform: style.platform,
                      title: title,
                      actions: destination.actions,
                      onBack: onBack,
                    ),
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: Builder(builder: destination.builder),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// The platform route for a destination page pushed from a tile:
/// [CupertinoPageRoute] for the iOS style, [MaterialPageRoute] otherwise
/// (so Android gets the app's page transitions, predictive back included).
Route<void> settingsDestinationRoute({
  required SettingsDestination destination,
  required Widget title,
  required SettingsStyleConfig config,
  required DevicePlatform platform,
}) {
  final settings = RouteSettings(name: destination.id);
  Widget build(BuildContext context) => SettingsDestinationPage(
    destination: destination,
    title: title,
    config: config,
  );
  if (settingsStyleFamily(platform) == SettingsStyleFamily.cupertino) {
    return CupertinoPageRoute<void>(builder: build, settings: settings);
  }
  return MaterialPageRoute<void>(builder: build, settings: settings);
}

/// Opens [destination] from a tile at [context]: selects it when the tile is
/// in a split view's list pane, otherwise pushes its page on the nearest
/// [Navigator] (inside a split view's detail pane, that's the detail pane's).
void openSettingsDestination(
  BuildContext context, {
  required SettingsDestination destination,
  required Widget tileTitle,
}) {
  final listScope = SettingsSplitListScope.maybeOf(context);
  if (listScope != null) {
    listScope.onOpen(destination, tileTitle);
    return;
  }
  final platform = SettingsTheme.of(context).platform;
  final config =
      SettingsStyleScope.maybeOf(context)?.config ??
      SettingsStyleConfig(platform: platform);
  Navigator.of(context).push(
    settingsDestinationRoute(
      destination: destination,
      title: destination.title ?? tileTitle,
      config: config,
      platform: platform,
    ),
  );
}
