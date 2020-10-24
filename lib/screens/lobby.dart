import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/case2/case2.dart';
import '../common/radial_menu/radial_button.dart';
import '../common/radial_menu/radial_menu.dart';

import '../models/table.dart';
import '../models/tracker.dart';

class LobbyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby', style: Theme.of(context).textTheme.headline1),
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
            //TODO: angles should be defined from here
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
    // the table model to control state
    final model = context.select<OrderTracker, TableModel>((tracker) => tracker.getTable(id));
    debugPrint("rebuilding _Table... $id");

    return Padding(
      padding: const EdgeInsets.all(25),
      child: _MainButton(
        model,
        surroundingButtonsBuilder: (context, animController) {
          // be aware that in this callback, model state may has changed
          return case2(model.isAbleToPlaceOrder(), {
            true: _fullFlow(context, model, animController),
            //TODO: add disable FAB color
            false: _partialFlow(context, model, animController),
          });
        },
        key: ObjectKey(model),
      ),
    );
  }
}

class _MainButton extends StatelessWidget {
  final TableModel model;
  final List<RadialButton> Function(BuildContext, AnimationController) surroundingButtonsBuilder;

  // create a smooth color transition effect
  final ColorTween colorTween;

  _MainButton(this.model, {this.surroundingButtonsBuilder, Key key})
      : colorTween = ColorTween(begin: model.currentColor(), end: model.reversedColor()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("rebuilding _MainButton... ${model.id}");

    return RadialMenu(
      mainButtonBuilder: (radialAnimationController, context) {
        return FloatingActionButton(
          heroTag: null,
          child: Icon(FontAwesomeIcons.circleNotch),
          onPressed: () {
            // model.toggleStatus();
            radialAnimationController.forward();
          },
          backgroundColor: colorTween.animate(radialAnimationController).value,
        );
      },
      secondaryButtonBuilder: (radialAnimationController, context) {
        return FloatingActionButton(
          heroTag: null,
          child: Icon(FontAwesomeIcons.expand),
          onPressed: () {
            // model.toggleStatus();
            radialAnimationController.reverse();
          },
          backgroundColor: colorTween.animate(radialAnimationController).value,
        );
      },
      radialButtonsBuilder: surroundingButtonsBuilder,
    );
  }
}

/// Partial flow: only able to see order details
_partialFlow(BuildContext _, TableModel __, AnimationController radialAnimationController) => [
      RadialButton(
        controller: radialAnimationController,
        angle: 0,
        onPressed: null, //disabled
        icon: FontAwesomeIcons.plusCircle,
        key: ValueKey<int>(1),
      ),
      RadialButton(
        controller: radialAnimationController,
        angle: 90,
        onPressed: () {
          radialAnimationController.reverse();
        },
        icon: FontAwesomeIcons.infoCircle,
        key: ValueKey<int>(2),
      ),
    ];

/// Full flow: able to place order, see order details
_fullFlow(BuildContext context, TableModel model, AnimationController radialAnimationController) =>
    [
      RadialButton(
        heroTag: "menu-subtag-table-${model.id}",
        controller: radialAnimationController,
        angle: 0,
        onPressed: () {
          // model.toggleStatus();
          // pass hero tag into new Page to animate the FAB
          Navigator.pushNamed(context, '/menu', arguments: 'subtag1-${model.id}').then((_) {
            Future.delayed(Duration(milliseconds: 600), () {
              radialAnimationController.reverse();
            });
          });
        },
        icon: FontAwesomeIcons.plusCircle,
        key: ValueKey<int>(1),
      ),
      RadialButton(
        heroTag: "details-subtag-table-${model.id}",
        controller: radialAnimationController,
        angle: 90,
        onPressed: () {
          // model.toggleStatus();
          radialAnimationController.reverse();
          //TODO: implement Order Details page
          Navigator.pushNamed(context, '/order-details', arguments: 'subtag2-${model.id}');
        },
        icon: FontAwesomeIcons.infoCircle,
        key: ValueKey<int>(2),
      ),
    ];
