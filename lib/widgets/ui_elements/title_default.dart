import 'package:flutter/material.dart';

class TitleDefault extends StatelessWidget {
  final String text;

  TitleDefault(this.text);

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Text(
      text,
      textAlign: TextAlign.center,
      softWrap: true,
      style: TextStyle(
        fontSize: deviceWidth > 400 ? 26.0 : 14.0,
        fontWeight: FontWeight.bold,
        fontFamily: 'BioRhyme',
      ),
    );
  }
}
