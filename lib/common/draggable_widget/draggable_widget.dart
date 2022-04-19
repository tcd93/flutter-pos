import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// A draggable widget that can "snap" anywhere inside a screen, must be inside a Stack
/// as it uses [Position] widget
class DraggableWidget extends StatefulWidget {
  final Widget child;

  /// initial x (left) pos of this widget on screen
  final double x;

  /// initial y (top) pos of this widget on screen
  final double y;

  /// the relative left, top to background container on drag end
  final void Function(double x, double y)? onDragEnd;

  const DraggableWidget({
    required this.child,
    this.x = 0,
    this.y = 0,
    this.onDragEnd,
    Key? key,
  }) : super(key: key);

  @override
  DraggableWidgetState createState() => DraggableWidgetState();
}

class DraggableWidgetState extends State<DraggableWidget> {
  late double top, left;
  final key = GlobalKey<DraggableWidgetState>();

  @override
  void initState() {
    super.initState();
    top = widget.y;
    left = widget.x;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      key: key,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() {
          top += details.delta.dy;
          left += details.delta.dx;
        }),
        onPanEnd: (_) {
          widget.onDragEnd?.call(left, top);
        },
        child: widget.child,
      ),
    );
  }
}
