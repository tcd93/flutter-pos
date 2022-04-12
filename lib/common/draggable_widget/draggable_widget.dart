import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// A draggable widget that can "snap" anywhere inside a screen, must be inside a Stack
/// as it uses [Position] widget
class DraggableWidget extends StatefulWidget {
  final Widget child;

  /// initial x (top) pos of this widget on screen
  final double x;

  /// initial y (left) pos of this widget on screen
  final double y;

  /// the relative left, top to background container on drag end
  final void Function(double x, double y)? onDragEnd;

  /// key of underlaying background container, so this draggable widget can find
  /// it's relative local position from
  final GlobalKey containerKey;

  /// Correctly scale feedback object when using this in a scaled view
  final TransformationController? transformController;

  const DraggableWidget({
    required this.child,
    this.x = 0,
    this.y = 0,
    required this.containerKey,
    this.onDragEnd,
    this.transformController,
    Key? key,
  }) : super(key: key);

  @override
  DraggableWidgetState createState() => DraggableWidgetState();
}

class DraggableWidgetState extends State<DraggableWidget> {
  late double top, left;
  late Size normalSize; // size of this widget, independent of Scale
  final key = GlobalKey<DraggableWidgetState>();

  @override
  void initState() {
    top = widget.y;
    left = widget.x;
    WidgetsBinding.instance!.addPostFrameCallback((_) => getSize());
    super.initState();
  }

  void getSize() {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject != null) {
      final box = renderObject as RenderBox;
      normalSize = box.size;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundRenderBox =
        widget.containerKey.currentContext!.findRenderObject()! as RenderBox;
    return Positioned(
      top: top,
      left: left,
      key: key,
      child: Draggable(
        dragAnchorStrategy: childDragAnchorStrategy,
        feedback: _ScalableFeedbackWidget(
          transformController: widget.transformController,
          child: widget.child,
        ),
        childWhenDragging: const SizedBox(),
        onDragEnd: (drag) {
          // just like the feedback, the drag detail is based on the "pre-scaled" widget
          // we need to translate the offset back to appropriate value to
          // prevent a "snap" effect which the child is not placed exactly on the dropped position
          var scale = widget.transformController?.value.getMaxScaleOnAxis() ?? 1.0;
          final localOffset = backgroundRenderBox.globalToLocal(drag.offset.translate(
            -(normalSize.width / 2) * (scale - 1.0),
            -(normalSize.height / 2) * (scale - 1.0),
          ));
          setState(() {
            top = localOffset.dy;
            left = localOffset.dx;
          });
          widget.onDragEnd?.call(left, top);
        },
        child: widget.child,
      ),
    );
  }
}

/// Scale the feedback widget up to the same display size as the dragged widget
class _ScalableFeedbackWidget extends StatelessWidget {
  final TransformationController? transformController;

  final Widget child;

  const _ScalableFeedbackWidget({
    Key? key,
    required this.child,
    this.transformController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var scale = transformController?.value.getMaxScaleOnAxis() ?? 1.0;
    return Transform.scale(
      scale: scale,
      child: child,
    );
  }
}
