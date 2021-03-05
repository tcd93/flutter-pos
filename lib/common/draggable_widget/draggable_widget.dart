import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A draggable widget that can "snap" anywhere inside a screen, must be inside a Stack
/// as it uses [Position] widget
class DraggableWidget extends StatefulWidget {
  final Widget child;

  /// key of underlaying background container, so this draggable widget can find
  /// it's relative local position from
  final GlobalKey containerKey;

  /// initial x (top) pos of this widget on screen
  final double x;

  /// initial y (left) pos of this widget on screen
  final double y;

  /// the relative left, top to background container on drag end
  final void Function(double x, double y)? onDragEnd;

  DraggableWidget(
      {required this.child,
      this.x = 0,
      this.y = 0,
      required this.containerKey,
      this.onDragEnd,
      Key? key})
      : super(key: key);

  @override
  DraggableWidgetState createState() => DraggableWidgetState();
}

class DraggableWidgetState extends State<DraggableWidget> {
  late double top, left;

  @override
  void initState() {
    top = widget.x;
    left = widget.y;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundRenderBox =
        widget.containerKey.currentContext!.findRenderObject()! as RenderBox;
    return Positioned(
      top: top,
      left: left,
      child: Draggable(
        dragAnchor: DragAnchor.child,
        feedback: widget.child,
        child: widget.child,
        childWhenDragging: const SizedBox(),
        onDragEnd: (drag) {
          final localOffset = backgroundRenderBox.globalToLocal(drag.offset);
          setState(() {
            top = localOffset.dy;
            left = localOffset.dx;
          });
          widget.onDragEnd?.call(top, left);
        },
      ),
    );
  }
}
