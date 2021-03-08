import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../common/common.dart';
import '../../printer/thermal_printer.dart';
import '../../storage_engines/connection_interface.dart';
import '../src.dart';

@immutable
class TableModel {
  final int id;

  final SlidingWindow<TableState> _s;
  late final Coordinate _coord;

  TableModel(this.id, [TableState? mockState, Coordinate? coord])
      : _s = mockState != null
            ? SlidingWindow(2, [mockState, TableState.copy(mockState)])
            : SlidingWindow(2, [TableState(id), TableState(id)]),
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
    final copy = TableState.copy(_s.current);
    _s.slideRight(copy);
  }

  /// Restore to last "commit" (called by [memorizePreviousState])
  void revert([Supplier? supplier]) {
    final copy = TableState.copy(_s.first);
    _s.slideLeft(copy);
    supplier?.notifyListeners();
  }

  Future<StateObject> checkout({required Supplier supplier, DateTime? atTime}) async {
    final database = supplier.database;

    if (database != null) {
      final nextID = await database.nextUID();
      _s.current.orderID = nextID;
    }
    _s.current.checkoutTime = atTime ?? DateTime.now();

    await database?.insert(_s.current);

    final copiedState = TableState.copy(_s.current);

    _s.lst = [TableState(id), TableState(id)]; // clear current state
    supplier.notifyListeners();
    return copiedState;
  }

  //TODO: implement store name, set it in the receipt header
  Future<void> printReceipt(
    BuildContext context, [
    double? customerPayAmount,
    StateObject? withState,
  ]) async {
    if (!kIsWeb) {
      return Printer.print(context, withState ?? _s.current, customerPayAmount);
    }
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
    final database = supplier?.database;
    database?.setCoordinate(id, newCoord.x, newCoord.y);
  }
}

class TableState extends StateObject {
  /// The associated table id
  final int tableID;

  TableStatus status = TableStatus.empty;

  TableState(this.tableID);

  /// copy to a new instance (except [orderID])
  TableState.copy(TableState base) : tableID = base.tableID {
    lineItems = base.lineItems
        .map((l) => LineItem(
              associatedDish: l.associatedDish,
              quantity: l.quantity,
            ))
        .toList();
    status = base.status;
    checkoutTime = base.checkoutTime;
    discountRate = base.discountRate;
  }

  TableState.mock(
    this.tableID,
    List<LineItem> lineItems, {
    int orderID = -1,
    DateTime? checkoutTime,
    double discountRate = 1.0,
    this.status = TableStatus.empty,
  }) {
    assert(discountRate > 0.0 && discountRate <= 1.0);
    super.lineItems = lineItems;
    super.checkoutTime = checkoutTime ?? DateTime.parse('1999-01-01');
    super.discountRate = discountRate;
  }
}

/// the current global X, Y position of this table node
class Coordinate {
  late double x = 0, y = 0;
  Coordinate(this.x, this.y);
  Coordinate.fromDB(int tableID, DatabaseConnectionInterface database) {
    x = database.getX(tableID);
    y = database.getY(tableID);
  }
}
