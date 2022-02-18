import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';
import '../../provider/src.dart';
import 'counter.dart';

class MenuScreen extends StatelessWidget {
  final TableModel model;
  final String? fromHeroTag;

  const MenuScreen(this.model, {this.fromHeroTag});

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
      body: _MenuList(
        builder: (context, menu) => ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: menu.length,
            itemBuilder: (context, index) {
              final dish = menu[index];
              final supplier = Provider.of<Supplier>(context, listen: false);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Counter(
                  model.getByDish(dish)?.quantity ?? 0,
                  onIncrement: (_) {
                    model.putIfAbsent(dish).addOne();
                    supplier.setTableStatus(model, TableStatus.incomplete);
                  },
                  onDecrement: (_) {
                    model.putIfAbsent(dish).substractOne();
                    // If there are not a single item in this order left,
                    // Then set status to "empty" to disable the [_ConfirmButton]
                    if (model.putIfAbsent(dish).quantity == 0 && model.totalMenuItemQuantity == 0) {
                      supplier.setTableStatus(model, TableStatus.empty);
                    } else {
                      supplier.setTableStatus(model, TableStatus.incomplete);
                    }
                  },
                  imgProvider: dish.imgProvider,
                  title: dish.dish,
                  subtitle: '(${Money.format(dish.price)})',
                  key: ObjectKey(model),
                ),
              );
            }),
      ),
    );
  }
}

class _MenuList extends StatelessWidget {
  final Widget Function(BuildContext, List<Dish>) builder;

  /// Return generic text 'No data found' or build a list of [_ListItem]
  const _MenuList({required this.builder});

  @override
  Widget build(BuildContext context) {
    final dishes = context.select<MenuSupplier?, List<Dish>?>((value) {
      return value?.menu.toList();
    });
    if (dishes == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }
    if (dishes.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)?.generic_empty ?? 'No data found'),
      );
    }
    return builder(context, dishes);
  }
}

class _ConfirmButton extends StatelessWidget {
  final TableModel model;
  final String? fromHeroTag;

  const _ConfirmButton(this.model, {this.fromHeroTag});

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
                      context.read<Supplier>().setTableStatus(model, TableStatus.occupied);
                      model.memorizePreviousState();
                      Navigator.pop(context); // Go back to Lobby Screen
                    }
                  : null,
              child: const Icon(Icons.done),
            ),
          );
        },
      ),
    );
  }
}

class _UndoButton extends StatelessWidget {
  final TableModel model;

  const _UndoButton(this.model);

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
                    context.read<Supplier>().revert(model);
                  }
                : null,
            child: const Icon(Icons.undo),
          ),
        );
      },
    );
  }
}
