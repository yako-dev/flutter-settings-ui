import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/utils/theme_provider.dart';

/// Pixel settings switches show a check when on and a cross when off.
final _thumbIcon = WidgetStateProperty.resolveWith<Icon>(
  (states) =>
      Icon(states.contains(WidgetState.selected) ? Icons.check : Icons.close),
);

class AndroidSettingsTile extends StatelessWidget {
  const AndroidSettingsTile({
    required this.tileType,
    required this.leading,
    required this.title,
    required this.description,
    required this.onPressed,
    required this.onToggle,
    required this.value,
    required this.initialValue,
    required this.activeSwitchColor,
    required this.enabled,
    required this.trailing,
    this.compact = false,
    this.titlePadding,
    this.leadingPadding,
    this.trailingPadding,
    this.descriptionPadding,
    this.selected = false,
    super.key,
  });

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget? title;
  final Widget? description;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final Widget? value;
  final bool initialValue;
  final bool enabled;
  final bool compact;
  final Color? activeSwitchColor;
  final Widget? trailing;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? leadingPadding;
  final EdgeInsetsGeometry? trailingPadding;
  final EdgeInsetsGeometry? descriptionPadding;

  /// Drawn as the selected item of a split view's list pane.
  final bool selected;

  @override
  Widget build(BuildContext context) =>
      ThemeProvider.withListColorScheme(context, Builder(builder: _buildTile));

  Widget _buildTile(BuildContext context) {
    final theme = SettingsTheme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final themeData = theme.themeData;

    // AOSP two-pane Settings fills the selected homepage card with the
    // detail pane's color, so it looks joined to it.
    final titleColor = !enabled
        ? themeData.inactiveTitleColor
        : selected
        ? (themeData.selectedTileTextColor ?? themeData.settingsTileTextColor)
        : themeData.settingsTileTextColor;
    final subtitleColor = !enabled
        ? themeData.inactiveSubtitleColor
        : selected
        ? (themeData.selectedTileTextColor?.withValues(alpha: 0.78) ??
              themeData.tileDescriptionTextColor)
        : themeData.tileDescriptionTextColor;
    final iconColor = !enabled
        ? themeData.inactiveTitleColor
        : selected
        ? (themeData.selectedTileIconColor ?? themeData.leadingIconsColor)
        : themeData.leadingIconsColor;

    // A disabled tile takes no focus, keys or taps (the IgnorePointer below
    // only blocks new pointers).
    final cantShowAnimation =
        !enabled ||
        (tileType == SettingsTileType.switchTile
            ? onToggle == null && onPressed == null
            : onPressed == null);
    final onChanged = enabled ? onToggle : null;

    final tile = IgnorePointer(
      ignoring: !enabled,
      child: Material(
        color: selected
            ? (themeData.selectedTileColor ?? Colors.transparent)
            : Colors.transparent,
        child: InkWell(
          onTap: cantShowAnimation
              ? null
              : () {
                  if (tileType == SettingsTileType.switchTile) {
                    onToggle?.call(!initialValue);
                  } else {
                    onPressed?.call(context);
                  }
                },
          highlightColor: theme.themeData.tileHighlightColor,
          child: Row(
            children: [
              if (leading != null)
                Padding(
                  padding:
                      leadingPadding ??
                      const EdgeInsetsDirectional.only(start: 16),
                  child: IconTheme(
                    data: IconTheme.of(context).copyWith(color: iconColor),
                    child: leading!,
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 16,
                    end: 16,
                    bottom: textScaler.scale(compact ? 6 : 12),
                    top: textScaler.scale(compact ? 6 : 12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: titlePadding ?? EdgeInsets.zero,
                        child: DefaultTextStyle(
                          style:
                              (theme.themeData.tileTextStyle ??
                                      const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ))
                                  .copyWith(color: titleColor),
                          child: title ?? Container(),
                        ),
                      ),
                      if (value != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: DefaultTextStyle(
                            style:
                                (theme.themeData.tileDescriptionTextStyle ??
                                        const TextStyle())
                                    .copyWith(color: subtitleColor),
                            child: value!,
                          ),
                        )
                      else if (description != null)
                        Padding(
                          padding:
                              descriptionPadding ??
                              const EdgeInsets.only(top: 4.0),
                          child: DefaultTextStyle(
                            style:
                                (theme.themeData.tileDescriptionTextStyle ??
                                        const TextStyle())
                                    .copyWith(color: subtitleColor),
                            child: description!,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (trailing != null && tileType == SettingsTileType.switchTile)
                Row(
                  children: [
                    trailing!,
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12),
                      child: Switch(
                        value: initialValue,
                        onChanged: onChanged,
                        thumbIcon: _thumbIcon,
                        activeThumbColor: enabled
                            ? activeSwitchColor
                            : (theme.themeData.inactiveSwitchColor ??
                                  theme.themeData.inactiveTitleColor),
                      ),
                    ),
                  ],
                )
              else if (tileType == SettingsTileType.switchTile)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
                  child: Switch(
                    value: initialValue,
                    onChanged: onChanged,
                    thumbIcon: _thumbIcon,
                    activeThumbColor: enabled
                        ? activeSwitchColor
                        : (theme.themeData.inactiveSwitchColor ??
                              theme.themeData.inactiveTitleColor),
                  ),
                )
              else if (trailing != null)
                Padding(
                  padding:
                      trailingPadding ??
                      const EdgeInsets.symmetric(horizontal: 16),
                  child: IconTheme(
                    data: IconTheme.of(context).copyWith(
                      color: enabled
                          ? theme.themeData.leadingIconsColor
                          : theme.themeData.inactiveTitleColor,
                    ),
                    child: trailing!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    // The row and the switch both toggle, so a switch tile is one node:
    // "title, switch, on".
    return tileType == SettingsTileType.switchTile
        ? MergeSemantics(child: tile)
        : tile;
  }
}
