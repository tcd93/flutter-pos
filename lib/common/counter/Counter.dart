import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Counter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ButtonBar(
        alignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            heroTag: '1', //TODO as parameter
            child: Icon(FontAwesomeIcons.arrowCircleLeft),
            onPressed: () {},
          ),
          FloatingActionButton(
            heroTag: '2',
            child: Icon(FontAwesomeIcons.arrowCircleRight),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
