import 'package:flutter/material.dart';
import 'package:settings_ui/src/abstract_section.dart';

// ignore: must_be_immutable
class CustomSection extends AbstractSection {
  final Widget child;

  CustomSection({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
