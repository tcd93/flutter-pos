import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:flutter/material.dart';

const double height = 85.0;

@immutable
class Counter extends StatefulWidget {
  final _memoizer = AsyncMemoizer();
  final int startingValue;
  final Uint8List imageData;
  final String subtitle;
  final TextEditingController textEditingController;
  final void Function(int currentValue) onIncrement;
  final void Function(int currentValue) onDecrement;

  Counter(
    this.startingValue, {
    this.onIncrement,
    this.onDecrement,
    this.imageData,
    this.subtitle,
    Key key,
  })  : textEditingController = TextEditingController(
          text: startingValue.toString(),
        ),
        super(key: key);

  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> with SingleTickerProviderStateMixin {
  AnimationController animController;

  _CounterState() {
    animController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  int add(AnimationController animController, int value) {
    if (value == 0) animController.forward();

    value++;
    widget.textEditingController.text = (value).toString();
    widget.onIncrement?.call(value);
    return value;
  }

  int sub(AnimationController animationController, int value) {
    // animate to "start" color when back to 0
    if (value == 1) animController.reverse();

    if (value == null || value <= 0) return 0;

    value--;
    widget.textEditingController.text = (value).toString();
    widget.onDecrement?.call(value);
    return value;
  }

  @override
  Widget build(BuildContext context) {
    var value = int.tryParse(widget.textEditingController.text);

    return AnimatedBuilder(
      animation: animController,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => value = add(animController, value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Spacer(),
              if (widget.subtitle != null)
                Expanded(
                  flex: 7,
                  child: Text(
                    widget.subtitle,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle2,
                    softWrap: true,
                    maxLines: 2,
                  ),
                ),
              Expanded(
                child: FittedBox(
                  child: FloatingActionButton(
                    // decrease
                    heroTag: null,
                    child: Icon(Icons.remove),
                    onPressed: () => value = sub(animController, value),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: widget.textEditingController,
                  enabled: false,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              Expanded(
                child: FittedBox(
                  child: FloatingActionButton(
                    // increase
                    heroTag: null,
                    child: Icon(Icons.add),
                    onPressed: () => value = add(animController, value),
                  ),
                ),
              ),
              const SizedBox(width: 2.0),
            ],
          ),
        ),
      ),
      builder: (context, cardContent) {
        if (widget.startingValue != 0) {
          widget._memoizer.runOnce(() {
            animController.forward();
          });
        }

        final colorTween = ColorTween(
          begin: Theme.of(context).cardTheme.color, // disabled color
          end: Theme.of(context).primaryColorLight, // hightlight if > 0
        );

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: height - 20.0,
              child: Card(
                margin: const EdgeInsets.only(left: height - 20),
                color: colorTween.animate(animController).value,
                child: cardContent,
              ),
            ),
            if (widget.imageData != null)
              Container(
                height: height,
                decoration: ShapeDecoration(
                  shape: CircleBorder(),
                  shadows: [
                    BoxShadow(
                      color: Theme.of(context).primaryColorLight,
                      blurRadius: animController.value * 6,
                      spreadRadius: animController.value * 9,
                    ),
                  ],
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.3,
                  child: Image.memory(widget.imageData),
                ),
                clipBehavior: Clip.hardEdge, // clip to circle avatar
              ),
          ],
        );
      },
    );
  }
}
