import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';
import '../src.dart';

/// A provider specifically for [HistoryScreen]
class HistorySupplierByDate extends ChangeNotifier {
  final OrderIO? database;
  late List<Order> _list; // list instance of [data]
  late DateTimeRange _selectedRange;

  List<Order> get data => List.unmodifiable(_list);
  DateTimeRange get selectedRange => _selectedRange;

  set selectedRange(DateTimeRange newRange) {
    if (_selectedRange != newRange) {
      _selectedRange = newRange;
      _list = database?.getRange(_selectedRange.start, _selectedRange.end) ?? [];
      _sumAmount = _calculateTotalPriceAfterDiscount(data);
      notifyListeners();
    }
  }

  /// summary amount over the [_selectedRange]
  late double _sumAmount = 0;

  double get sumAmount => _sumAmount;

  HistorySupplierByDate({this.database, DateTimeRange? range}) {
    _selectedRange = range ??
        DateTimeRange(
          start: DateTime.now().add(Duration(days: -30)),
          end: DateTime.now(),
        );
    _list = database?.getRange(_selectedRange.start, _selectedRange.end) ?? [];
    _sumAmount = _calculateTotalPriceAfterDiscount(data);
  }

  Future<Order?> ignoreOrder(Order order, int index) async {
    _excludeOrderFromTotal(order);
    final ord = await database?.delete(order.checkoutTime, order.id);
    if (ord != null) {
      _list[index] = ord;
    }
    return ord;
  }

  double _excludeOrderFromTotal(Order order) {
    _sumAmount -= (order.totalPrice * order.discountRate);
    notifyListeners();
    return _sumAmount;
  }

  double _calculateTotalPriceAfterDiscount(Iterable<Order> orders) => orders.fold(
        0,
        (previousValue, e) =>
            previousValue + (e.isDeleted == true ? 0 : e.totalPrice * e.discountRate),
      );
}
