import 'package:flutter/material.dart';

final ThemeData androidTheme = ThemeData(
  primarySwatch: Colors.deepPurple,
  primaryColor: Colors.purple,
  brightness: Brightness.light,
  buttonColor: Colors.deepPurple,
);

final ThemeData iosTheme = ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: Colors.blueGrey,
  brightness: Brightness.light,
  buttonColor: Colors.lightBlueAccent,
);

ThemeData getAdaptiveThemeData(context) {
  final TargetPlatform platform = Theme.of(context).platform;
  return platform == TargetPlatform.iOS ? iosTheme : androidTheme;
}
