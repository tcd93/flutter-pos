import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../provider/src.dart';
import 'order_card.dart';

class HistoryOrderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final length = context.select<HistoryOrderSupplier, int>(
        (HistoryOrderSupplier supplier) => supplier.orders.length);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: length,
      itemBuilder: (context, index) {
        return OrderCard(index);
      },
    );
  }
}
