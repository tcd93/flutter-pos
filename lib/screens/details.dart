import 'package:flutter/material.dart';

import '../common/money_format/money.dart';
import '../models/dish.dart';
import '../models/immutable/order.dart';

class DetailsScreen extends StatelessWidget {
  final Order order;
  final String fromHeroTag;
  final String fromScreen;

  DetailsScreen(this.order, {this.fromHeroTag, this.fromScreen});

  @override
  Widget build(BuildContext context) {
    debugPrint('rebuilding DetailsScreen... (from $fromScreen)');

    final orders = order.lineItems;
    final totalPrice = order.totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Total - ${Money.format(totalPrice)}',
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: [
          _CheckoutButton(
            order,
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
                title: Text(
                  fromScreen == 'history'
                      // if this is from "History" screen
                      // then we view by the order's older state (not current name, current price...)
                      ? orders[index].dishName
                      : Dish.getMenu()[orders[index].dishID].dish,
                ),
                trailing: Text(Money.format(orders[index].amount)),
              ),
            );
          }),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  final Order order;
  final String fromHeroTag;
  final String fromScreen;

  _CheckoutButton(this.order, {this.fromHeroTag, @required this.fromScreen});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: fromHeroTag ?? 'CheckoutButtonHeroTag',
      child: FlatButton(
        child: Icon(Icons.print),
        onPressed: () {
          fromScreen == 'history'
              ? order.printReceipt()
              : order.checkout(context: context).then((_) => order.printReceipt());
          Navigator.pop(context); // Go back to Lobby Screen
        },
      ),
    );
  }
}
