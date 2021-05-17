import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';
import '../src.dart';

/// A provider specifically for [HistoryScreen]
abstract class HistoryOrderSupplier extends ChangeNotifier {
  final OrderIO? database;
  late List<Order> data; // list instance of [data]
  late DateTimeRange _selectedRange;

  DateTimeRange get selectedRange => _selectedRange;

  set selectedRange(DateTimeRange newRange) {
    if (_selectedRange != newRange) {
      _selectedRange = newRange;
      data = database?.getRange(_selectedRange.start, _selectedRange.end) ?? [];
      sumAmount = _calculateTotalPriceAfterDiscount(data);
      notifyListeners();
    }
  }

  /// summary amount over the [_selectedRange]
  late double sumAmount = 0;

  HistoryOrderSupplier({this.database, DateTimeRange? range}) {
    _selectedRange = range ??
        DateTimeRange(
          start: DateTime.now().add(Duration(days: -30)),
          end: DateTime.now(),
        );
    data = database?.getRange(_selectedRange.start, _selectedRange.end) ?? [];
    sumAmount = _calculateTotalPriceAfterDiscount(data);
  }

  double _calculateTotalPriceAfterDiscount(Iterable<Order> orders) => orders.fold(
        0,
        (previousValue, e) =>
            previousValue + (e.isDeleted == true ? 0 : e.totalPrice * e.discountRate),
      );
}
