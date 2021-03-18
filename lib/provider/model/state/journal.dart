import 'package:flutter/foundation.dart';

@immutable
class Journal {
  final int id;
  final DateTime dateTime;
  final double amount;

  Journal({required this.id, DateTime? entryTime, double? amount})
      : dateTime = entryTime ?? DateTime.now(),
        amount = amount ?? 0;
}
