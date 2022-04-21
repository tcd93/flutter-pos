import 'package:flutter/foundation.dart';

import '../../../storage_engines/connection_interface.dart';

@immutable
class Journal {
  final QueryKey _id;
  final DateTime dateTime;
  final String entry;
  final double amount;

  QueryKey get id => _id;

  Journal({required this.entry, DateTime? entryTime, double? amount})
      : dateTime = entryTime ?? DateTime.now(),
        amount = amount ?? 0,
        _id = -1;

  Journal.fromJson(Map<String, dynamic> json)
      : _id = json['journalID'] ?? json['ID'] ?? -1,
        dateTime = DateTime.parse(json['dateTime']),
        entry = json['entry'],
        amount = json['amount'];

  Map<String, dynamic> toJson() {
    return {
      'ID': _id,
      'dateTime': dateTime.toString(),
      'entry': entry,
      'amount': amount,
    };
  }

  @override
  String toString() {
    return '{ '
        'ID: $_id, '
        'dateTime: ${dateTime.toString()}, '
        'entry: $entry, '
        'amount: $amount '
        '}';
  }
}
