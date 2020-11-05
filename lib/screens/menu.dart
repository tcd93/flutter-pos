import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../common/counter/counter.dart';

import '../models/dish.dart';
import '../models/order.dart';
import '../models/table.dart';
import '../models/tracker.dart';

class MenuScreen extends StatelessWidget {
  final int tableID;
  final String fromHeroTag;

  MenuScreen(this.tableID, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding MenuScreen...');

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
            return Selector<OrderTracker, Tuple2<TableModel, Order>>(
              selector: (context, tracker) {
                return Tuple2(
                  tracker.getTable(tableID), // item1
                  tracker.getTable(tableID).orderOf(index), // item2
                );
              },
              builder: (context, tuple, _) {
                return Counter(
                  tuple.item1.orderOf(index)?.quantity ?? 0,
                  onIncrement: (_) {
                    tuple.item2.quantity++;

                    tuple.item1.setTableStatus(TableStatus.incomplete);
                  },
                  onDecrement: (_) {
                    tuple.item2.quantity--;
                    // If there are not a single item in this order left,
                    // Then set status to "empty" to disable the [_ConfirmButton]
                    if (tuple.item1.orderOf(index).quantity == 0 &&
                        tuple.item1.totalMenuItemQuantity() == 0) {
                      tuple.item1.setTableStatus(TableStatus.empty);
                    } else {
                      tuple.item1.setTableStatus(TableStatus.incomplete);
                    }
                  },
                  imagePath: Dish.getMenu()[index].imagePath,
                  subtitle: Dish.getMenu()[index].dish,
                  key: ObjectKey(tuple.item1),
                );
              },
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
    return Hero(
      tag: fromHeroTag,
      // Use [Selector] here as the table status is deeply embedded
      // in Provider<OrderTracker>
      // We can also use [Tuple2] to select both [TableModel] and [TableStatus]
      child: Selector<OrderTracker, TableStatus>(
        selector: (_, tracker) => tracker.getTable(tableID).getTableStatus(),
        builder: (context, status, _) {
          final model = context.select<OrderTracker, TableModel>(
            (tracker) => tracker.getTable(tableID),
          );
          return FlatButton(
            child: Icon(FontAwesomeIcons.check),
            onPressed: status == TableStatus.incomplete
                ? () {
                    model.memorizePreviousState();
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
    // refer to [_ConfirmButton]
    return Selector<OrderTracker, TableStatus>(
      selector: (_, tracker) => tracker.getTable(tableID).getTableStatus(),
      builder: (context, status, _) {
        final model = context.select<OrderTracker, TableModel>(
          (tracker) => tracker.getTable(tableID),
        );
        return FlatButton(
          child: Icon(FontAwesomeIcons.undoAlt),
          onPressed: status == TableStatus.incomplete ? model.revert : null,
        );
      },
    );
  }
}
