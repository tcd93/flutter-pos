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

class Dish {
  // TODO: dish from external file
  String dish = 'Sample';
  int quantity = 0;
}

/// The separate "state" of the immutable [TableModel] class
class _State {
  _TableStatus status = _TableStatus.empty;

  //TODO: dummy
  List<Dish> order = [Dish()];
}

@immutable
class TableModel {
  final OrderTracker _tracker;
  final int id;
  //TODO: create menu list (Menu Class)

  final _State _tableState = _State();

  // ignore: type_annotate_public_apis
  operator ==(other) => other is TableModel && other.id == id;
  int get hashCode => id;

  TableModel(this._tracker, this.id);

  bool isAbleToPlaceOrder() => _tableState.status == _TableStatus.empty ? true : false;

  /// - When empty: `green`
  /// - When not empty: `grey`
  Color currentColor() =>
      _tableState.status == _TableStatus.empty ? Colors.green[300] : Colors.grey[300];

  /// The reversed version of `currentColor()`
  Color reversedColor() =>
      _tableState.status == _TableStatus.empty ? Colors.grey[300] : Colors.green[300];

  /// Toggle the "empty" status of current table.
  /// Trigger a rebuild
  void toggleStatus() {
    _tableState.status =
        _tableState.status == _TableStatus.empty ? _TableStatus.occupied : _TableStatus.empty;
    _tracker.notifyListeners();
  }

  /// Get orders
  List<Dish> getOrder() => _tableState.order;
}
