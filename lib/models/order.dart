import 'package:flutter/material.dart';

import 'table.dart';

class OrderTracker extends ChangeNotifier {
  List<TableModel> _tables;

  OrderTracker() {
    _tables = List.generate(7, (index) => TableModel(this, index), growable: false);
  }

  TableModel getTable(int index) => _tables[index];

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
