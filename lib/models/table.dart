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
  TableStatus status = TableStatus.empty;

  /// The order associated with a table.
  /// This is a [Map<int, Order>] where the key is the [Dish] item id
  Map<int, Order> order = {
    // 0: Order(dishID: 0),
    // 1: Order(dishID: 1),
  };
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

  // ignore: use_setters_to_change_properties
  /// Set [TableStatus], notify listeners to rebuild widget
  void setTableStatus(TableStatus newStatus) {
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
}
