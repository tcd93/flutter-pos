import 'dart:async';

import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../generated/l10n.dart';
import '../../theme/rally.dart';

const _targetTime = Duration(seconds: 2);

/// An extended version of [FloatingActionButton] that allows long press, fires a [onLongPress]
/// callback after 2s
///
/// Have a [CircularProgressIndicator] around showing progress
class AnimatedLongClickableFAB extends StatefulWidget {
  final VoidCallback onLongPress;

  const AnimatedLongClickableFAB({this.onLongPress});

  @override
  _AnimatedLongClickableFABState createState() => _AnimatedLongClickableFABState();
}

class _AnimatedLongClickableFABState extends State<AnimatedLongClickableFAB>
    with TickerProviderStateMixin {
  Timer t;
  AnimationController valueController, colorController;
  ColorTween cTween = ColorTween(begin: RallyColors.gray, end: RallyColors.primaryColor);
  final tooltip = SuperTooltip(
    popupDirection: TooltipDirection.up,
    arrowTipDistance: 25.0,
    borderWidth: 1.0,
    backgroundColor: RallyColors.cardBackground,
    content: Material(child: Text(S.current.lobby_tooltip, softWrap: true)),
  );

  _AnimatedLongClickableFABState() {
    valueController = AnimationController(
      duration: _targetTime,
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    colorController = AnimationController(duration: _targetTime, vsync: this);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => tooltip.show(context));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    valueController.dispose();
    colorController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: RallyColors.buttonColor,
          child: GestureDetector(
            onTapDown: (_) {
              t = Timer(_targetTime, widget.onLongPress);
              valueController.forward();
              colorController.forward();
            },
            onTapUp: (_) {
              if (t?.isActive ?? false) t.cancel();
              valueController.reset();
              colorController.reset();
            },
            onTapCancel: () {
              if (t?.isActive ?? false) t.cancel();
              valueController.reset();
              colorController.reset();
            },
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
