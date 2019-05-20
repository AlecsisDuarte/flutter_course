import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

import '../../models/product.dart';
import 'package:flutter_course/scoped_models/main_model.dart';

class ProductFAB extends StatefulWidget {
  final Product product;

  ProductFAB(this.product);

  @override
  State<StatefulWidget> createState() {
    return _ProductFABState();
  }
}

class _ProductFABState extends State<ProductFAB> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Container(
            //   child: FloatingActionButton(
            //     mini: true,
            //     onPressed: () {},
            //     child: Icon(Icons.more_vert),
            //   ),
            // ),
            Container(
              alignment: FractionalOffset.topCenter,
              width: 54.0,
              height: 68.0,
              child: SlideTransition(
                position: _controller.drive(
                  Tween<Offset>(
                    begin: Offset(0, 1.5),
                    end: Offset(0, 0),
                  ).chain(
                    CurveTween(
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
                child: ScaleTransition(
                  scale: CurvedAnimation(
                      parent: _controller,
                      curve: Interval(0.0, 1.0, curve: Curves.easeOut)),
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Theme.of(context).primaryColor,
                    heroTag: 'contact',
                    mini: true,
                    onPressed: () async {
                      final String email = widget.product.userEmail;
                      final url = 'mailto:$email';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Couldn\'t email to $email';
                      }
                    },
                    child: Icon(Icons.mail),
                  ),
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: 'options',
              onPressed: () {
                if (_controller.isDismissed) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget widget) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationZ(_controller.value * 0.5 * pi),
                    child: Icon(_controller.isDismissed
                        ? Icons.more_vert
                        : Icons.close),
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }
}
