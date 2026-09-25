import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/utils/settings_style.dart';

/// iPad Settings keeps its sidebar at 320pt in both orientations
/// (UISplitViewController's default maximum primary column width).
const double kCupertinoListPaneWidth = 320;

/// AOSP Settings gives the homepage 36.36% of the window
/// (config_activity_embed_split_ratio).
const double kMaterialListPaneFraction = 0.3636;

/// Chrome's settings menu (--settings-menu-width).
const double kWebListPaneWidth = 266;

/// Chrome's settings page: #main's flex basis is the 680px card column
/// divided by the 96% card width.
const double kWebMainBasis = 680 / 0.96;

/// Where the panes go, for one layout pass. Internal.
@immutable
class SplitGeometry {
  const SplitGeometry.single()
    : isSplit = false,
      listWidth = 0,
      gap = 0,
      detailWidth = 0;

  const SplitGeometry.split({
    required this.listWidth,
    required this.gap,
    required this.detailWidth,
  }) : isSplit = true;

  final bool isSplit;

  /// Width of the list pane (the start pane).
  final double listWidth;

  /// Space between the panes: the hinge, when one splits the window.
  final double gap;
  final double detailWidth;

  @override
  String toString() => isSplit
      ? 'SplitGeometry.split($listWidth | $gap | $detailWidth)'
      : 'SplitGeometry.single()';
}

/// Whether the host platform is a desktop, where the window's shortest side
/// says nothing about the device.
bool isDesktopPlatform(TargetPlatform platform) {
  switch (platform) {
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return true;
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.fuchsia:
      return false;
  }
}

/// Whether a style shows two panes at [width] by default.
///
/// - Cupertino (iPad): width >= 600 on a device whose shortest side is at
///   least 600 (so an iPad, iPad mini portrait included, but not an iPhone in
///   landscape). Apple publishes no point threshold; iPadOS switches with the
///   horizontal size class, which is compact in a 444pt window and regular
///   in the 744pt iPad mini portrait.
/// - Material: AOSP Settings' rule, width >= 720dp and smallest width
///   >= 600dp.
/// - Web: Chrome's, width > 980px.
///
/// On desktops only the width counts.
bool defaultShowsTwoPanes({
  required SettingsStyleFamily family,
  required double width,
  required double shortestSide,
  required bool desktop,
}) {
  switch (family) {
    case SettingsStyleFamily.cupertino:
      return width >= 600 && (desktop || shortestSide >= 600);
    case SettingsStyleFamily.material:
      return width >= 720 && (desktop || shortestSide >= 600);
    case SettingsStyleFamily.web:
      return width > 980;
  }
}

/// The default list pane width of a style for a window [width] wide.
double defaultListPaneWidth(SettingsStyleFamily family, double width) {
  switch (family) {
    case SettingsStyleFamily.cupertino:
      return kCupertinoListPaneWidth;
    case SettingsStyleFamily.material:
      return width * kMaterialListPaneFraction;
    case SettingsStyleFamily.web:
      return kWebListPaneWidth;
  }
}

/// A fold or hinge that cuts the split view into a start and an end part,
/// in the split view's coordinates.
@immutable
class SeparatingHinge {
  const SeparatingHinge({required this.left, required this.right});

  /// Distance from the split view's left edge to the hinge.
  final double left;

  /// Distance from the split view's left edge to the end of the hinge.
  final double right;

  double get width => right - left;
}

/// Finds a vertical display feature that separates the window into two
/// screens within `[origin.dx, origin.dx + size.width]`.
///
/// A hinge (always occluding) or a fold in the half-opened (book) posture
/// separates. A flat fold, like an unfolded Pixel Fold, does not, so it
/// doesn't move the panes (Material's HingePolicy.AvoidSeparating).
/// Horizontal (tabletop) features are ignored.
SeparatingHinge? findSeparatingHinge({
  required List<DisplayFeature> features,
  required Offset origin,
  required Size size,
}) {
  for (final feature in features) {
    final bounds = feature.bounds;
    if (feature.type == DisplayFeatureType.cutout) continue;
    final separates =
        feature.type == DisplayFeatureType.hinge ||
        feature.state == DisplayFeatureState.postureHalfOpened;
    if (!separates) continue;
    // Vertical: taller than wide and spanning the split view's height.
    final vertical =
        bounds.height > bounds.width &&
        bounds.top <= origin.dy + 0.5 &&
        bounds.bottom >= origin.dy + size.height - 0.5;
    if (!vertical) continue;
    final left = bounds.left - origin.dx;
    final right = bounds.right - origin.dx;
    // Only a hinge strictly inside the split view splits it.
    if (left <= 0 || right >= size.width) continue;
    return SeparatingHinge(left: left, right: right);
  }
  return null;
}

/// Decides one or two panes and their widths.
SplitGeometry computeSplitGeometry({
  required SettingsStyleFamily family,
  required bool forceSingle,
  required bool forceSplit,
  required double width,
  required double shortestSide,
  required bool desktop,
  required TextDirection textDirection,
  double? breakpoint,
  double? listPaneWidth,
  SeparatingHinge? hinge,
}) {
  if (forceSingle || width <= 0) return const SplitGeometry.single();

  // A separating hinge always gets one pane on each side of it, the list on
  // the start side: nothing should straddle it.
  if (hinge != null) {
    final startWidth = textDirection == TextDirection.ltr
        ? hinge.left
        : width - hinge.right;
    return SplitGeometry.split(
      listWidth: startWidth,
      gap: hinge.width,
      detailWidth: width - startWidth - hinge.width,
    );
  }

  final split =
      forceSplit ||
      (breakpoint != null
          ? width >= breakpoint
          : defaultShowsTwoPanes(
              family: family,
              width: width,
              shortestSide: shortestSide,
              desktop: desktop,
            ));
  if (!split) return const SplitGeometry.single();

  var listWidth = listPaneWidth ?? defaultListPaneWidth(family, width);
  // Leave the detail at least half the window when a narrow window is forced
  // into two panes.
  listWidth = math.min(listWidth, width / 2);
  return SplitGeometry.split(
    listWidth: listWidth,
    gap: 0,
    detailWidth: width - listWidth,
  );
}

/// Chrome's settings page puts a spacer after its content that grows as fast
/// as the content area (#main and #right both flex: 1), so the 680px column
/// sits closer to the menu than to the window edge. Returns that spacer's
/// width for a detail pane [detailWidth] wide.
double webDetailEndReserve(double detailWidth) =>
    math.max(0, (detailWidth - kWebMainBasis) / 2);
