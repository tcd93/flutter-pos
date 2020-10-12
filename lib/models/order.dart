import 'package:flutter/material.dart';

class OrderTracker extends ChangeNotifier {
  List<TableModel> _tables;

  OrderTracker() {
    _tables =
        List.generate(7, (index) => TableModel(this, index), growable: false);
  }

  TableModel getTable(int index) => _tables[index];

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

class TableModel {
  final OrderTracker tracker;
  final int id;
  bool isEmpty = true;

  operator ==(other) => other is TableModel && other.id == id;
  int get hashCode => id;

  TableModel(this.tracker, this.id);

  Color getStatusColor() => this.isEmpty ? Colors.green[400] : Colors.grey[600];

  void changeStatus() {
    this.isEmpty = !this.isEmpty;
    tracker.notifyListeners();
  }
}
