import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui_v2.dart';
import 'package:settings_ui/src/v2/utils/settings_theme.dart';

class IOSSettingsTile extends StatelessWidget {
  const IOSSettingsTile({
    required this.tileType,
    required this.leading,
    required this.title,
    required this.description,
    required this.onPressed,
    required this.onToggle,
    required this.trailing,
    this.initialValue,
    Key? key,
  }) : super(key: key);

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget? title;
  final Widget? description;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final Widget? trailing;
  final bool? initialValue;

  @override
  Widget build(BuildContext context) {
    final additionalInfo = IOSSettingsTileAdditionalInfo.of(context);
    final theme = SettingsTheme.of(context);

    return Column(
      children: [
        buildTitle(
          context: context,
          theme: theme,
          additionalInfo: additionalInfo,
        ),
        if (description != null)
          Divider(
            height: 0,
            thickness: 0.5,
            color: CupertinoColors.separator,
          ),
        if (description != null)
          buildDescription(
            context: context,
            theme: theme,
            additionalInfo: additionalInfo,
          ),
      ],
    );
  }

  Widget buildTitle({
    required BuildContext context,
    required SettingsTheme theme,
    required IOSSettingsTileAdditionalInfo additionalInfo,
  }) {
    return InkWell(
      onTap: () => onPressed?.call(context),
      child: Container(
        height: 44.0,
        padding: EdgeInsetsDirectional.only(start: 18),
        child: Row(
          children: [
            if (leading != null)
              IconTheme.merge(
                data: IconThemeData(
                  color: CupertinoColors.inactiveGray,
                ),
                child: leading!,
              ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(end: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: DefaultTextStyle(
                              style: TextStyle(
                                color: theme.themeData.settingsTileTextColor,
                                fontSize: 16,
                              ),
                              child: title!,
                            ),
                          ),
                          buildTrailing(context: context, theme: theme),
                        ],
                      ),
                    ),
                  ),
                  if (description == null && additionalInfo.needToShowDivider)
                    Divider(
                      height: 0,
                      thickness: 1,
                      color: CupertinoColors.separator,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDescription({
    required BuildContext context,
    required SettingsTheme theme,
    required IOSSettingsTileAdditionalInfo additionalInfo,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: theme.themeData.settingsListBackground,
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: theme.themeData.titleTextColor,
          fontSize: 13,
        ),
        child: description!,
      ),
    );
  }

  Widget buildTrailing({
    required BuildContext context,
    required SettingsTheme theme,
  }) {
    if (tileType == SettingsTileType.simpleTile && trailing == null) {
      return Container();
    }

    return Row(
      children: [
        if (tileType == SettingsTileType.switchTile)
          Switch.adaptive(value: initialValue ?? true, onChanged: onToggle),
        if (tileType == SettingsTileType.navigationTile && trailing != null)
          DefaultTextStyle(
            style: TextStyle(
              color: theme.themeData.titleTextColor,
              fontSize: 17,
            ),
            child: trailing!,
          ),
        if (tileType == SettingsTileType.navigationTile)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, end: 2),
            child: IconTheme(
              data: IconTheme.of(context).copyWith(
                color: CupertinoColors.inactiveGray,
              ),
              child: Icon(CupertinoIcons.chevron_forward, size: 18),
            ),
          ),
      ],
    );
  }
}

class IOSSettingsTileAdditionalInfo extends InheritedWidget {
  final bool needToShowDivider;

  IOSSettingsTileAdditionalInfo({
    required this.needToShowDivider,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(IOSSettingsTileAdditionalInfo old) => true;

  static IOSSettingsTileAdditionalInfo of(BuildContext context) {
    final IOSSettingsTileAdditionalInfo? result = context
        .dependOnInheritedWidgetOfExactType<IOSSettingsTileAdditionalInfo>();
    assert(result != null, 'No IOSSettingsTileAdditionalInfo found in context');
    return result!;
  }
}
