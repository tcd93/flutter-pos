import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dish.dart';
import '../models/table.dart';
import '../models/tracker.dart';

//TODO> list out the details of current order
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
    final orders = model.orders();

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu', style: Theme.of(context).textTheme.headline1),
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
                trailing: Text('pricing...'), //TODO add price&subtitle (note)
              ),
            );
          }),
    );
  }
}
