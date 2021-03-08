import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import './order_card.dart';
import '../../provider/src.dart';
import '../../storage_engines/connection_interface.dart';

class HistoryOrderList extends StatelessWidget {
  final DatabaseConnectionInterface database;
  final ValueListenable<DateTimeRange> listenableRange;
  final ValueNotifier<double> amountNotifier;

  const HistoryOrderList(this.database, this.listenableRange, this.amountNotifier);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTimeRange>(
      valueListenable: listenableRange, // rebuild list when selected range changes
      builder: (_, range, __) {
        final data = database.getRange(range.start, range.end);
        // update price (notify rebuild on AppBar) when list building is done
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          amountNotifier.value = _calculateTotalPriceAfterDiscount(data);
        });

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return OrderCard(
              data[index],
              database,
              onDeleted: (deletedOrder) {
                amountNotifier.value -= (deletedOrder.totalPrice * deletedOrder.discountRate);
              },
            );
          },
        );
      },
    );
  }
}

double _calculateTotalPriceAfterDiscount(List<Order> orders) => orders.fold(
      0,
      (previousValue, e) =>
          previousValue + (e.isDeleted == true ? 0 : e.totalPrice * e.discountRate),
    );
