import 'dart:async';

import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';

import '../src.dart';

class Supplier extends ChangeNotifier {
  late List<TableModel> _tables = [];
  List<TableModel> get tables => _tables;

  bool _loading = false;
  bool get loading => _loading;

  final NodeIO? database;

  Supplier({
    this.database,
    List<TableModel>? mockModels,
  }) {
    if (mockModels != null) {
      _tables = mockModels;
      _loading = false;
      return;
    }
    _loading = true;
    Future(() async {
      final ids = (await database?.tableIDs()) ?? [];
      _tables = [for (final _id in ids) TableModel(_id, await _startingCoord(_id))];
      _loading = false;
      notifyListeners();
    });
  }

  Future<Coordinate?> _startingCoord(int id) async =>
      database != null ? await Coordinate.fromDB(id, database!) : null;

  TableModel getTable(int id) {
    return tables.firstWhere((t) => t.id == id);
  }

  Future<int?> addTable() async {
    final _nextID = await database?.addTable();
    tables.add(TableModel(_nextID ?? -1));
    notifyListeners();
    return _nextID;
  }

  Future<void> removeTable(int tableID) async {
    await database?.removeTable(tableID);
    tables.removeWhere((table) => table.id == tableID);
    notifyListeners();
    return;
  }

  Future<void> checkout(TableModel table, [RIRepository<Order>? repo, DateTime? atTime]) async {
    await table.checkout(repo, atTime);
    notifyListeners();
  }

  void setTableStatus(TableModel table, TableStatus newStatus) {
    table.applyStatus(newStatus);
    notifyListeners();
  }

  void setTableDiscount(TableModel table, double discount) {
    table.applyDiscount(discount);
    notifyListeners();
  }

  void revert(TableModel table) {
    table.revert();
    notifyListeners();
  }

  void commit(TableModel table) {
    table.memorizePreviousState();
  }
}
