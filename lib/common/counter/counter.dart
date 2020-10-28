import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const double height = 100.0;

@immutable
class Counter extends StatefulWidget {
  final String imagePath;
  final String subtitle;
  final TextEditingController textEditingController;
  final void Function(int currentValue) onIncrement;
  final void Function(int currentValue) onDecrement;

  /// Creates a smooth color transition effect when adding / decreasing counter
  final ColorTween colorTween;

  Counter(
    int startingValue, {
    this.onIncrement,
    this.onDecrement,
    this.imagePath,
    this.subtitle,
    this.colorTween,
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
    animController =
        AnimationController(duration: Duration(milliseconds: 750), vsync: this);
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
        builder: (context, child) => Stack(
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
                color: widget.colorTween?.animate(animController)?.value ??
                    Color.fromRGBO(192, 192, 192, 0.75),
                elevation: 6.0,
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
                        if (value > 0) animController.reverse();

                        if (value == null || value <= 0) return;

                        value--;
                        widget.textEditingController.text = (value).toString();
                        widget.onDecrement?.call(value);
                      },
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 60.0,
                      // text box
                      child: TextField(
                        controller: widget.textEditingController,
                        enabled: false,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                        ),
                        textAlign: TextAlign.center,
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
              ),
            ),
            if (widget.imagePath != null)
              Material(
                shape: CircleBorder(
                  side: BorderSide(
                    width: 1.5,
                    color: widget.colorTween?.animate(animController)?.value ??
                        Color.fromRGBO(192, 192, 192, 0.75),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                elevation: 20.0,
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  height: height,
                  width: height,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
