import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu', style: Theme.of(context).textTheme.headline1),
      ),
      body: Center(
        child: Text('This is menu screen'),
      ),
    );
  }
}
