import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart' show radians;

class DrawerItem extends StatelessWidget {
  final AnimationController controller;
  final double angle;
  final Widget child;

  final Animation<double> translation;

  DrawerItem({required this.controller, required this.angle, required this.child, Key? key})
      : translation = Tween<double>(begin: 0.0, end: 60.0).animate(
          CurvedAnimation(parent: controller, curve: Curves.elasticOut),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final rad = radians(angle);

    return Transform(
      transform: Matrix4.identity()
        ..translate(
          (translation.value) * cos(rad),
          (translation.value) * sin(rad),
        ),
      child: child,
    );
  }
}
