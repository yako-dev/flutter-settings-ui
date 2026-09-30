import 'package:material_ui/material_ui.dart';
import 'package:settings_ui/settings_ui.dart';

class WebSettingsTile extends StatelessWidget {
  const WebSettingsTile({
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
  final Widget? trailing;
  final Color? activeSwitchColor;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? leadingPadding;
  final EdgeInsetsGeometry? trailingPadding;
  final EdgeInsetsGeometry? descriptionPadding;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    final cantShowAnimation = tileType == .switchTile
        ? onToggle == null && onPressed == null
        : onPressed == null;

    return IgnorePointer(
      ignoring: !enabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: cantShowAnimation
              ? null
              : () {
                  if (tileType == .switchTile) {
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
                  padding: leadingPadding ?? const .only(left: 24),
                  child: IconTheme(
                    data: IconTheme.of(context).copyWith(
                      color: enabled
                          ? theme.themeData.leadingIconsColor
                          : theme.themeData.inactiveTitleColor,
                    ),
                    child: leading!,
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: .only(
                    left: 24,
                    right: 24,
                    bottom: textScaler.scale(compact ? 9 : 19),
                    top: textScaler.scale(compact ? 9 : 19),
                  ),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      DefaultTextStyle(
                        style:
                            (theme.themeData.tileTextStyle ??
                                    const TextStyle(
                                      fontSize: 18,
                                      fontWeight: .w400,
                                    ))
                                .copyWith(
                                  color: enabled
                                      ? theme.themeData.settingsTileTextColor
                                      : theme.themeData.inactiveTitleColor,
                                ),
                        child: title ?? Container(),
                      ),
                      if (value != null)
                        Padding(
                          padding: const .only(top: 4.0),
                          child: DefaultTextStyle(
                            style:
                                (theme.themeData.tileDescriptionTextStyle ??
                                        const TextStyle())
                                    .copyWith(
                                      color: enabled
                                          ? theme
                                                .themeData
                                                .tileDescriptionTextColor
                                          : theme
                                                .themeData
                                                .inactiveSubtitleColor,
                                    ),
                            child: value!,
                          ),
                        )
                      else if (description != null)
                        Padding(
                          padding: descriptionPadding ?? const .only(top: 4.0),
                          child: DefaultTextStyle(
                            style:
                                (theme.themeData.tileDescriptionTextStyle ??
                                        const TextStyle())
                                    .copyWith(
                                      color: enabled
                                          ? theme
                                                .themeData
                                                .tileDescriptionTextColor
                                          : theme
                                                .themeData
                                                .inactiveSubtitleColor,
                                    ),
                            child: description!,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // if (tileType == SettingsTileType.navigationTile)
              //   Padding(
              //     padding:
              //         const EdgeInsetsDirectional.only(start: 6, end: 15),
              //     child: IconTheme(
              //       data: IconTheme.of(context)
              //           .copyWith(color: theme.themeData.leadingIconsColor),
              //       child: Icon(
              //         CupertinoIcons.chevron_forward,
              //         size: 18 * scaleFactor,
              //       ),
              //     ),
              //   ),
              if (trailing != null && tileType == .switchTile)
                Row(
                  children: [
                    IconTheme(
                      data: IconTheme.of(context).copyWith(
                        color: enabled
                            ? theme.themeData.leadingIconsColor
                            : theme.themeData.inactiveTitleColor,
                      ),
                      child: trailing!,
                    ),
                    Padding(
                      padding: const .only(right: 8),
                      child: Switch(
                        activeThumbColor: enabled
                            ? (activeSwitchColor ??
                                  const Color.fromRGBO(138, 180, 248, 1.0))
                            : theme.themeData.inactiveTitleColor,
                        value: initialValue,
                        onChanged: onToggle,
                      ),
                    ),
                  ],
                )
              else if (tileType == .switchTile)
                Padding(
                  padding: const .only(left: 16, right: 8),
                  child: Switch(
                    value: initialValue,
                    activeThumbColor: !enabled
                        ? (theme.themeData.inactiveSwitchColor ??
                              theme.themeData.inactiveTitleColor)
                        : activeSwitchColor,
                    onChanged: onToggle,
                  ),
                )
              else if (trailing != null)
                Padding(
                  padding: trailingPadding ?? const .symmetric(horizontal: 16),
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
  }
}
