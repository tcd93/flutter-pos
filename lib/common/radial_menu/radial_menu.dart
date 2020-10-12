import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hembo/common/radial_menu/radial_button.dart';
import 'package:vector_math/vector_math.dart' show radians;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RadialMenu extends StatefulWidget {
  final List<RadialButton> Function(AnimationController controller)
      buttonsBuilder;

  /// `event`: "onOpen" | "onClose"
  final void Function({String event}) onPressed;

  RadialMenu({this.onPressed, this.buttonsBuilder});

  createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
      width: 175,
      height: 175,
      child: _RadialAnimation(controller,
          onPressed: this.widget.onPressed,
          buttonsBuilder: this.widget.buttonsBuilder));
}

class _RadialAnimation extends StatelessWidget {
  final void Function({String event}) onPressed;
  final List<RadialButton> Function(AnimationController controller)
      buttonsBuilder;

  final AnimationController controller;
  final Animation<double> rotation;
  final Animation<double> scale;

  _RadialAnimation(this.controller,
      {this.onPressed, this.buttonsBuilder, Key key})
      : scale = Tween<double>(
          begin: 1.5,
          end: 0.0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
        ),
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
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("rebuilding _RadialAnimation...");
    // rotates by rotation value, also scales down in the process
    return AnimatedBuilder(
        animation: controller,
        builder: (context, widget) {
          return Transform.rotate(
              angle: radians(rotation.value),
              child: Stack(alignment: Alignment.center, children: <Widget>[
                ...buttonsBuilder(controller),

                //TODO: extract these to stateless widgets (to inject Color attribute)

                Transform.scale(
                  // transform to red when pressed
                  scale: scale.value - 1.0,
                  child: FloatingActionButton(
                      child: Icon(FontAwesomeIcons.timesCircle),
                      onPressed: _close,
                      backgroundColor: Colors.red),
                ),
                Transform.scale(
                  // default state is green
                  scale: scale.value,
                  child: FloatingActionButton(
                    child: Icon(FontAwesomeIcons.solidDotCircle),
                    onPressed: _open,
                    backgroundColor: Colors.green,
                  ),
                )
              ]));
        });
  }

  _open() {
    controller.forward();
    this.onPressed(event: "onOpen");
  }

  _close() {
    controller.reverse();
    this.onPressed(event: "onClose");
  }
}
