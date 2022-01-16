import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'order_card.dart';

class HistoryOrderList extends StatelessWidget {
  final int length;

  const HistoryOrderList(this.length);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: length,
      itemBuilder: (context, index) {
        return OrderCard(index);
      },
    );
  }
}
