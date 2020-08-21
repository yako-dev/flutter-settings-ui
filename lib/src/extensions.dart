import 'package:flutter/material.dart';

extension TargetExtensions on TargetPlatform {
  bool get isIOS => this == TargetPlatform.iOS;
  bool get isAndroid => this == TargetPlatform.android;
}
