import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    if (order == null) order = {}; // weird that I can't set default value...
  }

  TableStatus status;

  /// The order associated with a table.
  /// This is a [Map<int, Order>] where the key is the [Dish] item id
  Map<int, Order> order;

  /// Keep track of state history, overwrite snapshot everytime the confirm
  /// button is clicked
  _State previousState;

  /// Create a cloned [_State] object
  _State copy() => _State(
      status,
      Map.fromIterable(
        order.keys,
        key: (key) => key,
        value: (key) {
          var copiedOrder = Order(dishID: key);
          copiedOrder.quantity = order[key].quantity;
          return copiedOrder;
        },
      ));

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
    if (newStatus == TableStatus.occupied) {
      _tableState.previousState = _tableState.copy();
      debugPrint('    Set previous state: \n    ${_tableState.previousState.toString()}');
    }
    _tableState.status = newStatus;
    _tracker.notifyListeners();
  }

  /// Get [Order] from menu list, [dishID] is the index of Menu list
  Order orderOf(int dishID) => _tableState.order[dishID];

  /// Try putting new [Order] at the order associated with current table
  Order putOrderIfAbsent(int dishID) =>
      _tableState.order.putIfAbsent(dishID, () => Order(dishID: dishID));

  /// Returns total items (number of dishes) of current table
  int orderCount() => _tableState.order.entries.fold(
        0,
        (previousValue, element) => previousValue + element.value.quantity,
      );

  /// Restore to last "commit"
  void revert() {
    debugPrint('    Reverting table state back to: \n    ${_tableState.previousState.toString()}');
    _tableState.status = _tableState.previousState.status;
    _tableState.order = _tableState.previousState.order;
    _tracker.notifyListeners();
  }
}
