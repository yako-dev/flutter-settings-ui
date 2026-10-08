import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/src/tiles/platforms/cupertino_settings_switch.dart';
import 'package:settings_ui/src/tiles/settings_tile.dart';
import 'package:settings_ui/src/tiles/tile_data.dart';
import 'package:settings_ui/src/utils/platform_utils.dart';
import 'package:settings_ui/src/utils/settings_style.dart';
import 'package:settings_ui/src/utils/settings_theme.dart';

class IOSSettingsTile extends StatefulWidget {
  const IOSSettingsTile(
    this.tile, {
    this.selected = false,
    this.sidebar = false,
    this.semanticsSelected,
    super.key,
  });

  final SettingsTileData tile;

  /// Drawn as the selected row of an iPad sidebar: a filled capsule.
  final bool selected;

  /// In the list pane of a split view with two panes: an iPad sidebar row
  /// (no card, separator or chevron; highlighted as a capsule).
  final bool sidebar;

  /// Whether assistive technologies hear the row as selected: null for rows
  /// that don't open a page in a split view's list pane.
  final bool? semanticsSelected;

  @override
  IOSSettingsTileState createState() => IOSSettingsTileState();
}

class IOSSettingsTileState extends State<IOSSettingsTile> {
  SettingsTileData get tile => widget.tile;

  bool isPressed = false;

  /// Clears the pressed tint shortly after a tap.
  Timer? _releaseTimer;

  /// Only an enabled row with `onPressed` reacts to taps, and only then does
  /// it expose a tap action to screen readers.
  bool get _canPress => tile.enabled && tile.onPressed != null;

