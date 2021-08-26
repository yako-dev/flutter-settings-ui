import 'package:flutter/material.dart';

class SettingsTileTheme {
  /// If true then [ListTile]s will have the vertically dense layout.
  ///
  /// Only Android
  final bool? dense;

  /// {@template flutter.material.ListTileTheme.shape}
  /// If specified, [shape] defines the [ListTile]'s shape.
  /// {@endtemplate}
  ///
  /// Only Android
  final ShapeBorder? shape;

  /// If specified, [style] defines the font used for [ListTile] titles.
  ///
  /// Only Android
  final ListTileStyle? style;

  /// If specified, the color used for icons and text when a [ListTile] is selected.
  ///
  /// Only Android
  final Color? selectedColor;

  /// If specified, the icon color used for enabled [ListTile]s that are not selected.
  final Color? iconColor;

  /// If specified, the text color used for enabled [ListTile]s that are not selected.
  final Color? textColor;

  /// The tile's internal padding.
  ///
  /// Insets a [ListTile]'s contents: its [ListTile.leading], [ListTile.title],
  /// [ListTile.subtitle], and [ListTile.trailing] widgets.
  ///
  /// Only Android
  final EdgeInsetsGeometry? contentPadding;

  /// If specified, defines the background color for `ListTile` when
  /// [ListTile.selected] is false.
  ///
  /// If [ListTile.tileColor] is provided, [tileColor] is ignored.
  final Color? tileColor;

  /// If specified, defines the background color for `ListTile` when
  /// [ListTile.selected] is true.
  ///
  /// If [ListTile.selectedTileColor] is provided, [selectedTileColor] is ignored.
  ///
  /// Only Android
  final Color? selectedTileColor;

  /// The horizontal gap between the titles and the leading/trailing widgets.
  ///
  /// If specified, overrides the default value of [ListTile.horizontalTitleGap].
  ///
  /// Only Android
  final double? horizontalTitleGap;

  /// The minimum padding on the top and bottom of the title and subtitle widgets.
  ///
  /// If specified, overrides the default value of [ListTile.minVerticalPadding].
  ///
  /// Only Android
  final double? minVerticalPadding;

  /// The minimum width allocated for the [ListTile.leading] widget.
  ///
  /// If specified, overrides the default value of [ListTile.minLeadingWidth].
  ///
  /// Only Android
  final double? minLeadingWidth;

  /// If specified, defines the feedback property for `ListTile`.
  ///
  /// If [ListTile.enableFeedback] is provided, [enableFeedback] is ignored.
  ///
  /// Only Android
  final bool? enableFeedback;

  const SettingsTileTheme({
    this.tileColor,
    this.contentPadding,
    this.shape,
    this.selectedTileColor,
    this.dense,
    this.style,
    this.selectedColor,
    this.iconColor,
    this.textColor,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.minLeadingWidth,
    this.enableFeedback,
  });
}
