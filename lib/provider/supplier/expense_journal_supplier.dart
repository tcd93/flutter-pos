import 'package:flutter/material.dart';
import '../src.dart';
import '../../storage_engines/connection_interface.dart';

/// A provider specifically for [ExpenseJournalScreen]
class ExpenseSupplier extends ChangeNotifier {
  final JournalIO? database;
  late List<Journal> _list;
  late DateTimeRange _selectedRange;

  List<Journal> get data => _list;
  DateTimeRange get selectedRange => _selectedRange;

  /// total amount over the [_selectedRange]
  late double _sumAmount = 0;

  double get sumAmount => _sumAmount;

  ExpenseSupplier({this.database, DateTimeRange? range}) {
    _selectedRange = range ?? DateTimeRange(start: DateTime.now(), end: DateTime.now());
    _list = database?.getJournals(_selectedRange.start, _selectedRange.end) ?? [];
    _sumAmount = _calcTotalAmount(_list);
  }

  /// Add a new journal entry to the list, note that it still refresh & display newly added
  /// ones with older date to not confuse users. If the list is refreshed again then it would not
  /// be shown again
  void addJournal(Journal journal) {
    assert(journal.id >= 0);
    _list = [..._list, journal]; // don't use .add() because it does not work with 'select'
    _sumAmount = _calcTotalAmount(data);
    database?.insertJournal(journal);
    notifyListeners();
  }

  set selectedRange(DateTimeRange newRange) {
    if (_selectedRange != newRange) {
      _selectedRange = newRange;
      _list = database?.getJournals(_selectedRange.start, _selectedRange.end) ?? [];
      _sumAmount = _calcTotalAmount(data);
      notifyListeners();
    }
  }

  double _calcTotalAmount(List<Journal> journals) => journals.fold(0,
      (previousValue, e) => previousValue + (_between(e.dateTime, _selectedRange) ? e.amount : 0));

  /// check daterange inclusive without regards to time
  bool _between(DateTime current, DateTimeRange range) {
    final curr = trunc(current);
    return curr.isAfter(trunc(range.start).add(const Duration(days: -1))) &&
        current.isBefore(trunc(range.end).add(const Duration(days: 1)));
  }

  DateTime trunc(DateTime d) => DateTime(d.year, d.month, d.day);
}
