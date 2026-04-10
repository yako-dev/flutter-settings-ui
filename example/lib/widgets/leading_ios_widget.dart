import 'package:flutter/cupertino.dart';

class LeadingIosWidget extends StatelessWidget {
  final Color backgroundColor;
  final Color iconColor;
  final IconData iconData;

  const LeadingIosWidget({
    super.key,
    required this.backgroundColor,
    required this.iconColor,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(7)),
      ),
      child: Icon(
        iconData,
        color: iconColor,
      ),
    );
  }
}
