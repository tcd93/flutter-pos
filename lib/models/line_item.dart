import 'dart:io';

import 'package:flutter/foundation.dart';

import 'dish.dart';

class LineItem {
  /// The unique id from [Dish]
  final int dishID;

  int _quantity = 0;

  int get quantity => _quantity;

  /// `WARNING: Only allow setting quantity in TEST mode`
  set quantity(int v) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _quantity = v;
    } else {
      throw 'Only allow setting quantity in TEST mode';
    }
  }

  /// The amount of current line item (price * quantity)
  int get amount => Dish.getMenu()[dishID].price * _quantity;

  /// Increase quantity by 1
  int addOne() => ++_quantity;

  /// Decrease quantity by 1, returns 0 if reached 0
  int substractOne() => _quantity > 0 ? --_quantity : 0;

  /// Item is active in [MenuScreen]
  bool isBeingOrdered() => _quantity > 0;

  LineItem({@required this.dishID, int quantity = 0})
      : assert(dishID != null, dishID >= 0 && dishID < Dish.getMenu().length),
        _quantity = quantity;
}
