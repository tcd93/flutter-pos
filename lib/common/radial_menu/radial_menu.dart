import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart' show radians;

import 'radial_button.dart';

class RadialMenu extends StatefulWidget {
  /// Builder for surrounding sub-buttons
  final List<RadialButton> Function(BuildContext, AnimationController) radialButtonsBuilder;

  /// Builder for center button (normal state)
  final Widget Function(AnimationController, BuildContext) mainButtonBuilder;

  /// Builder for center button (expanded state)
  final Widget Function(AnimationController, BuildContext) secondaryButtonBuilder;

  RadialMenu(
      {this.mainButtonBuilder, this.radialButtonsBuilder, this.secondaryButtonBuilder, Key key})
      : super(key: key);

  _RadialMenuState createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> rotation;
  Animation<double> scale;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);

    scale = Tween<double>(
      begin: 1.5,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
    );

    rotation = Tween<double>(
      begin: 0.0,
      end: 360.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.0,
          0.7,
          curve: Curves.decelerate,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("== rebuilding _RadialMenuState... ==");
    // rotates by rotation value, also scales down in the process
    return Container(
        width: 175,
        height: 175,
        child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              // debugPrint("== rebuilding AnimatedBuilder of _RadialMenuState ... ==");

              return Transform.rotate(
                  angle: radians(rotation.value),
                  child: Stack(alignment: Alignment.center, children: <Widget>[
                    if (widget.radialButtonsBuilder != null)
                      ...widget.radialButtonsBuilder(context, controller),
                    if (widget.secondaryButtonBuilder != null)
                      Transform.scale(
                        scale: scale.value - 1.0,
                        child: widget.secondaryButtonBuilder(controller, context),
                      ),
                    if (widget.mainButtonBuilder != null)
                      Transform.scale(
                        scale: scale.value,
                        child: widget.mainButtonBuilder(controller, context),
                      ),
                  ]));
            }));
  }
}
