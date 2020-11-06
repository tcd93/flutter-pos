import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const double height = 100.0;

@immutable
class Counter extends StatefulWidget {
  final _memoizer = AsyncMemoizer();
  final int startingValue;
  final String imagePath;
  final String subtitle;
  final TextEditingController textEditingController;
  final void Function(int currentValue) onIncrement;
  final void Function(int currentValue) onDecrement;

  Counter(
    this.startingValue, {
    this.onIncrement,
    this.onDecrement,
    this.imagePath,
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

  @override
  Widget build(BuildContext context) {
    var value = int.tryParse(widget.textEditingController.text);

    return AnimatedBuilder(
      animation: animController,
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
            const VerticalDivider(
              thickness: 1,
              indent: 2,
              endIndent: 2,
            ),
            Expanded(
              child: FittedBox(
                child: FloatingActionButton(
                  // decrease
                  heroTag: null,
                  child: Icon(FontAwesomeIcons.minusCircle),
                  onPressed: () {
                    // animate to "start" color when back to 0
                    if (value == 1) animController.reverse();

                    if (value == null || value <= 0) return;

                    value--;
                    widget.textEditingController.text = (value).toString();
                    widget.onDecrement?.call(value);
                  },
                ),
              ),
            ),
            Expanded(
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
                  child: Icon(FontAwesomeIcons.plusCircle),
                  onPressed: () {
                    // animate to "end" color when starting from 0
                    if (value == 0) animController.forward();

                    value++;
                    widget.textEditingController.text = (value).toString();
                    widget.onIncrement?.call(value);
                  },
                ),
              ),
            ),
            const VerticalDivider(
              thickness: 1,
              indent: 2,
              endIndent: 2,
            ),
          ],
        ),
      ),
      builder: (context, cardContent) {
        if (widget.startingValue != 0) {
          widget._memoizer.runOnce(() {
            animController.forward();
          });
        }

        final colorTween = ColorTween(
          begin: Theme.of(context).cardColor, // disabled color
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
                elevation: 2.0,
                child: cardContent,
              ),
            ),
            if (widget.imagePath != null)
              DecoratedBox(
                decoration: ShapeDecoration(
                  shape: CircleBorder(),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(widget.imagePath),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Theme.of(context).primaryColorLight,
                      blurRadius: animController.value * 6,
                      spreadRadius: animController.value * 9,
                    ),
                  ],
                ),
                // empty box to contain the decoration image
                child: SizedBox(
                  height: height,
                  width: height,
                ),
              ),
          ],
        );
      },
    );
  }
}
