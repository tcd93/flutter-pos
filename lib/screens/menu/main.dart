import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/common.dart';
import '../../provider/src.dart';
import '../menu_filterer.dart';
import 'counter.dart';
import '../node_appbar_title.dart';

class MenuScreen extends StatelessWidget {
  final String? fromHeroTag;

  const MenuScreen({this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const NodeAppBarTitle(),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const _UndoButton(),
            _ConfirmButton(fromHeroTag: fromHeroTag),
          ],
        ),
      ),
      body: MenuFilterer(
        builder: (context, menu) => ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: menu.length,
            itemBuilder: (context, index) {
              final dish = menu[index];
              final supplier = Provider.of<OrderSupplier>(context, listen: false);
              return Selector<OrderSupplier, int>(
                key: ObjectKey(dish),
                selector: (_, supplier) => supplier.getByDish(dish)?.quantity ?? 0,
                builder: (context, quantity, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Counter(
                    quantity,
                    onIncrement: (_) {
                      supplier.putIfAbsent(dish).addOne();
                      supplier.setStatus(TableStatus.incomplete);
                    },
                    onDecrement: (_) {
                      supplier.putIfAbsent(dish).substractOne();
                      // If there are not a single item in this order left,
                      // Then set status to "empty" to disable the [_ConfirmButton]
                      if (supplier.putIfAbsent(dish).quantity == 0 &&
                          supplier.totalMenuItemQuantity == 0) {
                        supplier.setStatus(TableStatus.empty);
                      } else {
                        supplier.setStatus(TableStatus.incomplete);
                      }
                    },
                    imgProvider: dish.imgProvider,
                    title: dish.dish,
                    subtitle: '(${Money.format(dish.price)})',
                    key: ObjectKey(supplier.order),
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final String? fromHeroTag;

  const _ConfirmButton({this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    final supplier = Provider.of<OrderSupplier>(context);

    return Hero(
      tag: fromHeroTag ?? UniqueKey(),
      child: Tooltip(
        message: AppLocalizations.of(context)!.menu_confirm,
        child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width / 2,
          onPressed: supplier.order.status == TableStatus.incomplete
              ? () {
                  supplier.setStatus(TableStatus.occupied);
                  supplier.memorizePreviousState();
                  Navigator.pop(context); // Go back to Lobby Screen
                }
              : null,
          child: const Icon(Icons.done),
        ),
      ),
    );
  }
}

class _UndoButton extends StatelessWidget {
  const _UndoButton();

  @override
  Widget build(BuildContext context) {
    final supplier = Provider.of<OrderSupplier>(context);
    // refer to [_ConfirmButton]
    return Tooltip(
      message: AppLocalizations.of(context)!.menu_undo,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width / 2,
        onPressed: supplier.order.status == TableStatus.incomplete ? () => supplier.revert() : null,
        child: const Icon(Icons.undo),
      ),
    );
  }
}
