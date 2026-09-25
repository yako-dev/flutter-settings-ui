import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:settings_ui/src/utils/theme_provider.dart';

/// A tile in the list pane of a web-style split view, drawn as an item of
/// Chrome's settings menu: 40px tall, a 20px icon, 14px medium text, and a
/// pill rounded on the end side when selected. Descriptions and values are
/// not shown, as in Chrome's menu. Internal.
class WebSettingsMenuItem extends StatelessWidget {
  const WebSettingsMenuItem({
    required this.tileType,
    required this.leading,
    required this.title,
    required this.onPressed,
    required this.onToggle,
    required this.initialValue,
    required this.activeSwitchColor,
    required this.enabled,
    required this.selected,
    this.trailing,
    super.key,
  });

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget title;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final bool initialValue;
  final Color? activeSwitchColor;
  final bool enabled;
  final bool selected;

  /// Drawn right after the title, like the external-link icon of Chrome's
  /// "Extensions" item.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) =>
      ThemeProvider.withListColorScheme(context, Builder(builder: _buildTile));

  Widget _buildTile(BuildContext context) {
    final theme = SettingsTheme.of(context).themeData;
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);

    final foreground = !enabled
        ? theme.inactiveTitleColor
        : selected
        ? (theme.selectedTileTextColor ?? theme.settingsTileTextColor)
        : theme.settingsTileTextColor;
    final iconColor = !enabled
        ? theme.inactiveTitleColor
        : selected
        ? (theme.selectedTileIconColor ?? theme.leadingIconsColor)
        : theme.leadingIconsColor;

    final isSwitch = tileType == SettingsTileType.switchTile;
    // A disabled item takes no focus, keys or taps (the IgnorePointer below
    // only blocks new pointers).
    final onChanged = enabled ? onToggle : null;
    final VoidCallback? onTap = !enabled
        ? null
        : isSwitch
        ? (onToggle == null ? null : () => onToggle!(!initialValue))
        : (onPressed == null ? null : () => onPressed!(context));

    final item = IgnorePointer(
      ignoring: !enabled,
      child: Padding(
        // cr-nav-menu-item: 1px start margin, 2px end margin.
        padding: const EdgeInsetsDirectional.only(start: 1, end: 2),
        child: Material(
          color: selected
              ? (theme.selectedTileColor ?? Colors.transparent)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadiusDirectional.horizontal(
              end: Radius.circular(100),
            ).resolve(textDirection),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            hoverColor: theme.settingsTileTextColor?.withValues(alpha: 0.06),
            highlightColor: theme.tileHighlightColor,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: textScaler.scale(40)),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 23,
                  end: 16,
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    if (leading != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 20),
                        child: IconTheme(
                          data: IconTheme.of(
                            context,
                          ).copyWith(color: iconColor, size: 20),
                          child: leading!,
                        ),
                      ),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: DefaultTextStyle(
                              style:
                                  (theme.tileTextStyle ??
                                          const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ))
                                      .copyWith(color: foreground),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              child: title,
                            ),
                          ),
                          if (trailing != null)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 16,
                              ),
                              child: IconTheme(
                                data: IconTheme.of(
                                  context,
                                ).copyWith(color: iconColor, size: 20),
                                child: trailing!,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isSwitch)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 8),
                        child: SizedBox(
                          height: 20,
                          child: FittedBox(
                            child: Switch(
                              value: initialValue,
                              onChanged: onChanged,
                              activeThumbColor: activeSwitchColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // The row and the switch both toggle: one node, "title, switch, on".
    return isSwitch ? MergeSemantics(child: item) : item;
  }
}
