import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/money_format/money.dart';

import '../models/dish.dart';
import '../models/table.dart';
import '../models/tracker.dart';

class DetailsScreen extends StatelessWidget {
  final int tableID;
  final String fromHeroTag;

  DetailsScreen(this.tableID, {this.fromHeroTag});

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding DetailsScreen...');

    final model = context.select<OrderTracker, TableModel>(
      (tracker) => tracker.getTable(tableID),
    );
    final orders = model.lineItems();
    final totalPrice = orders.fold(0, (prev, order) {
      return prev + order.amount();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Total - ${Money.format(totalPrice.toString())}',
          style: Theme.of(context).textTheme.headline2,
        ),
        actions: [
          //TODO > add Checkout button
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
                  Money.format(orders[index].amount().toString()),
                ),
              ),
            );
          }),
    );
  }
}
