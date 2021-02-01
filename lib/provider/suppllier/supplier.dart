import 'dart:math';

import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';

import '../src.dart';

class Supplier extends ChangeNotifier {
  List<TableModel> tables;
  final DatabaseConnectionInterface database;

  Supplier({
    this.database,
    List<TableModel> Function(Supplier) modelBuilder,
  }) {
    final l = database?.tableIDs();
    tables = modelBuilder?.call(this) ?? l.map((id) => TableModel(this, id)).toList();
  }

  TableModel getTable(int id) => tables.firstWhere((t) => t.id == id, orElse: () {
        debugPrint('$id not found!');
        return null;
      });

  /// Returns new table's id
  int addTable() {
    final nextID = tables.map((t) => t.id).fold<int>(0, max) + 1;
    tables.add(TableModel(this, nextID));
    database?.addTable(nextID);
    return nextID;
  }

  void removeTable(int tableID) {
    tables.removeWhere((table) => table.id == tableID);
    database?.removeTable(tableID);
    return;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
