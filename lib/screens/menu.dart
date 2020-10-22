import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../common/counter/counter.dart';

class MenuScreen extends StatelessWidget {
  final String fromHeroTag;

  MenuScreen({this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu', style: Theme.of(context).textTheme.headline1),
      ),
      body: Counter(
        onIncrement: (currentValue) {
          debugPrint(currentValue.toString());
          return;
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: fromHeroTag,
        child: Icon(FontAwesomeIcons.plusSquare),
        onPressed: null,
      ),
    );
  }
}
