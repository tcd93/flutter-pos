import 'package:flutter/material.dart';

import '../../storage_engines/connection_interface.dart';
import '../src.dart';

/// First tab
class HistorySupplierByDate extends HistoryOrderSupplier {
  HistorySupplierByDate({OrderIO? database, DateTimeRange? range})
      : super(database: database, range: range);

  Future<Order?> ignoreOrder(Order order, int index) async {
    _excludeOrderFromTotal(order);
    final ord = await database?.delete(order.checkoutTime, order.id);
    if (ord != null) {
      data[index] = ord;
    }
    return ord;
  }

  double _excludeOrderFromTotal(Order order) {
    sumAmount -= (order.totalPrice * order.discountRate);
    notifyListeners();
    return sumAmount;
  }
}
