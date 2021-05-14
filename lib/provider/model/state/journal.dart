import 'package:flutter/foundation.dart';

@immutable
class Journal {
  final int id;
  final DateTime dateTime;
  final String entry;
  final double amount;

  Journal({required this.id, required this.entry, DateTime? entryTime, double? amount})
      : assert(id >= 0),
        dateTime = entryTime ?? DateTime.now(),
        amount = amount ?? 0;

  Journal.fromJson(Map<String, dynamic> json)
      : id = json['journalID'] ?? -1,
        dateTime = DateTime.parse(json['dateTime']),
        entry = json['entry'],
        amount = json['amount'];

  Map<String, dynamic> toJson() {
    return {
      'journalID': id,
      'dateTime': dateTime.toString(),
      'entry': entry,
      'amount': amount,
    };
  }
}
