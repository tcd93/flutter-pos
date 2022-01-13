import 'package:flutter/material.dart';

import '../../storage_engines/connection_interface.dart';
import '../src.dart';

/// First tab
class HistorySupplierByDate extends HistoryOrderSupplier {
  HistorySupplierByDate({OrderIO? database, DateTimeRange? range})
      : super(database: database, range: range);

  /// Mark an order from history list as 'ignored'
  void ignoreOrder(Order order) async {
    await database?.delete(order.checkoutTime, order.id);
    notifyListeners();
  }
}
