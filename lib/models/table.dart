import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../common/common.dart';

import 'dish.dart';
import 'line_item.dart';
import 'tracker.dart';

enum TableStatus {
  /// No one is sitting at this table
  empty,

  /// Dining
  occupied,

  /// Incomplete lineItem
  incomplete,
}

/// The separate "state" of the immutable [TableModel] class
class TableState {
  /// The associated table id
  final int tableID;
  int _orderID;

  /// The incremental unique ID (for reporting), should be generated when [checkout]
  int get orderID => _orderID;
  set orderID(int orderID) {
    assert(orderID != null, orderID > 0);
    _orderID = orderID;
  }

  TableStatus status;
  TableStatus previousStatus;
  DateTime checkoutTime;

  /// The lineItems associated with a table.
  /// This is a [Map<int, lineItems>] where the key is the [Dish] item id
  Map<int, LineItem> lineItems;

  /// Keep track of state history, overwrite snapshot everytime the confirm
  /// button is clicked
  Map<int, LineItem> previouslineItems;

  TableState(this.tableID) {
    cleanState();
  }

  /// set all line items to 0
  void cleanState() {
    status = TableStatus.empty;
    previousStatus = TableStatus.empty;
    lineItems = {
      for (var dish in Dish.getMenu())
        dish.id: LineItem(
          dishID: dish.id,
          quantity: 0,
        )
    };
    previouslineItems = {
      for (var dish in Dish.getMenu())
        dish.id: LineItem(
          dishID: dish.id,
          quantity: 0,
        )
    };
  }

  /// Total price of all line items in this order
  int totalPrice() => lineItems.entries
      .where((entry) => entry.value.quantity > 0)
      .map((entry) => entry.value)
      .fold(0, (prev, order) => prev + order.amount());

  /// Convert to JSON string object, line items with quantity > 0 are filtered
  ///
  /// @example:
  /// ```
  /// {
  ///   "orderID": 1,
  ///   "datetime": "2020-02-01 00:00:00.000",
  ///   "price": 100000,
  ///   "lineItems": [{"dishID": 1, "quantity": 5, "amount": 100000}]
  /// }
  /// ```
  String toJson() {
    var lineItemList = lineItems.values
        .where(
          (element) => element.quantity > 0,
        )
        .toList();

    return '{"orderID": $orderID, "datetime": "${checkoutTime.toString()}", "price": ${totalPrice()}, "lineItems": ${lineItemList.toString()}}';
  }

  @override
  String toString() => toJson();
}

@immutable
class TableModel {
  final OrderTracker _tracker;
  final int id;

  final TableState _tableState;

  // ignore: type_annotate_public_apis
  operator ==(other) => other is TableModel && other.id == id;
  int get hashCode => id;

  TableModel(this._tracker, this.id, [TableState mockState])
      : _tableState = mockState ?? TableState(id);

  /// Returns current [TableStatus]
  TableStatus getTableStatus() => _tableState.status;

  /// Set [TableStatus], notify listeners to rebuild widget
  void setTableStatus(TableStatus newStatus) {
    _tableState.status = newStatus;
    _tracker.notifyListeners();
  }

  /// Get [lineItems] from menu list
  LineItem lineItem(int index) => _tableState.lineItems[index];

  /// Get a list of current [lineItems] (with quantity > 0)
  UnmodifiableListView<LineItem> lineItems() {
    return UnmodifiableListView(
      _tableState.lineItems.entries
          .where((entry) => entry.value.quantity > 0)
          .map((entry) => entry.value),
    );
  }

  /// Returns total items (number of dishes) of current table
  int totalMenuItemQuantity() => _tableState.lineItems.entries.fold(
        0,
        (previousValue, element) => previousValue + element.value.quantity,
      );

  /// Total price of all line items in this order
  int totalPrice() => _tableState.totalPrice();

  /// Store current state for rollback operation
  void memorizePreviousState() {
    _tableState.previousStatus = _tableState.status;
    _tableState.previouslineItems = Common.cloneMap<int, LineItem>(
      _tableState.lineItems,
      (key, value) => LineItem(
        dishID: key,
        quantity: value.quantity,
      ),
    );
  }

  /// Restore to last "commit"
  void revert() {
    _tableState.status = _tableState.previousStatus;
    // overwrite current `lineItems` state.
    // has to do cloning here to not bind the reference of previous [lineItems]s to current state
    _tableState.lineItems = Common.cloneMap<int, LineItem>(
      _tableState.previouslineItems,
      (key, value) => LineItem(
        dishID: key,
        quantity: value.quantity,
      ),
    );
    _tracker.notifyListeners();
  }

  Future<void> checkout([DateTime atTime]) async {
    _tableState.orderID = await _tracker.database.nextUID();
    _tableState.checkoutTime = atTime ?? DateTime.now();
    await _tracker.database.insert(_tableState);
    _tableState.cleanState(); // clear state
    _tracker.notifyListeners();
  }
}
