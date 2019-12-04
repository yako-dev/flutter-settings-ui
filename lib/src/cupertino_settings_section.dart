import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import 'colors.dart';

class CupertinoSettingsSection extends StatelessWidget {
  const CupertinoSettingsSection(
    this.items, {
    this.header,
    this.footer,
  }) : assert(items != null);

  final List<Widget> items;

  final Widget header;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    List<Widget> dividedItems = items;
    if (items.length > 1) {
      dividedItems = dividedItems.map<Widget>((Widget item) {
        if (dividedItems.last == item) {
          return item;
        } else {
          final leftPadding =
              (item as SettingsTile).leading == null ? 15.0 : 54.0;

//          return Column(
//            children: <Widget>[
//              item,
//              // Add inner dividers.
//              Row(
//                children: <Widget>[
//                  Container(
//                    width: leftPadding,
//                    height: 0.3,
//                    color: Theme.of(context).brightness == Brightness.light
//                        ? Colors.white
//                        : Colors.black,
//                  ),
//                  Container(
//                    height: 0.3,
//                    color: Theme.of(context).brightness == Brightness.light
//                        ? borderColor
//                        : borderLightColor,
//                  ),
//                ],
//              ),
//            ],
//          );
          return Stack(
            children: <Widget>[
              Positioned(
                bottom: 1.0,
                right: 0.0,
                left: leftPadding,
                child: new Container(
                  color: Colors.white,
                  height: 1,
                ),
              ),
              item,
            ],
          );
        }
      }).toList();
    }

    final List<Widget> columnChildren = [];

    if (header != null) {
      columnChildren.add(DefaultTextStyle(
        style: TextStyle(
          color: CupertinoColors.inactiveGray,
          fontSize: 13.5,
          letterSpacing: -0.5,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 15.0,
            right: 15.0,
            bottom: 6.0,
          ),
          child: header,
        ),
      ));
    }

    columnChildren.add(
      Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          border: Border(
            top: const BorderSide(
              color: borderColor,
              width: 0.0,
            ),
            bottom: const BorderSide(
              color: borderColor,
              width: 0.0,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: dividedItems,
        ),
      ),
    );

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
      padding: EdgeInsets.only(
        top: header == null ? 35.0 : 22.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );
  }
}
