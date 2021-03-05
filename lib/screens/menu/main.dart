import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';
import '../../provider/src.dart';
import 'counter.dart';

class MenuScreen extends StatelessWidget {
  final TableModel model;
  final String? fromHeroTag;

  MenuScreen(this.model, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _UndoButton(model),
            _ConfirmButton(model, fromHeroTag: fromHeroTag),
          ],
        ),
      ),
      body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          // same count of order line items and items in the `menu` constant in [Dish]
          itemCount: Dish.getMenu().length,
          itemBuilder: (context, index) {
            final dish = Dish.at(index);

            return Selector<Supplier, LineItem>(
              // in case new menu dish is created from Edit Menu screen
              // `putIfAbsent` will put new line item to the lineItems object
              selector: (_, supplier) => model.putIfAbsent(dish),
              builder: (context, lineItem, _) {
                final supplier = Provider.of<Supplier>(context);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Counter(
                    model.putIfAbsent(dish).quantity,
                    onIncrement: (_) {
                      lineItem.addOne();

                      model.setTableStatus(TableStatus.incomplete, supplier);
                    },
                    onDecrement: (_) {
                      lineItem.substractOne();
                      // If there are not a single item in this order left,
                      // Then set status to "empty" to disable the [_ConfirmButton]
                      if (model.putIfAbsent(dish).quantity == 0 &&
                          model.totalMenuItemQuantity == 0) {
                        model.setTableStatus(TableStatus.empty, supplier);
                      } else {
                        model.setTableStatus(TableStatus.incomplete, supplier);
                      }
                    },
                    imageData: Dish.at(index).imageBytes,
                    title: dish.dish,
                    subtitle: '(${Money.format(dish.price)})',
                    key: ObjectKey(model),
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
  final String? fromHeroTag;

  _ConfirmButton(this.model, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: fromHeroTag ?? UniqueKey(),
      child: Selector<Supplier, TableStatus>(
        selector: (_, __) => model.status,
        builder: (context, status, _) {
          return Tooltip(
            message: AppLocalizations.of(context)!.menu_confirm,
            child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width / 2,
              child: Icon(Icons.done),
              onPressed: status == TableStatus.incomplete
                  ? () {
                      final supplier = context.read<Supplier>();
                      model.setTableStatus(TableStatus.occupied, supplier);
                      model.memorizePreviousState();
                      Navigator.pop(context); // Go back to Lobby Screen
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _UndoButton extends StatelessWidget {
  final TableModel model;

  _UndoButton(this.model);

  @override
  Widget build(BuildContext context) {
    // refer to [_ConfirmButton]
    return Selector<Supplier, TableStatus>(
      selector: (_, __) => model.status,
      builder: (context, status, _) {
        return Tooltip(
          message: AppLocalizations.of(context)!.menu_undo,
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width / 2,
            child: Icon(Icons.undo),
            onPressed: status == TableStatus.incomplete
                ? () {
                    final supplier = context.read<Supplier>();
                    model.revert(supplier);
                  }
                : null,
          ),
        );
      },
    );
  }
}
