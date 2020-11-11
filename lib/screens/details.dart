import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/money_format/money.dart';

import '../models/dish.dart';
import '../models/supplier.dart';
import '../models/table.dart';

class DetailsScreen extends StatelessWidget {
  final int tableID;
  final String fromHeroTag;

  DetailsScreen(this.tableID, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding DetailsScreen...');

    final model = context.select<Supplier, TableModel>(
      (tracker) => tracker.getTable(tableID),
    );
    final orders = model.lineItems();
    final totalPrice = model.totalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Total - ${Money.format(totalPrice)}',
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: [
          _CheckoutButton(model.id, fromHeroTag: fromHeroTag),
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
                  Money.format(orders[index].amount()),
                ),
              ),
            );
          }),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  final int tableID;
  final String fromHeroTag;

  _CheckoutButton(this.tableID, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: fromHeroTag,
      child: Selector<Supplier, TableStatus>(
        selector: (_, tracker) => tracker.getTable(tableID).getTableStatus(),
        builder: (context, status, _) {
          final model = context.select<Supplier, TableModel>(
            (tracker) => tracker.getTable(tableID),
          );
          return FlatButton(
            child: Icon(FontAwesomeIcons.print),
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
