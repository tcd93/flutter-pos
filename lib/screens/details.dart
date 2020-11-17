import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/money_format/money.dart';

import '../models/dish.dart';
import '../models/supplier.dart';
import '../models/table.dart';

class DetailsScreen extends StatelessWidget {
  final TableModel model;
  final String fromHeroTag;

  DetailsScreen(this.model, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding DetailsScreen...');

    final orders = model.lineItems();
    final totalPrice = model.totalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Total - ${Money.format(totalPrice)}',
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: [
          _CheckoutButton(model, fromHeroTag: fromHeroTag),
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

  _CheckoutButton(this.model, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: fromHeroTag ?? 'CheckoutButtonHeroTag',
      child: Selector<Supplier, TableStatus>(
        selector: (_, __) => model.getTableStatus(),
        builder: (context, status, _) {
          return FlatButton(
            child: Icon(Icons.print),
            onPressed: () {
              model.checkout();
              Navigator.pop(context); // Go back to Lobby Screen
            },
          );
        },
      ),
    );
  }
}
