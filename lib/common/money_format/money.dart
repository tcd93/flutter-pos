import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

@immutable
class Money {
  Money._();

  static final _fc = NumberFormat('#,###');
  static final _fcFull = NumberFormat.simpleCurrency();

  static String get symbol => _fc.currencySymbol;

  static String format(num price, {bool symbol = false}) {
    return symbol ? _fcFull.format(price) : _fc.format(price);
  }

  static num unformat(String money) {
    if (money == '') {
      return 0;
    }
    return _fc.parse(money.replaceAll(RegExp(r'[^0-9]'), '')); // extract numbers only
  }
}
