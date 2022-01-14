import 'dart:math';

import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';

import '../src.dart';

class Supplier extends ChangeNotifier {
  List<TableModel> tables = [];
  final SupplierRepository? database;

  Supplier({
    this.database,
    List<TableModel>? mockModels,
  }) {
    final l = database?.tableIDs();
    Coordinate? startingCoord(int id) => database != null ? Coordinate.fromDB(id, database!) : null;
    tables = mockModels ?? l?.map((id) => TableModel(id, startingCoord(id))).toList() ?? [];
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

  Future<void> checkout(TableModel table, [DateTime? atTime]) async {
    table.currentOrder.checkoutTime = atTime ?? DateTime.now();

    await database?.insert(table.currentOrder);

    notifyListeners();
  }
}
