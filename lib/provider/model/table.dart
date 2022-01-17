// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../storage_engines/connection_interface.dart';
import '../../common/common.dart';
import '../../printer/thermal_printer.dart';
import '../src.dart';

@immutable
class TableModel {
  final int id;
  final Coordinate _coord;

  final SlidingWindow<Order> _s;
  Order get currentOrder => _s.first;

  TableModel(this.id, [Coordinate? coord])
      : _s = SlidingWindow([Order.create(tableID: id), Order.create(tableID: id)]),
        _coord = coord ?? Coordinate(0, 0);

  TableModel.withOrder(Order order, [Coordinate? coord])
      : _s = SlidingWindow([Order.create(fromBase: order), Order.create(fromBase: order)]),
        id = order.tableID,
        _coord = coord ?? Coordinate(0, 0);

  TableStatus get status => currentOrder.status;

  void setTableStatus(TableStatus newStatus, [ChangeNotifier? notifier]) {
    if (newStatus != _s.first.status) {
      _s.replaceFirst(Order.create(fromBase: currentOrder, status: newStatus));
      notifier?.notifyListeners();
    }
  }

  LineItem putIfAbsent(Dish dish) {
    var s = currentOrder.lineItems.firstWhere(
      (li) => li.associatedDish == dish,
      orElse: () {
        final newLine = LineItem(associatedDish: dish);
        currentOrder.lineItems.add(newLine);
        return newLine;
      },
    );
    return s;
  }

  /// Get a list of current items with quantity > 0
  LineItemList get activeLineItems => currentOrder.activeLines;

  int get totalMenuItemQuantity => activeLineItems.fold(0, (p, c) => p + c.quantity);

  double get totalPricePreDiscount => currentOrder.totalPrice;

  double get totalPriceAfterDiscount => currentOrder.totalPrice * currentOrder.discountRate;

  double get discountPercent => (1 - currentOrder.discountRate) * 100;

  void memorizePreviousState() {
    final copy = Order.create(fromBase: currentOrder);
    _s.slideLeft(copy);
  }

  /// Restore to last "commit" (called by [memorizePreviousState])
  void revert([ChangeNotifier? notifier]) {
    final copy = Order.create(fromBase: currentOrder);
    _s.slideRight(copy);
    notifier?.notifyListeners();
  }

  Future<void> _printReceipt(BuildContext context, [double? customerPayAmount]) async {
    return Printer.print(context, currentOrder, customerPayAmount);
  }

  void _clear() {
    _s.slideRight(Order.create(tableID: -1));
    _s.slideRight(Order.create(tableID: -1));
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

  double applyDiscount(double discountRate, ChangeNotifier? notifier) {
    assert(0 < discountRate && discountRate <= 1);
    _s.replaceFirst(Order.create(fromBase: currentOrder, discountRate: discountRate));
    notifier?.notifyListeners();
    return totalPriceAfterDiscount;
  }

  /// current global X, Y pos on screen
  Coordinate getOffset() => _coord;

  void setOffset(Coordinate newCoord, CoordinateIO? db) {
    if (newCoord.x == _coord.y && newCoord.y == _coord.y) return;
    _coord.x = newCoord.x;
    _coord.y = newCoord.y;
    db?.setCoordinate(id, newCoord.x, newCoord.y);
  }
}
