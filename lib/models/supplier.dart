import 'package:flutter/material.dart';
import '../storage_engines/connection_interface.dart';

import 'table.dart';

class Supplier extends ChangeNotifier {
  List<TableModel> _tables;
  final DatabaseConnectionInterface database;

  Supplier({
    this.database,
    List<TableModel> Function(Supplier) modelBuilder,
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
