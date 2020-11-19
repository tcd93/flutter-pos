import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'dish.dart';
import 'line_item.dart';
import 'state/state_object.dart';
import 'state/status.dart';
import 'supplier.dart';

/// The separate current "state" of the immutable [TableModel] class
class _TableState extends StateObject {
  /// The associated table id
  final int tableID;

  TableStatus status = TableStatus.empty;

  TableStatus previousStatus = TableStatus.empty;

  /// Keep track of state history, overwrite snapshot everytime the confirm
  /// button is clicked
  List<LineItem> previouslineItems;

  _TableState(this.tableID) {
    cleanState();
  }

  _TableState.from(StateObject base) : tableID = -1 {
    lineItems = base.lineItems;
  }

  /// set all line items to 0
  void cleanState() {
    status = TableStatus.empty;
    previousStatus = TableStatus.empty;
    lineItems = Dish.getMenu()
        .map(
          (dish) => LineItem(
            dishID: dish.id,
            quantity: 0,
          ),
        )
        .toList();
    previouslineItems = Dish.getMenu()
        .map(
          (dish) => LineItem(
            dishID: dish.id,
            quantity: 0,
          ),
        )
        .toList();
  }
}

@immutable
class TableModel {
  final Supplier _tracker;
  final int id;

  final _TableState _tableState;

  // ignore: type_annotate_public_apis
  operator ==(other) => other is TableModel && other.id == id;
  int get hashCode => id;

  TableModel(this._tracker, this.id, [StateObject mockState])
      : _tableState = mockState != null ? _TableState.from(mockState) : _TableState(id);

  /// Returns current [TableStatus]
  TableStatus get status => _tableState.status;

  /// Set [TableStatus], notify listeners to rebuild widget
  void setTableStatus(TableStatus newStatus) {
    _tableState.status = newStatus;
    _tracker?.notifyListeners();
  }

  /// Get [lineItems] from menu list
  LineItem lineItem(int index) => _tableState.lineItems[index];

  /// Get a list of current [lineItems] (with quantity > 0)
  UnmodifiableListView<LineItem> get lineItems => UnmodifiableListView(
        _tableState.lineItems.where((entry) => entry.isBeingOrdered()),
      );

  /// Returns total items (number of dishes) of current table
  int get totalMenuItemQuantity => _tableState.lineItems.fold(
        0,
        (previousValue, element) => previousValue + element.quantity,
      );

  /// Total price of all line items in this order
  int get totalPrice => _tableState.totalPrice;

  /// Store current state for rollback operation
  void memorizePreviousState() {
    _tableState.previousStatus = _tableState.status;
    _tableState.previouslineItems = _tableState.lineItems
        .map(
          (e) => LineItem(
            dishID: e.dishID,
            quantity: e.quantity,
          ),
        )
        .toList(); // clone
  }

  /// Restore to last "commit"
  void revert() {
    _tableState.status = _tableState.previousStatus;
    // overwrite current `lineItems` state.
    // has to do cloning here to not bind the reference of previous [lineItems]s to current state
    _tableState.lineItems = _tableState.previouslineItems
        .map(
          (e) => LineItem(
            dishID: e.dishID,
            quantity: e.quantity,
          ),
        )
        .toList();
    _tracker?.notifyListeners();
  }

  Future<void> checkout([DateTime atTime]) async {
    _tableState.orderID = await _tracker?.database?.nextUID();
    _tableState.checkoutTime = atTime ?? DateTime.now();
    await _tracker?.database?.insert(_tableState);
    _tableState.cleanState(); // clear state
    _tracker?.notifyListeners();
  }

  // TODO: implement `printReceipt`
  Future<void> printReceipt() async {
    print('----- PRINT -----');
    await Future.delayed(const Duration(seconds: 1));
  }
}
