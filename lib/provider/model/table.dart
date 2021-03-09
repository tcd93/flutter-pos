import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../common/common.dart';
import '../../printer/thermal_printer.dart';
import '../../storage_engines/connection_interface.dart';
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

  int get totalMenuItemQuantity => _s.current.lineItems.fold(
        0,
        (previousValue, element) => previousValue + element.quantity,
      );

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

  Future<StateObject> checkout({required Supplier supplier, DateTime? atTime}) async {
    final database = supplier.database;

    if (database != null) {
      final nextID = await database.nextUID();
      _s.current.id = nextID;
    }
    _s.current.checkoutTime = atTime ?? DateTime.now();

    await database?.insert(_s.current);

    final copiedState = Order.copy(_s.current);

    _s.lst = [Order(id), Order(id)]; // clear current state
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
    _coord.x = newCoord.x;
    _coord.y = newCoord.y;
    final database = supplier?.database;
    database?.setCoordinate(id, newCoord.x, newCoord.y);
  }
}

class Order extends StateObject {
  /// The associated table id
  final int tableID;

  TableStatus status = TableStatus.empty;

  /// "soft-deleted", interactable only in [HistoryScreen]
  bool isDeleted;

  Order(this.tableID) : isDeleted = false;

  /// copy to a new instance (except [orderID])
  Order.copy(Order base)
      : tableID = base.tableID,
        isDeleted = base.isDeleted,
        status = base.status {
    lineItems = LineItemList.copy(base.lineItems);
    checkoutTime = base.checkoutTime;
    discountRate = base.discountRate;
  }

  Order.create({
    required this.tableID,
    required LineItemList lineItems,
    int orderID = -1,
    DateTime? checkoutTime,
    double discountRate = 1.0,
    this.status = TableStatus.empty,
    this.isDeleted = false,
  }) {
    assert(discountRate > 0.0 && discountRate <= 1.0);
    super.lineItems = lineItems;
    super.checkoutTime = checkoutTime ?? DateTime.parse('1999-01-01');
    super.discountRate = discountRate;
    if (orderID > -1) id = orderID;
  }

  Order.fromJson(Map<String, dynamic> json)
      : tableID = json['tableID'] ?? -1,
        isDeleted = json['isDeleted'] ?? false,
        super.create(
          json['orderID'],
          LineItemList.fromJson(json['lineItems']),
          json['discountRate'],
          DateTime.parse(json['checkoutTime']),
        );

  Map<String, dynamic> toJson() {
    var lineItemList = LineItemList(lineItems.where((l) => l.isBeingOrdered()));

    return {
      'tableID': tableID,
      'lineItems': lineItemList.toJson(),
      'orderID': id,
      'checkoutTime': checkoutTime.toString(),
      'discountRate': discountRate,
      'isDeleted': isDeleted,
    };
  }

  @override
  String toString() => toJson().toString();
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
