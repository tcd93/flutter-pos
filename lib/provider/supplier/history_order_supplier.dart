import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';
import '../src.dart';

/// A provider specifically for [HistoryScreen]
abstract class HistoryOrderSupplier extends ChangeNotifier {
  final OrderIO? database;
  late DateTimeRange _selectedRange;
  bool _discountFlag = true;

  DateTimeRange get selectedRange => _selectedRange;

  set selectedRange(DateTimeRange newRange) {
    if (_selectedRange != newRange) {
      _selectedRange = newRange;
      notifyListeners();
    }
  }

  bool get discountFlag => _discountFlag;

  /// include discount rate in sales
  set discountFlag(toggleValue) {
    _discountFlag = toggleValue;
    notifyListeners();
  }

  Future<List<Order>> retrieveOrders() async {
    return await database?.getRange(_selectedRange.start, _selectedRange.end) ?? [];
  }

  HistoryOrderSupplier({this.database, DateTimeRange? range}) {
    _selectedRange = range ?? DateTimeRange(start: DateTime.now(), end: DateTime.now());
  }

  double saleAmountOf(Order order) =>
      order.isDeleted == true ? 0 : order.totalPrice * (discountFlag ? order.discountRate : 1.0);

  double calculateTotalSalesAmount(Iterable<Order> orders) => orders.fold(
        0,
        (previousValue, order) => previousValue + saleAmountOf(order),
      );
}
