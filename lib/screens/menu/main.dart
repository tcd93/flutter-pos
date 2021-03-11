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
    final menuSupplier = Provider.of<MenuSupplier>(context);
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
          itemCount: menuSupplier.menu.length,
          itemBuilder: (context, index) {
            final dish = menuSupplier.getDish(index);
            final lineItem = model.putIfAbsent(dish);
            // there's some inefficiency here as we're replacing the whole state when calling `revert()`
            // everything in this listview is going to be updated
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
                  if (model.putIfAbsent(dish).quantity == 0 && model.totalMenuItemQuantity == 0) {
                    model.setTableStatus(TableStatus.empty, supplier);
                  } else {
                    model.setTableStatus(TableStatus.incomplete, supplier);
                  }
                },
                imgProvider: dish.imgProvider,
                title: dish.dish,
                subtitle: '(${Money.format(dish.price)})',
                key: ObjectKey(model),
              ),
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
              onPressed: status == TableStatus.incomplete
                  ? () {
                      final supplier = context.read<Supplier>();
                      model.setTableStatus(TableStatus.occupied, supplier);
                      model.memorizePreviousState();
                      Navigator.pop(context); // Go back to Lobby Screen
                    }
                  : null,
              child: Icon(Icons.done),
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
            onPressed: status == TableStatus.incomplete
                ? () {
                    final supplier = context.read<Supplier>();
                    model.revert(supplier);
                  }
                : null,
            child: Icon(Icons.undo),
          ),
        );
      },
    );
  }
}
