import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Counter extends StatelessWidget {
  final textEditingController = TextEditingController(text: '0');

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
            SizedBox(width: 6),
            FloatingActionButton(
              heroTag: '1', //TODO as parameter
              child: Icon(FontAwesomeIcons.plusCircle),
              onPressed: () {
                //TODO: increment/decrement this value
                textEditingController.text = (int.parse(textEditingController.text) + 1).toString();
                debugPrint("Typed ${textEditingController.text}");
              },
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                  controller: textEditingController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(border: const OutlineInputBorder()),
                  textAlign: TextAlign.center),
            ),
            SizedBox(width: 8),
            FloatingActionButton(
              heroTag: '2',
              child: Icon(FontAwesomeIcons.minusCircle),
              onPressed: () {},
            ),
            SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
