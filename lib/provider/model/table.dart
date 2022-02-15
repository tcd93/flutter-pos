import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../storage_engines/connection_interface.dart';
import '../../common/common.dart';
import '../../printer/thermal_printer.dart';
import '../src.dart';

// a 'wrapper' around the core state Node object
// implements the business logic here

@immutable
class TableModel {
  final Node node;

  int get id => node.id;

  final SlidingWindow<Order> _s;
  Order get _currentOrder => _s.first;

  TableModel([Node? node])
      : _s = SlidingWindow([Order.create(), Order.create()]),
        node = node ?? Node(page: 0);

  TableModel.withOrder(Order order, [Node? node])
      : _s = SlidingWindow([Order.create(fromBase: order), Order.create(fromBase: order)]),
        node = node ?? Node(page: 0);

  TableStatus get status => _currentOrder.status;

  LineItem putIfAbsent(Dish dish) {
    var s = _currentOrder.lineItems.firstWhere(
      (li) => li.associatedDish == dish,
      orElse: () {
        final newLine = LineItem(associatedDish: dish);
        _currentOrder.lineItems.add(newLine);
        return newLine;
      },
    );
    return s;
  }

  LineItem? getByDish(Dish dish) {
    final lines = _currentOrder.lineItems.where((d) => d.associatedDish == dish);
    return lines.isNotEmpty ? lines.first : null;
  }

  /// Get a list of current items with quantity > 0
  LineItemList get activeLineItems => _currentOrder.activeLines;

  int get totalMenuItemQuantity => activeLineItems.fold(0, (p, c) => p + c.quantity);

  double get totalPricePreDiscount => _currentOrder.totalPrice;

  double get totalPriceAfterDiscount => _currentOrder.totalPrice * _currentOrder.discountRate;

  double get discountPercent => (1 - _currentOrder.discountRate) * 100;

  void memorizePreviousState() {
    final copy = Order.create(fromBase: _currentOrder);
    _s.slideLeft(copy);
  }

  /// Restore to last "commit" (called by [memorizePreviousState])
  void revert() {
    final copy = Order.create(fromBase: _currentOrder);
    _s.slideRight(copy);
  }

  Future<void> checkout([RIRepository<Order>? repo, DateTime? atTime]) async {
    final _t = Order.create(
      fromBase: _currentOrder,
      checkoutTime: atTime ?? DateTime.now(),
    ); // without ID
    final order = await repo?.insert(_t) ?? _t;
    _s.replaceFirst(order);
  }

  Future<void> _printReceipt(BuildContext context, [double? customerPayAmount]) async {
    return Printer.print(context, _currentOrder, customerPayAmount);
  }

  void _clear() {
    _s.slideRight(Order.create());
    _s.slideRight(Order.create());
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

  void applyStatus(TableStatus newStatus) {
    if (newStatus == _currentOrder.status) return;
    _s.replaceFirst(Order.create(fromBase: _currentOrder, status: newStatus));
  }

  double applyDiscount(double discountRate) {
    assert(0 < discountRate && discountRate <= 1);
    _s.replaceFirst(Order.create(fromBase: _currentOrder, discountRate: discountRate));
    return totalPriceAfterDiscount;
  }

  /// {'x': double, 'y': double}
  Map<String, double> getOffset() => {'x': node.x, 'y': node.y};

  void setOffset(double x, double y, RIUDRepository<Node>? db) {
    if (node.x == y && node.y == y) return;
    node.x = x;
    node.y = y;
    db?.update(node);
  }
}
