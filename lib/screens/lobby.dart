import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/radial_menu/radial_button.dart';
import '../common/radial_menu/radial_menu.dart';
import '../models/order.dart';

class LobbyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catalog', style: Theme.of(context).textTheme.headline1),
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
            _Table(1),
            _Table(2),
          ],
        ),
      ],
    );
  }
}

class _Table extends StatelessWidget {
  final int id;

  _Table(this.id);

  @override
  Widget build(BuildContext context) {
    debugPrint("rebuilding _Table... $id");

    var model = context.select<OrderTracker, TableModel>(
        (tracker) => tracker.getTable(this.id));

    return Padding(
        padding: const EdgeInsets.all(25),
        child: RadialMenu(
          key: ValueKey<int>(this.id),
          mainButtonBuilder: (radialAnimationController, context) {
            return FloatingActionButton(
              child: Icon(FontAwesomeIcons.table),
              onPressed: () {
                radialAnimationController.reverse();
                model.changeStatus();
              },
              backgroundColor: model.getStatusColor(),
            );
          },
          secondaryButtonBuilder: (radialAnimationController, context) {
            return FloatingActionButton(
              child: Icon(FontAwesomeIcons.expand),
              onPressed: () {
                radialAnimationController.forward();
                model.changeStatus();
              },
              backgroundColor: model.getStatusColor(),
            );
          },
          radialButtonsBuilder: (radialAnimationController, context) => [
            RadialButton(radialAnimationController, 0, () {
              radialAnimationController.reverse();
            }, color: Colors.red, icon: FontAwesomeIcons.thumbtack),
          ],
        ));
  }
}
