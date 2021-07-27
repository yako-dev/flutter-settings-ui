import 'package:flutter/cupertino.dart';

/// This slider object defines the values for both the material `Slider` and
/// the iOS `CupertinoSlider`.
class SettingsSlider {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final Color? activeColor;
  final Color? thumbColor;

  SettingsSlider(
      {required this.value,
      required this.onChanged,
      this.onChangeStart,
      this.onChangeEnd,
      this.min = 0.0,
      this.max = 1.0,
      this.divisions,
      this.activeColor,
      this.thumbColor});
}
