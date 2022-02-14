import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/common.dart';
import '../../theme/rally.dart';
import '../../provider/src.dart';
import '../popup_del.dart';

class TableIcon extends StatelessWidget {
  final TableModel table;

  const TableIcon({required this.table});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: _RadialButton(
        table,
        surroundingButtonsBuilder: (context, animController, angles) =>
            _build(context, animController, angles),
        displayAngles: const [0, 90, 180],
      ),
    );
  }

  List<Widget> _build(
    BuildContext context,
    AnimationController radialAnimationController,
    List<double> angles,
  ) {
    return [
      // add order
      DrawerItem(
        controller: radialAnimationController,
        angle: angles[0],
        key: const ValueKey<int>(1),
        child: FloatingActionButton(
          mini: true,
          heroTag: 'menu-subtag-table-${table.id}',
          onPressed: () {
            Navigator.pushNamed(context, '/menu', arguments: {
              'heroTag': 'menu-subtag-table-${table.id}',
              'model': table,
            }).then((_) {
              Future.delayed(
                const Duration(milliseconds: 600),
                () => radialAnimationController.reverse(),
              );
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
      // see order details (and checkout)
      DrawerItem(
        controller: radialAnimationController,
        angle: angles[1],
        key: const ValueKey<int>(2),
        child: FloatingActionButton(
          mini: true,
          heroTag: 'details-subtag-table-${table.id}',
          onPressed: table.status == TableStatus.occupied
              ? () {
                  Navigator.pushNamed(context, '/order-details', arguments: {
                    'heroTag': 'details-subtag-table-${table.id}',
                    'state': table,
                    'from': 'lobby',
                  }).then((_) {
                    Future.delayed(
                      const Duration(milliseconds: 600),
                      () => radialAnimationController.reverse(),
                    );
                  });
                }
              : null,
          backgroundColor: table.status == TableStatus.occupied ? null : RallyColors.gray,
          child: const Icon(Icons.receipt),
        ),
      ),
      // remove table node
      DrawerItem(
        controller: radialAnimationController,
        angle: angles[2],
        key: const ValueKey<int>(3),
        child: FloatingActionButton(
          mini: true,
          heroTag: 'delete-subtag-table-${table.id}',
          onPressed: () => _removeTable(context, table),
          child: const Icon(Icons.delete),
        ),
      ),
    ];
  }
}

class _RadialButton extends StatelessWidget {
  final TableModel model;

  final List<Widget> Function(BuildContext, AnimationController, List<double> displayAngles)
      surroundingButtonsBuilder;

  /// Clock-wise placement angles for surrounding sub-buttons (add order, details...).
  /// Example: `[0, 90]` would place one at 3 o'clock, the other at 6 o'clock
  final List<double> displayAngles;

  const _RadialButton(
    this.model, {
    required this.surroundingButtonsBuilder,
    required this.displayAngles,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _colorTween = ColorTween(
      begin: model.status == TableStatus.occupied
          ? Colors.yellow[300]
          : model.status == TableStatus.incomplete
              ? Colors.grey[500]
              : Theme.of(context).floatingActionButtonTheme.backgroundColor,
      end: RallyColors.focusColor,
    );

    return RadialMenu(
      closedBuilder: (radialAnimationController, context) {
        return FloatingActionButton(
          heroTag: null,
          onPressed: () {
            radialAnimationController.forward();
          },
          backgroundColor: _colorTween.animate(radialAnimationController).value,
          child: Text(model.id.toString()),
        );
      },
      openBuilder: (radialAnimationController, context) {
        return FloatingActionButton(
          heroTag: null,
          onPressed: () {
            radialAnimationController.reverse();
          },
          backgroundColor: _colorTween.animate(radialAnimationController).value,
          child: const Icon(Icons.circle),
        );
      },
      drawerBuilder: (context, animController) =>
          surroundingButtonsBuilder(context, animController, displayAngles),
    );
  }
}

// ******************************* //

void _removeTable(BuildContext context, TableModel table) async {
  final supplier = Provider.of<Supplier>(context, listen: false);
  var delete = await popUpDelete(context);
  if (delete != null && delete) {
    supplier.removeTable(table);
  }
}
