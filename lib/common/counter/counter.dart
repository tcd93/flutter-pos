import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

@immutable
class Counter extends StatelessWidget {
  final Key key;
  final textEditingController = TextEditingController(text: '0');
  final void Function(int currentValue) onIncrement;
  final void Function(int currentValue) onDecrement;

  Counter({this.onIncrement, this.onDecrement, this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 200,
      height: 80,
      color: Colors.black12,
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 6),
            FloatingActionButton(
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
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                  controller: textEditingController,
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  decoration:
                      InputDecoration(border: const OutlineInputBorder()),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
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
          ],
        ),
      ),
    );
  }
}
