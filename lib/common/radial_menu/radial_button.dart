import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart' show radians;

class RadialButton extends StatelessWidget {
  final AnimationController controller;
  final double angle, elevation;
  final Color color;
  final IconData icon;
  final Function onPressed;

  final Animation<double> translation;

  RadialButton(this.controller, this.angle, this.onPressed,
      {this.color = Colors.green, this.icon, this.elevation = 0, Key key})
      : translation = Tween<double>(
          begin: 0.0,
          end: 60.0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.elasticOut),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final double rad = radians(angle);

    return Transform(
        transform: Matrix4.identity()
          ..translate(
              (translation.value) * cos(rad), (translation.value) * sin(rad)),
        child: FloatingActionButton(
            onPressed: onPressed,
            child: Icon(icon),
            backgroundColor: color,
            elevation: elevation));
  }
}
