import 'package:flutter/foundation.dart';

@immutable
class Journal {
  final int _id; // currently of no use...
  final DateTime dateTime;
  final String entry;
  final double amount;

  int get id => _id;

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
