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
  TableStatus status;
  TableStatus previousStatus;

  /// The lineItem associated with a table.
  /// This is a [Map<int, LineItem>] where the key is the [Dish] item id
  Map<int, LineItem> lineItem;

  /// Keep track of state history, overwrite snapshot everytime the confirm
  /// button is clicked
  Map<int, LineItem> previousLineItem;

  TableState() {
    blankState();
  }

  /// set all line items to 0
  void blankState() {
    status = TableStatus.empty;
    previousStatus = TableStatus.empty;
    lineItem = {
      for (var dish in Dish.getMenu())
        dish.id: LineItem(dishID: dish.id, quantity: 0)
    };
    previousLineItem = {
      for (var dish in Dish.getMenu())
        dish.id: LineItem(dishID: dish.id, quantity: 0)
    };
  }

  @override
  String toString() {
    return '{status: ${status.toString()}, lineItem: ${lineItem.toString()}}';
  }
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
      : _tableState = mockState ?? TableState();

  /// Returns current [TableStatus]
  TableStatus getTableStatus() => _tableState.status;

  /// Set [TableStatus], notify listeners to rebuild widget
  void setTableStatus(TableStatus newStatus) {
    _tableState.status = newStatus;
    _tracker.notifyListeners();
  }

  /// Get [LineItem] from menu list
  LineItem lineItem(int index) => _tableState.lineItem[index];

  /// Get a list of current [LineItem] (with quantity > 0)
  UnmodifiableListView<LineItem> lineItems() {
    return UnmodifiableListView(
      _tableState.lineItem.entries
          .where((entry) => entry.value.quantity > 0)
          .map((entry) => entry.value),
    );
  }

  /// Returns total items (number of dishes) of current table
  int totalMenuItemQuantity() => _tableState.lineItem.entries.fold(
        0,
        (previousValue, element) => previousValue + element.value.quantity,
      );

  /// Store current state for rollback operation
  void memorizePreviousState() {
    _tableState.previousStatus = _tableState.status;
    _tableState.previousLineItem = Common.cloneMap<int, LineItem>(
      _tableState.lineItem,
      (key, value) => LineItem(
        dishID: key,
        quantity: value.quantity,
      ),
    );
  }

  /// Restore to last "commit"
  void revert() {
    _tableState.status = _tableState.previousStatus;
    // overwrite current `lineItem` state.
    // has to do cloning here to not bind the reference of previous [LineItem]s to current state
    _tableState.lineItem = Common.cloneMap<int, LineItem>(
      _tableState.previousLineItem,
      (key, value) => LineItem(
        dishID: key,
        quantity: value.quantity,
      ),
    );
    _tracker.notifyListeners();
  }

  void checkout() {
    debugPrint('Checked out...');

    // TODO: implement checkout (save file to database & print)

    // clear state
    _tableState.blankState();
    _tracker.notifyListeners();
  }
}
