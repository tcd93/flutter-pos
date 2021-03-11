import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../common/common.dart';
import '../../printer/thermal_printer.dart';
import '../src.dart';

@immutable
class TableModel {
  final int id;

  final SlidingWindow<Order> _s;
  final Coordinate _coord;

  TableModel(this.id, [Coordinate? coord])
      : _s = SlidingWindow(2, [Order(id), Order(id)]),
        _coord = coord ?? Coordinate(0, 0);

  TableModel.withOrder(Order mockState, [Coordinate? coord])
      : _s = SlidingWindow(2, [mockState, Order.copy(mockState)]),
        id = mockState.tableID,
        _coord = coord ?? Coordinate(0, 0);

  TableStatus get status => _s.current.status;

  void setTableStatus(TableStatus newStatus, [Supplier? supplier]) {
    if (newStatus != _s.current.status) {
      _s.current.status = newStatus;
      supplier?.notifyListeners();
    }
  }

  LineItem putIfAbsent(Dish dish) {
    var s = _s.current.lineItems.firstWhere(
      (li) => li.associatedDish == dish,
      orElse: () {
        final newLine = LineItem(associatedDish: dish);
        _s.current.lineItems.add(newLine);
        return newLine;
      },
    );
    return s;
  }

  /// Get a list of current items with quantity > 0
  LineItemList get activeLineItems => _s.current.activeLines;

  int get totalMenuItemQuantity => activeLineItems.fold(0, (p, c) => p + c.quantity);

  double get totalPricePreDiscount => _s.current.totalPrice;

  double get totalPriceAfterDiscount => _s.current.totalPrice * _s.current.discountRate;

  double get discountPercent => (1 - _s.current.discountRate) * 100;

  void memorizePreviousState() {
    final copy = Order.copy(_s.current);
    _s.slideRight(copy);
  }

  /// Restore to last "commit" (called by [memorizePreviousState])
  void revert([Supplier? supplier]) {
    final copy = Order.copy(_s.first);
    _s.slideLeft(copy);
    supplier?.notifyListeners();
  }

  Future<int> _genNextID(Supplier supplier) async {
    return (await supplier.database?.nextUID()) ?? -1;
  }

  Future<void> _checkout(Supplier supplier, [DateTime? atTime]) async {
    final database = supplier.database;

    _s.current.id = await _genNextID(supplier);
    _s.current.checkoutTime = atTime ?? DateTime.now();

    await database?.insert(_s.current);

    supplier.notifyListeners();
  }

  //TODO: implement store name, set it in the receipt header
  Future<void> _printReceipt(BuildContext context, [double? customerPayAmount]) async {
    return Printer.print(context, _s.current, customerPayAmount);
  }

  void _clear() {
    _s.lst = [Order(id), Order(id)];
  }

  /// checkout, print receipt (not for Web), then clear the node's state
  ///
  /// - if [supplier] null then this does not persist to storage
  /// - if [context] null or on Web then it does not print receipt paper, [customerPayAmount] will be
  /// printed if not null
  /// - state is always cleared after calling this method
  Future<void> checkoutPrintClear({
    Supplier? supplier,
    DateTime? atTime,
    BuildContext? context,
    double? customerPayAmount,
  }) async {
    if (supplier != null) await _checkout(supplier, atTime);
    if (context != null && !kIsWeb) await _printReceipt(context, customerPayAmount);
    _clear();
  }

  double applyDiscount(double discountRate, Supplier? supplier) {
    assert(0 < discountRate && discountRate <= 1);
    _s.current.discountRate = discountRate;
    supplier?.notifyListeners();
    return totalPriceAfterDiscount;
  }

  /// current global X, Y pos on screen
  Coordinate getOffset() => _coord;

  void setOffset(Coordinate newCoord, Supplier? supplier) {
    if (newCoord.x == _coord.y && newCoord.y == _coord.y) return;
    _coord.x = newCoord.x;
    _coord.y = newCoord.y;
    final database = supplier?.database;
    database?.setCoordinate(id, newCoord.x, newCoord.y);
  }
}