  @override
  void didUpdateWidget(IOSSettingsTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_canPress) {
      _releaseTimer?.cancel();
      isPressed = false;
    }
  }

  @override
  void dispose() {
    _releaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final additionalInfo = IOSSettingsTileAdditionalInfo.of(context);
    final theme = SettingsTheme.of(context);

    // The row is one node, so the rows of a section never merge into one. A
    // row with onPressed is a button, dimmed when disabled. A switch row
    // without onPressed reads as its switch: "title, switch, on" (with it,
    // the switch is a node of its own, labelled with the title).
    final isSwitch = tile.tileType == SettingsTileType.switchTile;
    final isButton = tile.onPressed != null;
    Widget row = Semantics(
      container: true,
      button: isButton,
      enabled: isButton || (!isSwitch && !tile.enabled) ? tile.enabled : null,
      selected: widget.semanticsSelected,
      child: buildTitle(
        context: context,
        theme: theme,
        additionalInfo: additionalInfo,
      ),
    );
    if (isSwitch && !isButton) row = MergeSemantics(child: row);

    return IgnorePointer(
      ignoring: !tile.enabled,
      child: Column(
        children: [
          row,
          if (tile.description != null)
            buildDescription(
              context: context,
              theme: theme,
              additionalInfo: additionalInfo,
            ),
        ],
      ),
    );
  }

  Widget buildTitle({
    required BuildContext context,
    required SettingsTheme theme,
    required IOSSettingsTileAdditionalInfo additionalInfo,
  }) {
    Widget content = buildTileContent(context, theme, additionalInfo);
    // Use the platform from SettingsTheme (respects user's explicit choice)
    // rather than re-detecting from the system, which ignored platform overrides.
    if (theme.platform != DevicePlatform.iOS) {
      content = Material(color: Colors.transparent, child: content);
    }

    // iPad sidebar rows highlight as a 52pt capsule.
    if (widget.sidebar) {
      return ClipRRect(borderRadius: BorderRadius.circular(26), child: content);
    }

    // Continuous (superellipse) corners, like the grouped cards in iOS
    // Settings.
    return ClipRSuperellipse(
      borderRadius: BorderRadius.vertical(
        top: additionalInfo.enableTopBorderRadius
            ? const Radius.circular(26)
            : Radius.zero,
        bottom: additionalInfo.enableBottomBorderRadius
            ? const Radius.circular(26)
            : Radius.zero,
      ),
      child: content,
    );
  }

  Widget buildDescription({
    required BuildContext context,
    required SettingsTheme theme,
    required IOSSettingsTileAdditionalInfo additionalInfo,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);

    // Fill the width the tile gets (a pane of a split view can be much
    // narrower than the screen), falling back to the screen width when it's
    // unbounded. The footer is a semantics node of its own, read after the
    // row.
    return Semantics(
      container: true,
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          width: constraints.hasBoundedWidth
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width,
          padding:
              tile.descriptionPadding ??
              EdgeInsets.only(
                left: 16,
                right: 16,
                top: textScaler.scale(8),
                bottom: additionalInfo.needToShowDivider
                    ? 24
                    : textScaler.scale(8),
              ),
          decoration: BoxDecoration(
            color: theme.themeData.settingsListBackground,
          ),
          child: DefaultTextStyle(
            style:
                (theme.themeData.tileDescriptionTextStyle ??
                        const TextStyle(fontSize: 13))
                    .copyWith(color: theme.themeData.titleTextColor),
            child: tile.description!,
          ),
        ),
      ),
    );
  }

  /// Returns the non-value trailing controls (switch, trailing icon, chevron).
  Widget buildTrailing({
    required BuildContext context,
    required SettingsTheme theme,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final iconColor = widget.selected
        ? (theme.themeData.selectedTileIconColor ??
              theme.themeData.leadingIconsColor)
        : theme.themeData.leadingIconsColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tile.trailing != null)
          Padding(
            padding:
                tile.trailingPadding ??
                const EdgeInsets.symmetric(horizontal: 16),
            child: IconTheme(
              data: IconTheme.of(context).copyWith(
                color: tile.enabled
                    ? iconColor
                    : theme.themeData.inactiveTitleColor,
              ),
              child: tile.trailing!,
            ),
          ),
        // The switch's glass lens paints up to ~12.5pt past its end and ~6pt
        // above and below it. The 16pt end padding and the 52pt row keep it
        // inside the card.
        if (tile.tileType == SettingsTileType.switchTile)
          tile.labelSwitchIfSeparate(
            CupertinoTheme(
              // The switch picks its light or dark colors from this: the
              // list's, which `SettingsList.brightness` can set apart from the
              // app's.
              data: CupertinoTheme.of(
                context,
              ).copyWith(brightness: SettingsStyleScope.brightnessOf(context)),
              child: CupertinoSettingsSwitch(
                value: tile.initialValue,
                // A disabled tile's switch takes no focus, keys or taps.
                onChanged: tile.enabled ? tile.onToggle : null,
                activeTrackColor: tile.enabled
                    ? tile.activeSwitchColor
                    : (theme.themeData.inactiveSwitchColor ??
                          theme.themeData.inactiveTitleColor),
              ),
            ),
          ),
        // iPad sidebar rows have no chevron.
        if (tile.tileType == SettingsTileType.navigationTile && !widget.sidebar)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, end: 2),
            child: IconTheme(
              data: IconTheme.of(context).copyWith(color: iconColor),
              child: Icon(
                isRTL
                    ? CupertinoIcons.chevron_back
                    : CupertinoIcons.chevron_forward,
                size: textScaler.scale(18),
              ),
            ),
          ),
      ],
    );
  }

  void changePressState({bool isPressed = false}) {
    // A tap recognizer that is dropped mid-press (the tile was disabled)
    // cancels during the build. didUpdateWidget has cleared the tint by then.
    if (mounted && this.isPressed != isPressed) {
      setState(() {
        this.isPressed = isPressed;
      });
    }
  }

  Widget buildTileContent(
    BuildContext context,
    SettingsTheme theme,
    IOSSettingsTileAdditionalInfo additionalInfo,
  ) {
    final textScaler = MediaQuery.textScalerOf(context);
    final shouldShowInlineValue =
        (tile.tileType == SettingsTileType.navigationTile ||
            tile.tileType == SettingsTileType.simpleTile) &&
        tile.value != null;
    final themeData = theme.themeData;
    final selected = widget.selected;
    final Color? background;
    if (widget.sidebar) {
      background = selected
          ? themeData.selectedTileColor
          : isPressed
          ? themeData.tileHighlightColor
          : null;
    } else {
      background = isPressed
          ? themeData.tileHighlightColor
          : themeData.settingsSectionBackground;
    }
    final titleColor = !tile.enabled
        ? themeData.inactiveTitleColor
        : selected
        ? (themeData.selectedTileTextColor ?? themeData.settingsTileTextColor)
        : themeData.settingsTileTextColor;
    final valueColor = !tile.enabled
        ? themeData.inactiveTitleColor
        : selected
        ? (themeData.selectedTileTextColor ?? themeData.trailingTextColor)
        : themeData.trailingTextColor;
    final iconColor = !tile.enabled
        ? themeData.inactiveTitleColor
        : selected
        ? (themeData.selectedTileIconColor ?? themeData.leadingIconsColor)
        : themeData.leadingIconsColor;

    // Without callbacks the detector has no tap recognizer, so a row that
    // does nothing exposes no tap action, and a press that started before
    // the tile was disabled does not fire.
    final canPress = _canPress;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: canPress
          ? () {
              changePressState(isPressed: true);

              tile.onPressed!.call(context);

              _releaseTimer?.cancel();
              _releaseTimer = Timer(
                const Duration(milliseconds: 100),
                () => changePressState(isPressed: false),
              );
            }
          : null,
      onTapDown: canPress ? (_) => changePressState(isPressed: true) : null,
      onTapUp: canPress ? (_) => changePressState(isPressed: false) : null,
      onTapCancel: canPress ? () => changePressState(isPressed: false) : null,
      child: Container(
        color: background,
        // iPad sidebar: icon 14pt into the row, label 8.5pt after a 28pt
        // icon.
        padding: EdgeInsetsDirectional.only(start: widget.sidebar ? 14 : 16),
        child: Row(
          children: [
            if (tile.leading != null)
              Padding(
                padding:
                    tile.leadingPadding ??
                    EdgeInsetsDirectional.only(
                      end: widget.sidebar ? 8.5 : 12.0,
                    ),
                child: IconTheme.merge(
                  data: IconThemeData(color: iconColor),
                  child: tile.leading!,
                ),
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: widget.sidebar ? 14 : 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            // The title fills the row. The value keeps its
                            // natural width, up to half the row, so neither a
                            // long title nor a long value can hide the other
                            // (Issues #186, #203).
                            builder: (context, constraints) => Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            tile.titlePadding ??
                                            // 16 + 17pt text + 16 gives the
                                            // 52pt row of iOS Settings.
                                            EdgeInsetsDirectional.only(
                                              top: textScaler.scale(
                                                tile.compact ? 8.0 : 16.0,
                                              ),
                                              bottom:
                                                  tile.titleDescription == null
                                                  ? textScaler.scale(
                                                      tile.compact ? 8.0 : 16.0,
                                                    )
                                                  : textScaler.scale(
                                                      tile.compact ? 2.0 : 4.0,
                                                    ),
                                            ),
                                        child: DefaultTextStyle(
                                          style:
                                              (theme.themeData.tileTextStyle ??
                                                      const TextStyle(
                                                        fontSize: 17,
                                                      ))
                                                  .copyWith(color: titleColor),
                                          child: tile.title,
                                        ),
                                      ),
                                      if (tile.titleDescription != null)
                                        Padding(
                                          padding:
                                              tile.titleDescriptionPadding ??
                                              EdgeInsetsDirectional.only(
                                                bottom: textScaler.scale(
                                                  tile.compact ? 8.0 : 16.0,
                                                ),
                                              ),
                                          child: DefaultTextStyle(
                                            style: TextStyle(
                                              color: !tile.enabled
                                                  ? themeData.inactiveTitleColor
                                                  : selected
                                                  ? titleColor?.withValues(
                                                      alpha: 0.8,
                                                    )
                                                  : themeData.titleTextColor,
                                              fontSize: 15,
                                            ),
                                            child: tile.titleDescription!,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (shouldShowInlineValue)
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 8,
                                    ),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: constraints.maxWidth / 2,
                                      ),
                                      child: DefaultTextStyle(
                                        style: TextStyle(
                                          color: valueColor,
                                          fontSize: 17,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.end,
                                        child: tile.value!,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        buildTrailing(context: context, theme: theme),
                      ],
                    ),
                  ),
                  if (tile.description == null &&
                      additionalInfo.needToShowDivider &&
                      !widget.sidebar)
                    Divider(
                      height: 0,
                      thickness: 0.7,
                      color: theme.themeData.dividerColor,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IOSSettingsTileAdditionalInfo extends InheritedWidget {
  final bool needToShowDivider;
  final bool enableTopBorderRadius;
  final bool enableBottomBorderRadius;

  const IOSSettingsTileAdditionalInfo({
    super.key,
    required this.needToShowDivider,
    required this.enableTopBorderRadius,
    required this.enableBottomBorderRadius,
    required super.child,
  });

  @override
  bool updateShouldNotify(IOSSettingsTileAdditionalInfo oldWidget) => true;

  static IOSSettingsTileAdditionalInfo of(BuildContext context) {
    final IOSSettingsTileAdditionalInfo? result = context
        .dependOnInheritedWidgetOfExactType<IOSSettingsTileAdditionalInfo>();
    // assert(result != null, 'No IOSSettingsTileAdditionalInfo found in context');
    return result ??
        const IOSSettingsTileAdditionalInfo(
          needToShowDivider: true,
          enableBottomBorderRadius: true,
          enableTopBorderRadius: true,
          child: SizedBox(),
        );
  }
}
