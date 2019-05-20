import 'package:flutter/material.dart';
import 'package:flutter_course/widgets/ui_elements/adaptive_progress_indicator.dart';

class PageLoading extends StatelessWidget {
  final String message;

  PageLoading({this.message = 'Loading the munchies'});

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AdaptiveProgressIndicator(),
          Text(message),
        ],
      ),
    );
  
}