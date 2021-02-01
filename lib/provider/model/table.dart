import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../common/common.dart';
import '../../printer/thermal_printer.dart';
import '../../storage_engines/connection_interface.dart';
import '../src.dart';

@immutable
class TableModel {
  final Supplier _tracker;
  final int id;

  final SlidingWindow<_TableState> _s;
  final Coordinate _coord;

  TableModel(this._tracker, this.id, [StateObject mockState])
      : _coord = Coordinate.fromDB(id, _tracker?.database),
        _s = mockState != null
            ? SlidingWindow(
                2,
                [_TableState.downcast(id, mockState), _TableState.downcast(id, mockState)],
              )
            : SlidingWindow(2, [_TableState(id), _TableState(id)]);

  TableStatus get status => _s.current.status;

  void setTableStatus(TableStatus newStatus) {
    if (newStatus != _s.current.status) {
      _s.current.status = newStatus;
      _tracker?.notifyListeners();
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

  /// Get a list of current [lineItems] (with quantity > 0)
  List<LineItem> get lineItems =>
      _s.current.lineItems.where((entry) => entry.isBeingOrdered()).toList();

  int get totalMenuItemQuantity => _s.current.lineItems.fold(
        0,
        (previousValue, element) => previousValue + element.quantity,
      );

  double get totalPricePreDiscount => _s.current.totalPrice;

  double get totalPriceAfterDiscount => _s.current.totalPrice * _s.current.discountRate;

  double get discountPercent => (1 - _s.current.discountRate) * 100;

  void memorizePreviousState() {
    final copy = _TableState.copy(_s.current);
    _s.slideRight(copy);
  }

  /// Restore to last "commit" (called by [memorizePreviousState])
  void revert() {
    final copy = _TableState.copy(_s.first);
    _s.slideLeft(copy);
    _tracker?.notifyListeners();
  }

  Future<TableModel> checkout({DateTime atTime}) async {
    final database = _tracker?.database;

    _s.current.orderID = await database?.nextUID();
    _s.current.checkoutTime = atTime ?? DateTime.now();

    await database?.insert(_s.current);

    // this is a bit hacky, but we need to keep a state for printing...
    final copy = _TableState.copy(_s.current);

    _s.lst = [_TableState(id), _TableState(id)]; // clear current state
    _tracker?.notifyListeners();
    return TableModel(null, id, copy);
  }

  //TODO: implement store name, set it in the receipt header
  Future<void> printReceipt(BuildContext context, [double customerPayAmount]) async {
    if (!kIsWeb) {
      return Printer.print(context, _s.current, customerPayAmount);
    }
  }

  double applyDiscount(double discountRate) {
    assert(0 < discountRate && discountRate <= 1);
    _s.current.discountRate = discountRate;
    return totalPriceAfterDiscount;
  }

  /// current global X, Y pos on screen
  Coordinate get offset => _coord;

  set offset(Coordinate newCoord) {
    if (newCoord.x == _coord.y && newCoord.y == _coord.y) return;
    final database = _tracker?.database;
    database?.setCoordinate(id, newCoord.x, newCoord.y);
  }
}

class _TableState extends StateObject {
  /// The associated table id
  final int tableID;

  TableStatus status = TableStatus.empty;

  _TableState(this.tableID);

  _TableState.downcast(this.tableID, StateObject base) {
    lineItems = base.lineItems
        .map((l) => LineItem(
              associatedDish: l.associatedDish,
              quantity: l.quantity,
            ))
        .toList();
    checkoutTime = base.checkoutTime;
    discountRate = base.discountRate;
    if (base.orderID != null) {
      orderID = base.orderID;
    }
  }

  _TableState.copy(_TableState base) : tableID = base.tableID ?? -1 {
    lineItems = base.lineItems
        .map((l) => LineItem(
              associatedDish: l.associatedDish,
              quantity: l.quantity,
            ))
        .toList();
    status = base.status;
    checkoutTime = base.checkoutTime;
    discountRate = base.discountRate;
    if (base.orderID != null) {
      orderID = base.orderID;
    }
  }
}

/// the current global X, Y position of this table node
class Coordinate {
  double x, y;
  Coordinate(this.x, this.y);
  Coordinate.fromDB(int tableID, DatabaseConnectionInterface database) {
    x = database?.getX(tableID) ?? 0;
    y = database?.getY(tableID) ?? 0;
  }
}
