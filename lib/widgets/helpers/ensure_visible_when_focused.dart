import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class EnsureVisibleWhenFocused extends StatefulWidget {
  const EnsureVisibleWhenFocused(
      {Key key,
      @required this.child,
      @required this.focusNode,
      this.curve: Curves.ease,
      this.duration: const Duration(milliseconds: 100)})
      : super(key: key);

  /// The [FocusNode] we will monitor to determine if the child is focused
  final FocusNode focusNode;

  /// The child [Widget] that we are wrapping
  final Widget child;

  ///  The [Curve] we will use to scroll ourselves into view
  /// Defaults to [Curves.ease]
  final Curve curve;

  /// The [Duration] we will use to scroll ourselves into view
  /// Defaults to __100 milliseconds__
  final Duration duration;

  @override
  State<StatefulWidget> createState() => EnsureVisibleWhenFocusedState();
}

class EnsureVisibleWhenFocusedState extends State<EnsureVisibleWhenFocused> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_ensureVisible);
  }

  @override
  void dispose() {
    super.dispose();
    widget.focusNode.removeListener(_ensureVisible);
  }

  Future<Null> _ensureVisible() async {
    // Wait for the keyboard to come into view
    // position doesn't seem to notify listeners when metrics change,
    // perhaps a [NotificationListener] around the scrollable could avoid
    // the need to insert a delay here.
    await Future.delayed(const Duration(milliseconds: 300));

    if (!widget.focusNode.hasFocus) {
      return;
    }

    final RenderObject object = context.findRenderObject();
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(object);
    assert(viewport != null);

    ScrollableState scrollableState = Scrollable.of(context);
    assert(scrollableState != null);

    ScrollPosition position = scrollableState.position;
    double alignment;
    if (position.pixels > viewport.getOffsetToReveal(object, 0.0).offset) {
      alignment = 0.0;
    } else if (position.pixels <
        viewport.getOffsetToReveal(object, 1.0).offset) {
      alignment = 1.0;
    } else {
      // No scrolling is necesary to reveal the child
      return;
    }

    position.ensureVisible(
      object,
      alignment: alignment,
      duration: widget.duration,
      curve: widget.curve
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
