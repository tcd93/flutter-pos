import 'package:flutter/material.dart';

import './components/table_component.dart';

class LobbyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby', style: Theme.of(context).textTheme.headline6),
      ),
      body: _LobbyLayout(),
    );
  }
}

/// Represents the table layout in lobby: 4 at the right side, 3 at the left side
class _LobbyLayout extends StatelessWidget {
  _LobbyLayout({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TableComponent(1, [0, 90]),
            TableComponent(2, [90, 180]),
          ],
        ),
      ],
    );
  }
}
