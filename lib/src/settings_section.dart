import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:settings_ui/src/abstract_section.dart';
import 'package:settings_ui/src/cupertino_settings_section.dart';
import 'package:settings_ui/src/settings_tile.dart';
import 'package:settings_ui/src/extensions.dart';

// ignore: must_be_immutable
class SettingsSection extends AbstractSection {
  final List<SettingsTile> tiles;
  final TextStyle titleTextStyle;

  SettingsSection({
    Key key,
    String title,
    this.tiles,
    this.titleTextStyle,
  }) : super(key: key, title: title);

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform.isIOS)
      return iosSection();
    else if (platform.isAndroid)
      return androidSection(context);
    else
      return androidSection(context);
  }

  Widget iosSection() {
    return CupertinoSettingsSection(
      tiles,
      header: title == null ? null : Text(title, style: titleTextStyle),
    );
  }

  Widget androidSection(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      title == null
          ? Container()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: titleTextStyle ??
                    TextStyle(
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
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
