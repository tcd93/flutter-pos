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
    animController = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var value = int.tryParse(widget.textEditingController.text);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 14,
      ),
      child: AnimatedBuilder(
        animation: animController,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 24.0),
            if (widget.subtitle != null)
              Expanded(
                child: Text(
                  widget.subtitle,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
            const SizedBox(width: 6),
            FloatingActionButton(
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
            const SizedBox(width: 6),
            SizedBox(
              width: 60.0,
              child: TextField(
                controller: widget.textEditingController,
                enabled: false,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            const SizedBox(width: 6),
            FloatingActionButton(
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
            const SizedBox(width: 6),
          ],
        ),
        builder: (context, childWidget) {
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
                  margin: const EdgeInsets.only(left: height - 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  borderOnForeground: false,
                  color: colorTween.animate(animController).value,
                  elevation: 2.0,
                  child: childWidget,
                ),
              ),
              if (widget.imagePath != null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColorLight,
                        blurRadius: animController.value * 6,
                        spreadRadius: animController.value * 9,
                      ),
                    ],
                  ),
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: Colors.black12,
                        width: 1.5,
                      ),
                    ),
                    elevation: 2.0,
                    borderOnForeground: false,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                      height: height, // have to specify both width & height
                      width: height, // to properly align
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
