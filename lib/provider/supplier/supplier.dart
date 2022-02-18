import 'dart:async';

import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';

import '../src.dart';

class Supplier extends ChangeNotifier {
  late List<TableModel> _tables = [];
  List<TableModel> tables(int page) {
    return List.unmodifiable(_tables.where((t) => t.node.page == page));
  }

  bool _loading = false;
  bool get loading => _loading;

  final RIUDRepository<Node>? database;

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
      final nodes = (await database?.get()) ?? [];
      _tables = [for (final n in nodes) TableModel(n)];
      _loading = false;
      notifyListeners();
    });
  }

  Future<int?> addTable(int page) async {
    final n = await database?.insert(Node(page: page));
    _tables.add(TableModel(n));
    notifyListeners();
    return n?.id;
  }

  Future<void> removeTable(TableModel table) async {
    assert(_tables.contains(table));

    await database?.delete(table.node);
    _tables.remove(table);
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
