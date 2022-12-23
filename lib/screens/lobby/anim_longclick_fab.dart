import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../theme/rally.dart';

const _targetTime = Duration(milliseconds: 600);

/// An extended version of [FloatingActionButton] that allows long press, fires a [onLongPress]
/// callback after 2s
///
/// Have a [CircularProgressIndicator] around showing progress
class AnimatedLongClickableFAB extends HookWidget {
  final ColorTween cTween = ColorTween(begin: RallyColors.gray, end: RallyColors.primaryColor);
  final VoidCallback onLongPress;

  AnimatedLongClickableFAB({required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    // controllers
    final valueController = useAnimationController(duration: _targetTime);
    final colorController = useAnimationController(duration: _targetTime);
    // states
    final t = useState<Timer?>(null);

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: AnimatedBuilder(
            animation: valueController,
            builder: (_, __) {
              return CircularProgressIndicator(
                strokeWidth: 4.0,
                value: valueController.value,
                valueColor: colorController.drive(cTween),
              );
            },
          ),
        ),
        // must be last to receive tap events
        FloatingActionButton(
          onPressed: () {}, // ignore, let [GestureDetector] take care of this
          child: GestureDetector(
            onTapDown: (_) {
              t.value = Timer(_targetTime, onLongPress);
              valueController.animateTo(1.0, curve: Curves.decelerate);
              colorController.forward();
            },
            onTapUp: (_) {
              if (t.value != null && t.value!.isActive) t.value!.cancel();
              valueController.reset();
              colorController.reset();
            },
            onTapCancel: () {
              if (t.value != null && t.value!.isActive) t.value!.cancel();
              valueController.reset();
              colorController.reset();
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
