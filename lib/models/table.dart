import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../common/common.dart';

import 'dish.dart';
import 'order.dart';
import 'tracker.dart';

enum TableStatus {
  /// No one is sitting at this table
  empty,

  /// Dining
  occupied,

  /// Incomplete order
  incomplete,
}

/// The separate "state" of the immutable [TableModel] class
class _State {
  _State([this.status = TableStatus.empty, this.order]) {
    // create an `order` (of quantity 0) to very item on `menu`
    if (order == null) {
      order = {
        for (var dish in Dish.getMenu())
          dish.id: Order(
            dishID: dish.id,
            quantity: 0,
          )
      };

      previousOrder = {
        for (var dish in Dish.getMenu())
          dish.id: Order(
            dishID: dish.id,
            quantity: 0,
          )
      };
    }
    ; // weird that I can't set default value...
  }

  TableStatus status;

  /// The order associated with a table.
  /// This is a [Map<int, Order>] where the key is the [Dish] item id
  Map<int, Order> order;

  /// Keep track of state history, overwrite snapshot everytime the confirm
  /// button is clicked
  Map<int, Order> previousOrder;

  @override
  String toString() {
    return '{status: ${status.toString()}, order: ${order.toString()}}';
  }
}

@immutable
class TableModel {
  final OrderTracker _tracker;
  final int id;

  final _State _tableState = _State();

  // ignore: type_annotate_public_apis
  operator ==(other) => other is TableModel && other.id == id;
  int get hashCode => id;

  TableModel(this._tracker, this.id);

  /// Returns current [TableStatus]
  TableStatus getTableStatus() => _tableState.status;

  /// Set [TableStatus], notify listeners to rebuild widget
  void setTableStatus(TableStatus newStatus) {
    _tableState.status = newStatus;
    _tracker.notifyListeners();
  }

  /// Store current state for rollback operation
  void memorizePreviousState() {
    _tableState.previousOrder = Common.cloneMap<int, Order>(
      _tableState.order,
      (key, value) => Order(
        dishID: key,
        quantity: value.quantity,
      ),
    );
    debugPrint(
        '    Set previous state: \n    ${_tableState.previousOrder.toString()}\n');
  }

  /// Get [Order] from menu list, [dishID] is the index of Menu list
  Order orderOf(int dishID) => _tableState.order[dishID];

  /// Try putting new [Order] at the order associated with current table
  Order putOrderIfAbsent(int dishID) =>
      _tableState.order.putIfAbsent(dishID, () => Order(dishID: dishID));

  /// Get a list of current [Order] (with quantity > 0)
  UnmodifiableListView<Order> orders() {
    return UnmodifiableListView(
      _tableState.order.entries
          .where((entry) => entry.value.quantity > 0)
          .map((entry) => entry.value),
    );
  }

  /// Returns total items (number of dishes) of current table
  int totalMenuItemQuantity() => _tableState.order.entries.fold(
        0,
        (previousValue, element) => previousValue + element.value.quantity,
      );

  /// Restore to last "commit"
  void revert() {
    // if has not "commit", revert back to all "0"
    if (_tableState.previousOrder == null) {}
    debugPrint(
        '    Reverting table state back to: \n    ${_tableState.previousOrder.toString()}\n');
    _tableState.status = TableStatus.occupied;
    // overwrite current `order` state.
    // has to do cloning here to not bind the reference of previous [Order]s to current state
    _tableState.order = Common.cloneMap<int, Order>(
      _tableState.previousOrder,
      (key, value) => Order(
        dishID: key,
        quantity: value.quantity,
      ),
    );
    _tracker.notifyListeners();
  }
}
