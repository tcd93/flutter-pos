import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
}

@immutable
class TableModel {
  final OrderTracker _tracker;
  final int id;
  //TODO: create menu list (Menu Class)

  final _State tableState = _State();

  // ignore: type_annotate_public_apis
  operator ==(other) => other is TableModel && other.id == id;
  int get hashCode => id;

  TableModel(this._tracker, this.id);

  bool isAbleToPlaceOrder() => tableState.status == _TableStatus.empty ? true : false;

  /// - When empty: `green`
  /// - When not empty: `grey`
  Color currentColor() =>
      tableState.status == _TableStatus.empty ? Colors.green[300] : Colors.grey[300];

  /// The reversed version of `currentColor()`
  Color reversedColor() =>
      tableState.status == _TableStatus.empty ? Colors.grey[300] : Colors.green[300];

  /// Toggle the "empty" status of current table.
  /// Trigger a rebuild
  void toggleStatus() {
    tableState.status =
        tableState.status == _TableStatus.empty ? _TableStatus.occupied : _TableStatus.empty;
    _tracker.notifyListeners();
  }
}
