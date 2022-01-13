import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'order_card.dart';
import '../../../provider/src.dart';

class HistoryOrderList extends StatelessWidget {
  final Iterable<Order> orders;

  const HistoryOrderList(this.orders);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return OrderCard(orders.elementAt(index));
      },
    );
  }
}
