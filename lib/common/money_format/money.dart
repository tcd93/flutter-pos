import 'package:flutter/cupertino.dart';

@immutable
class Money {
  static String format(num price) {
    var p = price.round().toString();
    if (p.length > 2) {
      var value = p;
      value = value.replaceAll(RegExp(r'\D'), '');
      value = value.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
      return value;
    }
    return p;
  }
}
