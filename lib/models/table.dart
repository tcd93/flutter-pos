import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../common/common.dart';
import 'line_item.dart';
import 'state/state_object.dart';
import 'state/status.dart';
import 'state/table_state.dart';
import 'supplier.dart';

@immutable
class TableModel {
  final Supplier _tracker;
  final int id;

  final TableState _tableState;

  // ignore: type_annotate_public_apis
  operator ==(other) => other is TableModel && other.id == id;
  int get hashCode => id;

  TableModel(this._tracker, this.id, [StateObject mockState])
      : _tableState = mockState ?? TableState(id);

  /// Returns current [TableStatus]
  TableStatus get status => _tableState.status;

  /// Set [TableStatus], notify listeners to rebuild widget
  void setTableStatus(TableStatus newStatus) {
    _tableState.status = newStatus;
    _tracker.notifyListeners();
  }

  /// Get [lineItems] from menu list
  LineItem lineItem(int index) => _tableState.lineItems[index];

  /// Get a list of current [lineItems] (with quantity > 0)
  UnmodifiableListView<LineItem> get lineItems => UnmodifiableListView(
        _tableState.lineItems.entries
            .where((entry) => entry.value.quantity > 0)
            .map((entry) => entry.value),
      );

  /// Returns total items (number of dishes) of current table
  int get totalMenuItemQuantity => _tableState.lineItems.entries.fold(
        0,
        (previousValue, element) => previousValue + element.value.quantity,
      );

  /// Total price of all line items in this order
  int get totalPrice => _tableState.totalPrice;

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
