import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import 'colors.dart';
import 'defines.dart';

class CupertinoSettingsSection extends StatelessWidget {
  const CupertinoSettingsSection(
    this.items, {
    this.header,
    this.headerPadding = defaultTitlePadding,
    this.footer,
  });

  final List<Widget> items;

  final Widget? header;
  final EdgeInsetsGeometry headerPadding;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final List<Widget> columnChildren = [];
    if (header != null) {
      columnChildren.add(DefaultTextStyle(
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w400,
          fontSize: 13.5,
          letterSpacing: -0.5,
        ),
        child: Padding(
          padding: headerPadding,
          child: header,
        ),
      ));
    }

    List<Widget> itemsWithDividers = [];
    for (int i = 0; i < items.length; i++) {
      if (i < items.length - 1) {
        var leftPadding = 0.0;
        if (items[i] is SettingsTile &&
            (i < items.length - 1 && (items[i + 1] is SettingsTile))) {
          leftPadding =
              (items[i] as SettingsTile).leading == null ? 15.0 : 54.0;
        }

        itemsWithDividers.add(items[i]);
        itemsWithDividers.add(Divider(
          height: 0.3,
          color: Colors.grey.shade400,
          indent: leftPadding,
        ));
      } else {
        itemsWithDividers.add(items[i]);
      }
    }

    bool largeScreen = MediaQuery.of(context).size.width >= 768 ? true : false;

    columnChildren.add(largeScreen
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Theme.of(context).brightness == Brightness.light
                  ? CupertinoColors.white
                  : iosTileDarkColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: itemsWithDividers,
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? CupertinoColors.white
                  : iosTileDarkColor,
              border: Border(
                top: const BorderSide(
                  color: borderColor,
                  width: 0.3,
                ),
                bottom: const BorderSide(
                  color: borderColor,
                  width: 0.3,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: itemsWithDividers,
            ),
          ));

    if (footer != null) {
      columnChildren.add(DefaultTextStyle(
        style: TextStyle(
          color: groupSubtitle,
          fontSize: 13.0,
          letterSpacing: -0.08,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 15.0,
            right: 15.0,
            top: 7.5,
          ),
          child: footer,
        ),
      ));
    }

    return Padding(
      padding: largeScreen
          ? EdgeInsets.only(
              top: header == null ? 35.0 : 22.0, left: 22, right: 22)
          : EdgeInsets.only(
              top: header == null ? 35.0 : 22.0,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );
  }
}
