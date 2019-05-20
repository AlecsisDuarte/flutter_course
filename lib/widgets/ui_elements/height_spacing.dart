import 'package:flutter/material.dart';

class HeightSpacing extends StatelessWidget {
  final double height;

  HeightSpacing({this.height = 10.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}
