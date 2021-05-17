import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'order_card.dart';
import '../../../provider/src.dart';

class HistoryOrderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = context.select<HistorySupplierByDate, Iterable<Order>>(
      (provider) => provider.data,
    );
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return OrderCard(index);
      },
    );
  }
}
