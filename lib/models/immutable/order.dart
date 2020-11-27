import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../storage_engines/connection_interface.dart';
import '../line_item.dart';
import '../state/state_object.dart';
import '../supplier.dart';
import '../table.dart';

/// The order snapshot, can not be affected by changes from menu editor
class Order implements StateObject {
  final int tableID;

  @override
  int orderID;

  DateTime checkoutTime;

  final int price;

  final List<OrderItem> lineItems;

  final bool isDeleted;

  Order(
    this.tableID,
    this.orderID,
    this.checkoutTime,
    this.price,
    this.lineItems, {
    this.isDeleted = false,
  });

  @override
  set lineItems(List<LineItem> _lineItems) => throw 'Can not set LineItem from an Order instance';

  @override
  int get totalPrice => lineItems
      ?.where((entry) => entry.isBeingOrdered())
      ?.fold(0, (prev, order) => prev + (order.price * order.quantity));

  @override
  int get totalQuantity => lineItems.fold(0, (prevValue, item) => prevValue + item.quantity);

  /// One of `context`, `supplier`, `database`, `model` parameter is required
  /// Someone should probably refactor this
  Future<void> checkout({
    DateTime atTime,
    TableModel model,
    BuildContext context,
    Supplier supplier,
    DatabaseConnectionInterface database,
  }) async {
    final _tracker = context?.read<Supplier>() ?? supplier;

    final _model = _tracker?.getTable(tableID) ?? model;
    assert(_model != null);

    orderID = await _tracker?.database?.nextUID() ?? await database?.nextUID();
    checkoutTime = atTime ?? DateTime.now();

    final db = _tracker?.database ?? database;
    await db?.insert(this);

    _model?.cleanState(); // clear state
    _tracker?.notifyListeners();
  }

  // TODO: implement `printReceipt`
  Future<void> printReceipt() async {
    print('----- PRINT -----');
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  String toString() {
    return '$orderID: {$price, ${checkoutTime.toString()}, $lineItems, isDeleted: $isDeleted}';
  }
}

/// Menu items snapshot, goes hand-to-hand with [Order]
@immutable
class OrderItem implements LineItem {
  final int dishID;

  final String dishName;

  /// The recorded price
  final int price;

  final int quantity;

  OrderItem(this.dishID, this.dishName, this.quantity, this.price);

  @override
  set quantity(int v) => throw 'Can not modify history item';

  @override
  int addOne() => throw 'Can not modify history item';

  @override
  int substractOne() => throw 'Can not modify history item';

  @override
  bool isBeingOrdered() => quantity > 0;

  @override
  String toString() {
    return '[$dishID, $dishName, $quantity, ${price * quantity}]';
  }
}
