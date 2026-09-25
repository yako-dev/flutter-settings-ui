import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';

/// The text of a tile's [title] when it is a [Text] or a [RichText] (its
/// semantics label if it has one), or null for other widgets. Internal.
String? tileTitleLabel(Widget? title) {
  if (title is Text) {
    return title.semanticsLabel ??
        title.data ??
        title.textSpan?.toPlainText(includeSemanticsLabels: true);
  }
  if (title is RichText) {
    return title.text.toPlainText(includeSemanticsLabels: true);
  }
  return null;
}

/// Makes a tile's switch one semantics node that says what it switches:
/// [label] (the tile title, see [tileTitleLabel]), then the switch state.
///
/// For switch tiles whose row has an action of its own (`onPressed` on iOS,
/// macOS and Windows), so the row and the switch are separate nodes and the
/// switch would otherwise read as just "switch, on". Internal.
Widget labelTileSwitch({required Widget? title, required Widget child}) {
  return MergeSemantics(
    child: Semantics(label: tileTitleLabel(title), child: child),
  );
}

/// Makes a section's [tile] one semantics node, so screen readers read each
/// row on its own. A [SettingsTile] is a node already; any other tile (a
/// `CustomSettingsTile`) gets a node here, or its text would be read with
/// the section title or the rows next to it. Internal.
Widget tileSemanticsNode(Widget tile) =>
    tile is SettingsTile ? tile : Semantics(container: true, child: tile);
