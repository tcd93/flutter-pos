import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';
import '../src.dart';

/// A provider specifically for [HistoryScreen]
class HistoryOrderSupplier extends ChangeNotifier implements DatePickerTemplate {
  final RIDRepository<Order>? database;
  late DateTimeRange _selectedRange;
  bool _discountFlag = true;

  bool _loading = false;
  bool get loading => _loading;

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  @override
  DateTimeRange get selectedRange => _selectedRange;

  @override
  set selectedRange(DateTimeRange newRange) {
    if (_selectedRange != newRange) {
      _selectedRange = newRange;
      _retrieveOrders();
    }
  }

  bool get discountFlag => _discountFlag;

  /// include discount rate in sales
  set discountFlag(toggleValue) {
    _discountFlag = toggleValue;
    notifyListeners();
  }

  HistoryOrderSupplier({this.database, DateTimeRange? range}) {
    _selectedRange = range ?? DateTimeRange(start: DateTime.now(), end: DateTime.now());
    _retrieveOrders();
  }

  /// Mark an order from history list as 'ignored'
  void ignoreOrder(Order order) async {
    await database?.delete(order);
    final copy = Order.create(fromBase: order, isDeleted: true);
    orders[orders.indexOf(order)] = copy;
    notifyListeners();
  }

  double calculateTotalSalesAmount(Iterable<Order> orders) => orders.fold(
        0,
        (previousValue, order) => previousValue + order.saleAmount(discountFlag),
      );

  void _retrieveOrders() {
    _loading = true;
    notifyListeners();
    database?.get(_selectedRange.start, _selectedRange.end).then((value) {
      _orders = value;
      _loading = false;
      notifyListeners();
    });
  }
}
