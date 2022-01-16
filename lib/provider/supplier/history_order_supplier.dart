import 'package:flutter/material.dart';
import '../../common/common.dart';
import '../../storage_engines/connection_interface.dart';
import '../src.dart';

/// A provider specifically for [HistoryScreen]
class HistoryOrderSupplier extends ChangeNotifier {
  final OrderIO? database;
  late DateTimeRange _selectedRange;
  bool _discountFlag = true;

  bool _loading = false;
  bool get loading => _loading;

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  DateTimeRange get selectedRange => _selectedRange;

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
    await database?.delete(order.checkoutTime, order.id);
    // don't directly modify order object as this will make the 'selector' from Provider
    // unable to compare states
    final copy = Order.copy(order);
    copy.isDeleted = true;
    // copy.id = order.id; TODO: ???
    final i = orders.indexOf(order);
    orders.replaceRange(i, i + 1, [copy]);

    notifyListeners();
  }

  /// Returns a list of grouped orders:
  ///   - If ranges over multiple days, then group by day: [['YYYY/MM/DD', value]]
  ///   - If ranges over one day, the group by time: [['HH24:MM', value]]
  ///
  /// The outer list is for indexing the X axis (time).
  /// The nested inner list is for marking the display titles and values
  List<List<dynamic>> group() {
    return orders.fold(
      [],
      (obj, o) {
        String xAxis;
        if (selectedRange.duration.inDays > 1) {
          xAxis = Common.extractYYYYMMDD2(o.checkoutTime);
        } else {
          xAxis = _extractTime(o.checkoutTime);
        }
        final match = obj.firstWhere(
          (element) => element.isNotEmpty && element.first == xAxis,
          orElse: () {
            final newObj = [xAxis, 0];
            obj.add(newObj);
            return newObj;
          },
        );
        match[1] += o.saleAmount(discountFlag);
        return obj;
      },
    );
  }

  double calculateTotalSalesAmount(Iterable<Order> orders) => orders.fold(
        0,
        (previousValue, order) => previousValue + order.saleAmount(discountFlag),
      );

  String _extractTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}'
        ':'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _retrieveOrders() {
    _loading = true;
    notifyListeners();
    database?.getRange(_selectedRange.start, _selectedRange.end).then((value) {
      _orders = value;
      _loading = false;
      notifyListeners();
    });
  }
}
