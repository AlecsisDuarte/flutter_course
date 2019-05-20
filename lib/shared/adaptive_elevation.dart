import 'package:flutter/material.dart';

double getAdaptiveElevation(BuildContext context) =>
    Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0;
