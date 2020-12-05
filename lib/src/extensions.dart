import 'package:flutter/material.dart';

extension TargetExtensions on TargetPlatform {
  bool isIOS(BuildContext context) =>
      Theme.of(context).platform == TargetPlatform.iOS;
  bool isAndroid(BuildContext context) =>
      Theme.of(context).platform == TargetPlatform.android;
}
