import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/counter/counter.dart';

import '../models/dish.dart';
import '../models/table.dart';
import '../models/tracker.dart';

class MenuScreen extends StatelessWidget {
  final int tableID;
  final String fromHeroTag;

  MenuScreen(this.tableID, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding MenuScreen...');

    final model = context.select<OrderTracker, TableModel>(
      (tracker) => tracker.getTable(tableID),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu', style: Theme.of(context).textTheme.headline1),
        actions: [
          _UndoButton(
            tableID,
            fromHeroTag: fromHeroTag,
          ),
          _ConfirmButton(
            tableID,
            fromHeroTag: fromHeroTag,
          ),
        ],
      ),
      body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: Dish.getMenu().length,
          itemBuilder: (context, index) {
            var startingQuantity = model.orderOf(index)?.quantity ?? 0;

            return Counter(
              startingQuantity,
              onIncrement: (_) {
                model.putOrderIfAbsent(index).quantity++;

                model.setTableStatus(TableStatus.incomplete);
              },
              onDecrement: (_) {
                model.putOrderIfAbsent(index).quantity--;
                // If there are not a single item in this order left,
                // Then set status to "empty" to disable the [_ConfirmButton]
                if (model.orderOf(index).quantity == 0 && model.orderCount() == 0) {
                  model.setTableStatus(TableStatus.empty);
                } else {
                  model.setTableStatus(TableStatus.incomplete);
                }
              },
              imagePath: Dish.getMenu()[index].imagePath,
              subtitle: Dish.getMenu()[index].dish,
            );
          }),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final int tableID;
  final String fromHeroTag;

  _ConfirmButton(this.tableID, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    final model = context.select<OrderTracker, TableModel>(
      (tracker) => tracker.getTable(tableID),
    );
    return Hero(
      tag: fromHeroTag,
      // Use [Selector] here as the table status is deeply embedded
      // in Provider<OrderTracker>
      // We can also use [Tuple2] to select both [TableModel] and [TableStatus]
      child: Selector<OrderTracker, TableStatus>(
        selector: (_, tracker) => tracker.getTable(tableID).getTableStatus(),
        builder: (context, status, _) {
          return FlatButton(
            child: Icon(FontAwesomeIcons.check),
            onPressed: status == TableStatus.incomplete
                ? () {
                    model.setTableStatus(TableStatus.occupied);
                    Navigator.pop(context); // Go back to Lobby Screen
                  }
                : null,
          );
        },
      ),
    );
  }
}

class _UndoButton extends StatelessWidget {
  final int tableID;
  final String fromHeroTag;

  _UndoButton(this.tableID, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    final model = context.select<OrderTracker, TableModel>(
      (tracker) => tracker.getTable(tableID),
    );
    // refer to [_ConfirmButton]
    return Selector<OrderTracker, TableStatus>(
      selector: (_, tracker) => tracker.getTable(tableID).getTableStatus(),
      builder: (context, status, _) {
        return FlatButton(
          child: Icon(FontAwesomeIcons.undoAlt),
          onPressed: status == TableStatus.incomplete
              ? () {
                  model.revert();
                  //TODO: find a way to rebuild widgets more efficiently
                  Navigator.popAndPushNamed(context, '/menu', arguments: {
                    'heroTag': fromHeroTag,
                    'tableID': tableID,
                  });
                }
              : null,
        );
      },
    );
  }
}
