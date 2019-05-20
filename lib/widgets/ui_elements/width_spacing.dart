import 'package:flutter/material.dart';

class WidthSpacing extends StatelessWidget {
  final double width;

  WidthSpacing({this.width = 8.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
    );
  }
}
