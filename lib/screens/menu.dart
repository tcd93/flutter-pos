import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../common/counter/counter.dart';
import '../common/money_format/money.dart';

import '../models/dish.dart';
import '../models/line_item.dart';
import '../models/supplier.dart';
import '../models/table.dart';

class MenuScreen extends StatelessWidget {
  final TableModel model;
  final String fromHeroTag;

  MenuScreen(this.model, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding MenuScreen...');

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu', style: Theme.of(context).textTheme.headline6),
        actions: [
          _UndoButton(
            model,
            fromHeroTag: fromHeroTag,
          ),
          _ConfirmButton(
            model,
            fromHeroTag: fromHeroTag,
          ),
        ],
      ),
      body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: Dish.getMenu()
              .length, // same count of order line items and items in the `menu` constant in [Dish]
          itemBuilder: (context, index) {
            return Selector<Supplier, Tuple2<TableModel, LineItem>>(
              selector: (context, tracker) {
                return Tuple2(
                  model, // item1
                  model.lineItem(index), // item2
                );
              },
              builder: (context, tuple, _) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Counter(
                    tuple.item1.lineItem(index)?.quantity ?? 0,
                    onIncrement: (_) {
                      tuple.item2.quantity++;

                      tuple.item1.setTableStatus(TableStatus.incomplete);
                    },
                    onDecrement: (_) {
                      tuple.item2.quantity--;
                      // If there are not a single item in this order left,
                      // Then set status to "empty" to disable the [_ConfirmButton]
                      if (tuple.item1.lineItem(index).quantity == 0 &&
                          tuple.item1.totalMenuItemQuantity() == 0) {
                        tuple.item1.setTableStatus(TableStatus.empty);
                      } else {
                        tuple.item1.setTableStatus(TableStatus.incomplete);
                      }
                    },
                    imagePath: Dish.getMenu()[index].imagePath,
                    subtitle:
                        '${Dish.getMenu()[index].dish} (${Money.format(Dish.getMenu()[index].price)})',
                    key: ObjectKey(tuple.item1),
                  ),
                );
              },
            );
          }),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final TableModel model;
  final String fromHeroTag;

  _ConfirmButton(this.model, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: fromHeroTag,
      // Use [Selector] here as the table status is deeply embedded
      child: Selector<Supplier, TableStatus>(
        selector: (_, __) => model.getTableStatus(),
        builder: (context, status, _) {
          return FlatButton(
            child: Icon(Icons.done),
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
  final TableModel model;
  final String fromHeroTag;

  _UndoButton(this.model, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    // refer to [_ConfirmButton]
    return Selector<Supplier, TableStatus>(
      selector: (_, __) => model.getTableStatus(),
      builder: (context, status, _) {
        return FlatButton(
          child: Icon(Icons.undo),
          onPressed: status == TableStatus.incomplete ? model.revert : null,
        );
      },
    );
  }
}
