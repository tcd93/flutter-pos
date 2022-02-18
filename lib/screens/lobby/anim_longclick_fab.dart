import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:super_tooltip/super_tooltip.dart';
import '../../theme/rally.dart';

const _targetTime = Duration(seconds: 2);

/// An extended version of [FloatingActionButton] that allows long press, fires a [onLongPress]
/// callback after 2s
///
/// Have a [CircularProgressIndicator] around showing progress
class AnimatedLongClickableFAB extends HookWidget {
  final ColorTween cTween = ColorTween(begin: RallyColors.gray, end: RallyColors.primaryColor);
  final VoidCallback onLongPress;

  AnimatedLongClickableFAB({required this.onLongPress});

  final tooltip = SuperTooltip(
    popupDirection: TooltipDirection.up,
    arrowTipDistance: 25.0,
    borderWidth: 1.0,
    backgroundColor: RallyColors.cardBackground,
    content: Builder(builder: (context) {
      return Material(
        child: Text(
          AppLocalizations.of(context)?.lobby_tooltip ?? '',
          softWrap: true,
        ),
      );
    }),
  );

  @override
  Widget build(BuildContext context) {
    useMemoized(() {
      WidgetsBinding.instance!.addPostFrameCallback((_) => tooltip.show(context));
    });

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
          backgroundColor: RallyColors.buttonColor,
          child: GestureDetector(
            onTapDown: (_) {
              t.value = Timer(_targetTime, onLongPress);
              valueController.forward();
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
