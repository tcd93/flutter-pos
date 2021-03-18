import 'package:flutter/material.dart';
import '../src.dart';
import '../../storage_engines/connection_interface.dart';

/// A provider specifically for [InventoryJournalScreen]
class InventorySupplier extends ChangeNotifier {
  final JournalIO? database;
  late List<Journal> _list;
  late DateTimeRange _selectedRange;

  List<Journal> get data => _list;
  DateTimeRange get selectedRange => _selectedRange;

  /// total amount over the [_selectedRange]
  late double _sumAmount = 0;

  double get sumAmount => _sumAmount;

  InventorySupplier({this.database, DateTimeRange? range}) {
    _selectedRange = range ?? DateTimeRange(start: DateTime.now(), end: DateTime.now());
    _list = database?.getJournals(_selectedRange.start, _selectedRange.end) ?? [];
    _sumAmount = _calcTotalAmount(_list);
  }

  void add(Journal journal) {
    _list.add(journal);
  }

  set selectedRange(DateTimeRange newRange) {
    if (_selectedRange != newRange) {
      _selectedRange = newRange;
      _list = database?.getJournals(_selectedRange.start, _selectedRange.end) ?? [];
      _sumAmount = _calcTotalAmount(data);
      notifyListeners();
    }
  }

  double _calcTotalAmount(List<Journal> journals) =>
      journals.fold(0, (previousValue, e) => previousValue + e.amount);
}
