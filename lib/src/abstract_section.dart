import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
abstract class AbstractSection extends StatelessWidget {
  bool showBottomDivider = false;
  final String? title;
  final Widget? titleWidget;
  final EdgeInsetsGeometry? titlePadding;

  AbstractSection({
    Key? key,
    this.title,
    this.titleWidget,
    this.titlePadding,
  }) : super(key: key);
}
