import 'package:flutter/material.dart';

import '../common/money_format/money.dart';

import '../models/dish.dart';
import '../models/table.dart';

class DetailsScreen extends StatelessWidget {
  final TableModel model;
  final String fromHeroTag;
  final String fromScreen;

  DetailsScreen(this.model, {this.fromHeroTag, this.fromScreen});

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding DetailsScreen... (from $fromScreen)');

    final orders = model.lineItems;
    final totalPrice = model.totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Total - ${Money.format(totalPrice)}',
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: [
          _CheckoutButton(
            model,
            fromHeroTag: fromHeroTag,
            fromScreen: fromScreen,
          ),
        ],
      ),
      body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return Card(
              key: ObjectKey(orders[index]),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(orders[index].quantity.toString()),
                ),
                title: Text(Dish.getMenu()[orders[index].dishID].dish),
                trailing: Text(
                  Money.format(orders[index].amount),
                ),
              ),
            );
          }),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  final TableModel model;
  final String fromHeroTag;
  final String fromScreen;

  _CheckoutButton(this.model, {this.fromHeroTag, @required this.fromScreen});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: fromHeroTag ?? 'CheckoutButtonHeroTag',
      child: FlatButton(
        child: Icon(Icons.print),
        onPressed: () {
          fromScreen == 'history'
              ? model.printReceipt()
              : model.checkout().then((_) => model.printReceipt());
          Navigator.pop(context); // Go back to Lobby Screen
        },
      ),
    );
  }
}
