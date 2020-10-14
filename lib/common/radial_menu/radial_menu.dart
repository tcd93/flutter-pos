import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart' show radians;

import 'radial_button.dart';

class RadialMenu extends StatefulWidget {
  /// Builder for surrounding sub-buttons
  final List<RadialButton> Function(AnimationController, BuildContext) radialButtonsBuilder;

  /// Builder for center button (normal state)
  final Widget Function(AnimationController, BuildContext) mainButtonBuilder;

  /// Builder for center button (expanded state)
  final Widget Function(AnimationController, BuildContext) secondaryButtonBuilder;

  RadialMenu(
      {this.mainButtonBuilder, this.radialButtonsBuilder, this.secondaryButtonBuilder, Key key})
      : super(key: key);

  createState() => _RadialMenuState();
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
    // rotates by rotation value, also scales down in the process
    return SizedBox(
        width: 175,
        height: 175,
        child: AnimatedBuilder(
            animation: controller,
            builder: (context, widget) {
              return Transform.rotate(
                  angle: radians(rotation.value),
                  child: Stack(alignment: Alignment.center, children: <Widget>[
                    ...this.widget.radialButtonsBuilder(controller, context),
                    Transform.scale(
                      scale: scale.value - 1.0,
                      child: this.widget.secondaryButtonBuilder(controller, context),
                    ),
                    Transform.scale(
                      scale: scale.value,
                      child: this.widget.mainButtonBuilder(controller, context),
                    ),
                  ]));
            }));
  }
}
