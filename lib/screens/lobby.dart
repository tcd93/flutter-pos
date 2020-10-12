import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hembo/common/radial_menu/radial_button.dart';
import 'package:hembo/common/radial_menu/radial_menu.dart';
import 'package:provider/provider.dart';
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
          onPressed: ({String event}) {
            model.changeStatus();
          },
          buttonsBuilder: (radialAnimationController) => [
            RadialButton(radialAnimationController, 0, () {
              radialAnimationController.reverse();
            }, color: Colors.red, icon: FontAwesomeIcons.thumbtack),
            // RadialButton(controller, 45, _close,
            //     color: Colors.green, icon: FontAwesomeIcons.sprayCan),
            // RadialButton(controller, 90, _close,
            //     color: Colors.orange, icon: FontAwesomeIcons.fire),
            // RadialButton(controller, 135, _close,
            //     color: Colors.blue, icon: FontAwesomeIcons.kiwiBird),
          ],
          // child: RaisedButton(
          //   key: ValueKey(model.id),
          //   color: context
          //       .select<OrderTracker, Color>((tracker) => model.getStatusColor()),
          //   child: Text(
          //     model.id.toString(),
          //     style: Theme.of(context).textTheme.headline3,
          //   ),
          //   onPressed: () => null,
          // ),
        ));
  }
}
