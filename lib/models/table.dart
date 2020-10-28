import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'order.dart';
import 'tracker.dart';

enum _TableStatus {
  /// No one is sitting at this table
  empty,

  /// Dining
  occupied,
  // may be more status here, like Discounted, Need cleaning...
}

/// The separate "state" of the immutable [TableModel] class
class _State {
  _TableStatus status = _TableStatus.empty;

  //TODO: dummy
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

  bool isAbleToPlaceOrder() =>
      _tableState.status == _TableStatus.empty ? true : false;

  /// TODO - remove these, model should not dictate UI elements
  /// - When empty: `green`
  /// - When not empty: `grey`
  Color currentColor() => _tableState.status == _TableStatus.empty
      ? Colors.green[300]
      : Colors.grey[300];

  /// The reversed version of `currentColor()`
  Color reversedColor() => _tableState.status == _TableStatus.empty
      ? Colors.grey[300]
      : Colors.green[300];

  /// TODO - make this more functional
  /// Toggle the "empty" status of current table.
  /// Trigger a rebuild
  void toggleStatus() {
    _tableState.status = _tableState.status == _TableStatus.empty
        ? _TableStatus.occupied
        : _TableStatus.empty;
    _tracker.notifyListeners();
  }

  /// Get [Order] at menu index
  Order getOrder(int dishID) => _tableState.order[dishID];

  /// putIfAbsent [Order] at menu index
  Order getOrPutOrder(int dishID) =>
      _tableState.order.putIfAbsent(dishID, () => Order(dishID: dishID));
}
