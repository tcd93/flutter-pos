import 'package:flutter/material.dart';

import '../database_factory.dart';
import 'table.dart';

class OrderTracker extends ChangeNotifier {
  List<TableModel> _tables;

  OrderTracker({
    DatabaseConnectionInterface database,
    List<TableModel> Function(OrderTracker) modelBuilder,
  }) {
    _tables = modelBuilder?.call(this) ??
        List.generate(7, (index) => TableModel(this, index), growable: false);
  }

  TableModel getTable(int index) => _tables[index];

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
