import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

@immutable
class Counter extends StatelessWidget {
  final String imagePath;
  final String subtitle;
  final TextEditingController textEditingController;
  final void Function(int currentValue) onIncrement;
  final void Function(int currentValue) onDecrement;

  Counter(int startingValue,
      {this.onIncrement,
      this.onDecrement,
      this.imagePath,
      this.subtitle,
      Key key})
      : textEditingController =
            TextEditingController(text: startingValue.toString()),
        super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        // width: 200,
        height: 100,
        color: Colors.black12,
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 6),
              if (imagePath != null)
                SizedBox(
                  height: 95,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              if (subtitle != null)
                Expanded(
                  child: Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
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
                  var value = int.tryParse(textEditingController.text);
                  if (value == null || value <= 0) return;

                  value--;
                  textEditingController.text = (value).toString();
                  onDecrement?.call(value);
                },
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 60,
                // text box
                child: TextField(
                    controller: textEditingController,
                    enabled: false,
                    keyboardType:
                        const TextInputType.numberWithOptions(signed: true),
                    decoration:
                        InputDecoration(border: const OutlineInputBorder()),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(width: 6),
              FloatingActionButton(
                // increase
                heroTag: null,
                child: Icon(FontAwesomeIcons.plusCircle),
                onPressed: () {
                  var value = int.tryParse(textEditingController.text);
                  if (value == null || value < 0) return;

                  value++;
                  textEditingController.text = (value).toString();
                  onIncrement?.call(value);
                },
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      );
}
