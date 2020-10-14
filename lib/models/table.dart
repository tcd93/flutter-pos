import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'order.dart';

class TableModel {
  final OrderTracker _tracker;
  final int id;

  bool _isEmpty = true;

  operator ==(other) => other is TableModel && other.id == id;
  int get hashCode => id;

  TableModel(this._tracker, this.id);

  /// - When empty: `green`
  /// - When not empty: `grey`
  Color currentColor() => this._isEmpty ? Colors.green[400] : Colors.grey[300];

  /// The reversed version of `currentColor()`
  Color reversedColor() => this._isEmpty ? Colors.grey[300] : Colors.green[400];

  /// Toggle the "empty" status of current table.
  /// Trigger a rebuild
  void toggleStatus() {
    this._isEmpty = !this._isEmpty;
    _tracker.notifyListeners();
  }
}
