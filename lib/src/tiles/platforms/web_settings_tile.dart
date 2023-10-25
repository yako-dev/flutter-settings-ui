import 'package:flutter/material.dart';
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
    this.titlePadding,
    this.leadingPadding,
    this.trailingPadding,
    this.descriptionPadding,
    Key? key,
  }) : super(key: key);

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget? title;
  final Widget? description;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final Widget? value;
  final bool initialValue;
  final bool enabled;
  final Widget? trailing;
  final Color? activeSwitchColor;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? leadingPadding;
  final EdgeInsetsGeometry? trailingPadding;
  final EdgeInsetsGeometry? descriptionPadding;

  @override
  Widget build(BuildContext context) {
    final theme = SettingsTheme.of(context);
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    final cantShowAnimation = tileType == SettingsTileType.switchTile
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
                  padding: leadingPadding ??
                      // TODO: move literals to file with theme constants
                      const EdgeInsetsDirectional.only(
                        start: 24,
                      ),
                  child: IconTheme(
                    data: IconTheme.of(context).copyWith(
                      color: enabled
                          ? theme.themeData.tileLeadingIconsColor
                          : theme.themeData.tileDisabledContentColor,
                    ),
                    child: leading!,
                  ),
                ),
              Expanded(
                child: Padding(
                  // TODO: move literals to file with theme constants
                  padding: EdgeInsetsDirectional.only(
                    start: 24,
                    end: 24,
                    bottom: 19 * scaleFactor,
                    top: 19 * scaleFactor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        // TODO: move literals to file with theme constants
                        style: TextStyle(
                          color: enabled
                              ? theme.themeData.tileTitleTextColor
                              : theme.themeData.tileDisabledContentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        child: title ?? Container(),
                      ),
                      if (value != null)
                        Padding(
                          // TODO: move literals to file with theme constants
                          padding: const EdgeInsets.only(top: 4.0),
                          child: DefaultTextStyle(
                            style: TextStyle(
                              color: enabled
                                  ? theme.themeData.tileDescriptionTextColor
                                  : theme.themeData.inactiveSubtitleColor,
                            ),
                            child: value!,
                          ),
                        )
                      else if (description != null)
                        Padding(
                          padding: descriptionPadding ??
                              // TODO: move literals to file with theme constants
                              const EdgeInsets.only(top: 4.0),
                          child: DefaultTextStyle(
                            style: TextStyle(
                              color: enabled
                                  ? theme.themeData.tileDescriptionTextColor
                                  : theme.themeData.inactiveSubtitleColor,
                            ),
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
                    IconTheme(
                      data: IconTheme.of(context).copyWith(
                        color: enabled
                            ? theme.themeData.tileLeadingIconsColor
                            : theme.themeData.tileDisabledContentColor,
                      ),
                      child: trailing!,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: Switch.adaptive(
                        activeColor: enabled
                            ? (activeSwitchColor ??
                                // TODO: move color constant to file with theme constants

                                const Color.fromRGBO(138, 180, 248, 1.0))
                            : theme.themeData.tileDisabledContentColor,
                        value: initialValue,
                        onChanged: onToggle,
                      ),
                    ),
                  ],
                )
              else if (tileType == SettingsTileType.switchTile)
                Padding(
                  // TODO: move literals to file with theme constants
                  padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
                  child: Switch(
                    value: initialValue,
                    activeColor: enabled
                        ? (activeSwitchColor ??
                            // TODO: move color constant to file with theme constants
                            const Color.fromRGBO(138, 180, 248, 1.0))
                        : theme.themeData.tileDisabledContentColor,
                    onChanged: onToggle,
                  ),
                )
              else if (trailing != null)
                Padding(
                  padding: trailingPadding ??
                      // TODO: move literals to file with theme constants
                      const EdgeInsets.symmetric(horizontal: 16),
                  child: IconTheme(
                    data: IconTheme.of(context).copyWith(
                      color: enabled
                          ? theme.themeData.tileLeadingIconsColor
                          : theme.themeData.tileDisabledContentColor,
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
