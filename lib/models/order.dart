import 'package:flutter/foundation.dart';

import 'dish.dart';

class Order {
  int _dishID;

  /// The unique id from [Dish]
  int get dishID => _dishID;

  /// The unique id from [Dish]
  set dishID(int dishID) {
    assert(dishID != null, dishID >= 0 && dishID < Dish.getMenu().length);
    _dishID = dishID;
  }

  int _quantity = 0;

  int get quantity => _quantity;

  set quantity(int quantity) {
    assert(quantity != null, quantity > 0);
    _quantity = quantity;
  }

  Order({@required int dishID})
      : assert(dishID != null, dishID >= 0 && dishID < Dish.getMenu().length),
        _dishID = dishID;

  @override
  String toString() {
    return '{dishID: $_dishID, quantity: $_quantity}';
  }
}
