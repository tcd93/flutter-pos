import 'package:flutter/foundation.dart';

import 'dish.dart';

class LineItem {
  /// The unique id from [Dish]
  final int _dishID;

  int _quantity = 0;

  /// The amount of current line item (price * quantity)
  int get amount => Dish.getMenu()[dishID].price * quantity;

  /// The unique id from [Dish]
  int get dishID => _dishID;

  int get quantity => _quantity;

  set quantity(int quantity) {
    assert(quantity != null, quantity > 0);
    _quantity = quantity;
  }

  LineItem({@required int dishID, int quantity = 0})
      : assert(dishID != null, dishID >= 0 && dishID < Dish.getMenu().length),
        _dishID = dishID,
        _quantity = quantity;
}
