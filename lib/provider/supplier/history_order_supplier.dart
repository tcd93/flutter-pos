import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';
import '../src.dart';

/// A provider specifically for [HistoryScreen]
abstract class HistoryOrderSupplier extends ChangeNotifier {
  final OrderIO? database;
  late List<Order> data; // list instance of [data]
  late DateTimeRange _selectedRange;
  bool _discountFlag = true;

  DateTimeRange get selectedRange => _selectedRange;

  set selectedRange(DateTimeRange newRange) {
    if (_selectedRange != newRange) {
      _selectedRange = newRange;
      data = database?.getRange(_selectedRange.start, _selectedRange.end) ?? [];
      sumAmount = _calculateTotalSalesAmount(data);
      notifyListeners();
    }
  }

  bool get discountFlag => _discountFlag;

  /// include discount rate in sales
  set discountFlag(toggleValue) {
    _discountFlag = toggleValue;
    sumAmount = _calculateTotalSalesAmount(data);
    notifyListeners();
  }

  /// summary amount over the [_selectedRange]
  late double sumAmount = 0;

  double saleAmountOf(Order order) =>
      order.isDeleted == true ? 0 : order.totalPrice * (discountFlag ? order.discountRate : 1.0);

  HistoryOrderSupplier({this.database, DateTimeRange? range}) {
    _selectedRange = range ??
        DateTimeRange(
          start: DateTime.now().add(Duration(days: -30)),
          end: DateTime.now(),
        );
    data = database?.getRange(_selectedRange.start, _selectedRange.end) ?? [];
    sumAmount = _calculateTotalSalesAmount(data);
  }

  double _calculateTotalSalesAmount(Iterable<Order> orders) => orders.fold(
        0,
        (previousValue, order) => previousValue + saleAmountOf(order),
      );
}
