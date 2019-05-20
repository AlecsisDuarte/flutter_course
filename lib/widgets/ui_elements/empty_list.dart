import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  final String message;

  EmptyList({this.message = 'No food found, add something'});

  @override
  Widget build(BuildContext context) => ListView(
        padding: EdgeInsets.all(20.0),
        shrinkWrap: true,
        children: <Widget>[
          Image.asset(
            'assets/silent_tears.gif',
            height: 100.0,
            width: 100.0,
          ),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
        ],
      );
}
