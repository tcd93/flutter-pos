import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/radial_menu/radial_button.dart';
import '../common/radial_menu/radial_menu.dart';
import '../common/case2/case2.dart';

import '../models/order.dart';
import '../models/table.dart';

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

    // the table model to control state
    final model = context.select<OrderTracker, TableModel>((tracker) => tracker.getTable(this.id));

    return Padding(
      padding: const EdgeInsets.all(25),
      child: case2(model.isAbleToPlaceOrder(), {
        true: menuRenderFullFlow(model),
        false: menuRenderPartialFlow(model),
      }),
    );
  }
}

RadialMenu menuRenderPartialFlow(TableModel model) {
  //TODO: implement partial flow (only able to see order details)

  return RadialMenu(
    key: ValueKey(model.id),
    mainButtonBuilder: (radialAnimationController, context) {
      return FloatingActionButton(
        child: Icon(FontAwesomeIcons.circleNotch),
        backgroundColor: Colors.grey[400],
        onPressed: null, // disabled
        disabledElevation: 0,
      );
    },
    radialButtonsBuilder: (radialAnimationController, context) => [
      RadialButton(
        radialAnimationController,
        0,
        (key) {
          radialAnimationController.reverse();
        },
        color: Colors.red,
        icon: FontAwesomeIcons.infoCircle,
        key: ValueKey<int>(2),
      ),
    ],
  );
}

/// Full flow: able to place order, see order details
RadialMenu menuRenderFullFlow(TableModel model) {
  // create a smooth color transition effect
  final colorTween = ColorTween(begin: model.currentColor(), end: model.reversedColor());

  return RadialMenu(
    key: ValueKey(model.id),
    mainButtonBuilder: (radialAnimationController, context) {
      return FloatingActionButton(
        child: Icon(FontAwesomeIcons.circleNotch),
        onPressed: () {
          model.toggleStatus();
          radialAnimationController.forward();
        },
        backgroundColor: colorTween.animate(radialAnimationController).value,
      );
    },
    secondaryButtonBuilder: (radialAnimationController, context) {
      return FloatingActionButton(
        child: Icon(FontAwesomeIcons.expand),
        onPressed: () {
          model.toggleStatus();
          radialAnimationController.reverse();
        },
        backgroundColor: colorTween.animate(radialAnimationController).value,
      );
    },
    radialButtonsBuilder: (radialAnimationController, context) => [
      RadialButton(
        radialAnimationController,
        0,
        (key) {
          model.toggleStatus();
          radialAnimationController.reverse();
        },
        color: Colors.red,
        icon: FontAwesomeIcons.plusCircle,
        key: ValueKey<int>(1),
      ),
      RadialButton(
        radialAnimationController,
        90,
        (key) {
          model.toggleStatus();
          radialAnimationController.reverse();
        },
        color: Colors.red,
        icon: FontAwesomeIcons.infoCircle,
        key: ValueKey<int>(2),
      ),
    ],
  );
}
