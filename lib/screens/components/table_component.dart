import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../common/case2/case2.dart';
import '../../common/radial_menu/radial_button.dart';
import '../../common/radial_menu/radial_menu.dart';

import '../../models/table.dart';
import '../../models/tracker.dart';

class TableComponent extends StatelessWidget {
  final int id;
  final List<double> displayAngles;

  TableComponent(this.id, this.displayAngles);

  @override
  Widget build(BuildContext context) {
    // the table model to control state
    final model = context.select<OrderTracker, TableModel>((tracker) => tracker.getTable(id));
    debugPrint("rebuilding _Table... $id");

    return Padding(
      padding: const EdgeInsets.all(25),
      child: _MainButton(
        model,
        surroundingButtonsBuilder: (context, animController, angles) {
          // be aware that in this callback, model state may has changed
          return case2(model.isAbleToPlaceOrder(), {
            true: _fullFlow(context, model, animController, angles),
            //TODO: add disable FAB color
            false: _partialFlow(context, model, animController, angles),
          });
        },
        displayAngles: displayAngles,
        key: ObjectKey(model),
      ),
    );
  }
}

class _MainButton extends StatelessWidget {
  final TableModel model;

  /// Returns a list of surrounding [RadialButton].
  /// Should match the number of elements in [displayAngles]
  final List<RadialButton> Function(BuildContext, AnimationController, List<double> displayAngles)
      surroundingButtonsBuilder;

  /// Clock-wise placement angles for surrounding sub-buttons (add order, details...).
  /// Example: `[0, 90]` would place one at 3 o'clock, the other at 6 o'clock
  final List<double> displayAngles;

  // create a smooth color transition effect
  final ColorTween _colorTween;

  _MainButton(this.model,
      {@required this.surroundingButtonsBuilder, @required this.displayAngles, Key key})
      : _colorTween = ColorTween(begin: model.currentColor(), end: model.reversedColor()),
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
            radialAnimationController.forward();
          },
          backgroundColor: _colorTween.animate(radialAnimationController).value,
        );
      },
      secondaryButtonBuilder: (radialAnimationController, context) {
        return FloatingActionButton(
          heroTag: null,
          child: Icon(FontAwesomeIcons.expand),
          onPressed: () {
            radialAnimationController.reverse();
          },
          backgroundColor: _colorTween.animate(radialAnimationController).value,
        );
      },
      radialButtonsBuilder: (context, animController) =>
          surroundingButtonsBuilder(context, animController, displayAngles),
    );
  }
}

/// Partial flow: only able to see order details
_partialFlow(BuildContext _, TableModel __, AnimationController radialAnimationController,
        List<double> angles) =>
    [
      RadialButton(
        controller: radialAnimationController,
        angle: angles[0],
        onPressed: null, //disabled
        icon: FontAwesomeIcons.plusCircle,
        key: ValueKey<int>(1),
      ),
      RadialButton(
        controller: radialAnimationController,
        angle: angles[1],
        onPressed: () {
          radialAnimationController.reverse();
        },
        icon: FontAwesomeIcons.infoCircle,
        key: ValueKey<int>(2),
      ),
    ];

/// Full flow: able to place order, see order details
_fullFlow(BuildContext context, TableModel model, AnimationController radialAnimationController,
        List<double> angles) =>
    [
      RadialButton(
        heroTag: "menu-subtag-table-${model.id}",
        controller: radialAnimationController,
        angle: angles[0],
        onPressed: () {
          // model.toggleStatus();
          // pass hero tag into new Page to animate the FAB
          Navigator.pushNamed(context, '/menu',
                  arguments: {'heroTag': 'menu-subtag-table-${model.id}', 'tableID': model.id})
              .then((_) {
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
        angle: angles[1],
        onPressed: () {
          // model.toggleStatus();
          radialAnimationController.reverse();
          Navigator.pushNamed(context, '/order-details',
              arguments: {'heroTag': 'details-subtag-table-${model.id}', 'tableID': model.id});
        },
        icon: FontAwesomeIcons.infoCircle,
        key: ValueKey<int>(2),
      ),
    ];
