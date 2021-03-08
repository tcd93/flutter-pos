import 'dart:math';

import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';

import '../src.dart';

class Supplier extends ChangeNotifier {
  List<TableModel> tables = [];
  final DatabaseConnectionInterface? database;

  Supplier({
    this.database,
    List<TableModel>? mockModels,
  }) {
    final l = database?.tableIDs();
    tables = mockModels ?? l?.map((id) => TableModel(id)).toList() ?? [];
  }

  TableModel getTable(int id) {
    return tables.firstWhere((t) => t.id == id);
  }

  /// Returns new table's id
  int addTable() {
    final nextID = tables.map((t) => t.id).fold<int>(0, max) + 1;
    tables.add(TableModel(nextID));
    database?.addTable(nextID);
    notifyListeners();
    return nextID;
  }

  void removeTable(int tableID) {
    tables.removeWhere((table) => table.id == tableID);
    database?.removeTable(tableID);
    notifyListeners();
    return;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
