import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../common/common.dart';
import '../../printer/thermal_printer.dart';
import '../../storage_engines/connection_interface.dart';

import '../src.dart';

class OrderSupplier extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  final RIDRepository<Order>? database;

  late final SlidingWindow<Order> _s;

  /// The current order
  Order get order => _s.first;

  OrderSupplier({this.database, Order? order}) {
    _loading = true;
    if (order != null) {
      _s = SlidingWindow([order, order]);
    } else {
      _s = SlidingWindow([Order.create(tableID: -1), Order.create(tableID: -1)]);
    }
    notifyListeners();
    Future(() async {
      // TODO: get the order directly from db, ex: (await database?.get(node))
      _loading = false;
      notifyListeners();
    });
  }

  /// Get a list of current items with quantity > 0
  LineItemList get activeLineItems => order.activeLines;

  double get discountPercent => (1 - order.discountRate) * 100;

  int get totalMenuItemQuantity => activeLineItems.fold(0, (p, c) => p + c.quantity);

  double get totalPricePreDiscount => order.totalPrice;

  double get totalPriceAfterDiscount => order.totalPrice * order.discountRate;

  void memorizePreviousState() {
    final copy = Order.create(fromBase: order);
    _s.slideLeft(copy);
  }

  void setStatus(TableStatus newStatus) {
    _s.replaceFirst(Order.create(fromBase: order, status: newStatus));
    notifyListeners();
  }

  /// Restore to last "commit" (called by [memorizePreviousState])
  void revert() {
    final copy = Order.create(fromBase: order);
    _s.slideRight(copy);
    notifyListeners();
  }

  LineItem? getByDish(Dish dish) {
    final lines = order.lineItems.where((d) => d.associatedDish == dish);
    return lines.isNotEmpty ? lines.first : null;
  }

  LineItem putIfAbsent(Dish dish) {
    var s = order.lineItems.firstWhere(
      (li) => li.associatedDish == dish,
      orElse: () {
        final newLine = LineItem(associatedDish: dish);
        order.lineItems.add(newLine);
        return newLine;
      },
    );
    notifyListeners();
    return s;
  }

  /// print receipt (not for Web), then clear the node's state
  ///
  /// - if [context] null or on Web then it does not print receipt paper, [customerPayAmount] will be
  /// printed if not null
  /// - state is always cleared after calling this method
  Future<void> printClear({
    BuildContext? context,
    double? customerPayAmount,
  }) async {
    if (context != null && !kIsWeb) await _printReceipt(context, customerPayAmount);
    _clear();
  }

  Future<void> _printReceipt(BuildContext context, [double? customerPayAmount]) async {
    return Printer.print(context, order, customerPayAmount);
  }

  Future<void> checkout([DateTime? atTime]) async {
    final t = Order.create(
      fromBase: order,
      checkoutTime: atTime ?? DateTime.now(),
    ); // without ID
    final o = await database?.insert(t) ?? t;
    _s.replaceFirst(o);
    notifyListeners();
  }

  void _clear() {
    _s.slideRight(Order.create(tableID: order.tableID));
    _s.slideRight(Order.create(tableID: order.tableID));
    notifyListeners();
  }

  void setDiscount(double discountRate) {
    assert(0 < discountRate && discountRate <= 1);
    _s.replaceFirst(Order.create(fromBase: order, discountRate: discountRate));
    notifyListeners();
  }
}
