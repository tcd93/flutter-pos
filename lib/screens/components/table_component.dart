import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

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
    final model = context.select<OrderTracker, TableModel>(
      (tracker) => tracker.getTable(id),
    );
    debugPrint("rebuilding _Table... $id");

    return Padding(
      padding: const EdgeInsets.all(15),
      child: _MainButton(
        model,
        surroundingButtonsBuilder: (context, animController, angles) =>
            _sideButtonsBuilder(context, model, animController, angles),
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
  final List<Widget> Function(
    BuildContext,
    AnimationController,
    List<double> displayAngles,
  ) surroundingButtonsBuilder;

  /// Clock-wise placement angles for surrounding sub-buttons (add order, details...).
  /// Example: `[0, 90]` would place one at 3 o'clock, the other at 6 o'clock
  final List<double> displayAngles;

  _MainButton(
    this.model, {
    @required this.surroundingButtonsBuilder,
    @required this.displayAngles,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("rebuilding _MainButton... ${model.id}");

    final _colorTween = ColorTween(
      begin: Theme.of(context).primaryColor,
      end: Theme.of(context).disabledColor,
    );

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

/// Able to place order, see order details
_sideButtonsBuilder(
  BuildContext context,
  TableModel model,
  AnimationController radialAnimationController,
  List<double> angles,
) {
  final status = context.select<OrderTracker, TableStatus>(
    (_) => model.getTableStatus(),
  );
  return [
    RadialButton(
      heroTag: "menu-subtag-table-${model.id}",
      controller: radialAnimationController,
      angle: angles[0],
      onPressed: () {
        // model.toggleStatus();
        // pass hero tag into new Page to animate the FAB
        Navigator.pushNamed(context, '/menu', arguments: {
          'heroTag': 'menu-subtag-table-${model.id}',
          'tableID': model.id,
        }).then((_) {
          Future.delayed(
            Duration(milliseconds: 600),
            () {
              radialAnimationController.reverse();
            },
          );
        });
      },
      icon: FontAwesomeIcons.plusCircle,
      key: ValueKey<int>(1),
    ),
    RadialButton(
      heroTag: "details-subtag-table-${model.id}",
      controller: radialAnimationController,
      angle: angles[1],
      onPressed: status == TableStatus.occupied
          ? () {
              Navigator.pushNamed(context, '/order-details', arguments: {
                'heroTag': 'details-subtag-table-${model.id}',
                'tableID': model.id,
              }).then((_) {
                Future.delayed(
                  Duration(milliseconds: 600),
                  () {
                    radialAnimationController.reverse();
                  },
                );
              });
            }
          : null,
      icon: FontAwesomeIcons.infoCircle,
      key: ValueKey<int>(2),
    ),
  ];
}
