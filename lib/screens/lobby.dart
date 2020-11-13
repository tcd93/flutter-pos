import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../common/radial_menu/radial_button.dart';
import '../common/radial_menu/radial_menu.dart';

import '../models/supplier.dart';
import '../models/table.dart';

class LobbyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby', style: Theme.of(context).textTheme.headline6),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Restaurant App',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ),
            ListTile(
              title: Text('History'),
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
            ),
          ],
        ),
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
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TableComponent(1, [0, 90]),
                  _TableComponent(2, [0, 90]),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TableComponent(3, [0, 90]),
                  _TableComponent(4, [0, 90]),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _TableComponent(5, [0, 90]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableComponent extends StatelessWidget {
  final int id;
  final List<double> displayAngles;

  _TableComponent(this.id, this.displayAngles);

  @override
  Widget build(BuildContext context) {
    // the table model to control state
    final model = context.select<Supplier, TableModel>(
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

    final status = context.select<Supplier, TableStatus>(
      (_) => model.getTableStatus(),
    );

    // display different color when table is occupied
    final _colorTween = ColorTween(
      begin: status == TableStatus.occupied
          ? Colors.yellow[300]
          : Theme.of(context).floatingActionButtonTheme.backgroundColor,
      end: Theme.of(context).floatingActionButtonTheme.focusColor,
    );

    return RadialMenu(
      mainButtonBuilder: (radialAnimationController, context) {
        return SizedBox(
          width: 85,
          height: 85,
          child: FittedBox(
            child: FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.crop_square),
              onPressed: () {
                radialAnimationController.forward();
              },
              backgroundColor: _colorTween.animate(radialAnimationController).value,
            ),
          ),
        );
      },
      secondaryButtonBuilder: (radialAnimationController, context) {
        return FloatingActionButton(
          heroTag: null,
          child: Icon(Icons.circle),
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
  final status = context.select<Supplier, TableStatus>(
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
      icon: Icons.add,
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
      icon: Icons.receipt,
      key: ValueKey<int>(2),
    ),
  ];
}
