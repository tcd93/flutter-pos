import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../provider/src.dart';
import 'order_card.dart';

class HistoryOrderList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = context.select((HistoryOrderSupplier supplier) => supplier.orders);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return OrderCard(index);
      },
    );
  }
}
