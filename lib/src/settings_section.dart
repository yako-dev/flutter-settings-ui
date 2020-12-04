import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/abstract_section.dart';
import 'package:settings_ui/src/cupertino_settings_section.dart';
import 'package:settings_ui/src/extensions.dart';
import 'package:settings_ui/src/settings_tile.dart';

import 'defines.dart';

// ignore: must_be_immutable
class SettingsSection extends AbstractSection {
  final List<SettingsTile> tiles;
  final TextStyle titleTextStyle;
  final int maxLines;
  final Widget subtitle;
  final EdgeInsetsGeometry subtitlePadding;

  SettingsSection({
    Key key,
    String title,
    EdgeInsetsGeometry titlePadding = defaultTitlePadding,
    this.maxLines,
    this.subtitle,
    this.subtitlePadding = defaultTitlePadding,
    this.tiles,
    this.titleTextStyle,
  })  : assert(titlePadding != null),
        assert(maxLines == null || maxLines > 0),
        super(key: key, title: title, titlePadding: titlePadding);

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform.isIOS(context)) {
      return iosSection();
    } else {
      return androidSection(context);
    }
  }

  Widget iosSection() {
    return CupertinoSettingsSection(
      tiles,
      header: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title,
              style: titleTextStyle,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          if (subtitle != null)
            Padding(
              padding: subtitlePadding,
              child: subtitle,
            ),
        ],
      ),
      headerPadding: titlePadding,
    );
  }

  Widget androidSection(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title != null)
        Padding(
          padding: titlePadding,
          child: Text(
            title,
            style: titleTextStyle ??
                TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold,
                ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      if (subtitle != null)
        Padding(
          padding: subtitlePadding,
          child: subtitle,
        ),
      ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: tiles.length,
        separatorBuilder: (BuildContext context, int index) =>
            Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          return tiles[index];
        },
      ),
      if (showBottomDivider) Divider(height: 1)
    ]);
  }
}
