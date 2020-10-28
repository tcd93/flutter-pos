import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const double height = 100.0;

@immutable
class Counter extends StatelessWidget {
  final String imagePath;
  final String subtitle;
  final TextEditingController textEditingController;
  final void Function(int currentValue) onIncrement;
  final void Function(int currentValue) onDecrement;

  Counter(
    int startingValue, {
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
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 14,
        ),
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Container(
              height: height - 20.0,
              child: Card(
                margin: const EdgeInsets.only(left: height - 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                borderOnForeground: false,
                color: Color.fromARGB(75, 192, 192, 192), // silver
                elevation: 6.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24.0),
                    if (subtitle != null)
                      Expanded(
                        child: Text(
                          subtitle,
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
                        var value = int.tryParse(textEditingController.text);
                        if (value == null || value <= 0) return;

                        value--;
                        textEditingController.text = (value).toString();
                        onDecrement?.call(value);
                      },
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 60.0,
                      // text box
                      child: TextField(
                        controller: textEditingController,
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
            ),
            if (imagePath != null)
              Material(
                shape: CircleBorder(),
                elevation: 20.0,
                child: SizedBox(
                  height: height,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      );
}
