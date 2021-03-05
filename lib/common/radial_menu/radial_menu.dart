import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart' show radians;

class RadialMenu extends StatefulWidget {
  final double width;
  final double height;

  /// Builder for surrounding sub-buttons
  final List<Widget> Function(BuildContext, AnimationController)? drawerBuilder;

  /// Builder for center button (normal state)
  final Widget Function(AnimationController, BuildContext)? closedBuilder;

  /// Builder for center button (expanded state)
  final Widget Function(AnimationController, BuildContext)? openBuilder;

  final double beginScale, endScale;

  /// An animation controller would be create by default, but user can use their own too
  final Animation? animationController;

  /// Duration of animation, default 500ms; if [animationController] is passed, then this is ignored
  final Duration duration;

  RadialMenu({
    this.closedBuilder,
    this.drawerBuilder,
    this.openBuilder,
    this.width = 175.0,
    this.height = 175.0,
    this.beginScale = 1.3,
    this.endScale = 1.0,
    this.animationController,
    this.duration = const Duration(milliseconds: 500),
    Key? key,
  }) : super(key: key);

  @override
  _RadialMenuState createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> rotation;
  late final Animation<double> downScale, upScale;

  @override
  void initState() {
    super.initState();

    controller = (widget.animationController ??
        AnimationController(duration: widget.duration, vsync: this)) as AnimationController;

    downScale = Tween<double>(begin: widget.beginScale, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
    );
    upScale = Tween<double>(begin: 0.0, end: widget.endScale).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInBack),
    );

    rotation = Tween<double>(begin: 0.0, end: 360.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.7, curve: Curves.decelerate),
      ),
    );
  }

  @override
  void dispose() {
    // if the animation is handed from parent then let them dispose it
    if (widget.animationController == null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  // rotates by rotation value, also scales down in the process
  Widget build(BuildContext context) => Container(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          // copy to local var to enable type promotion
          final drawerBuilder = widget.drawerBuilder;
          final openBuilder = widget.openBuilder;
          final closedBuilder = widget.closedBuilder;

          return Transform.rotate(
            angle: radians(rotation.value),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                if (drawerBuilder != null) ...drawerBuilder(context, controller),
                if (openBuilder != null)
                  Transform.scale(
                    scale: upScale.value,
                    child: openBuilder(controller, context),
                  ),
                if (closedBuilder != null)
                  Transform.scale(
                    scale: downScale.value,
                    child: closedBuilder(controller, context),
                  ),
              ],
            ),
          );
        },
      ));
}
