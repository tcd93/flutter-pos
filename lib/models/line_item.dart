import 'package:flutter/foundation.dart';

import 'dish.dart';

class LineItem {
  final int _dishID;

  /// The unique id from [Dish]
  int get dishID => _dishID;

  int _quantity = 0;

  int get quantity => _quantity;

  set quantity(int quantity) {
    assert(quantity != null, quantity > 0);
    _quantity = quantity;
  }

  /// The amount of current line item (price * quantity)
  int amount() {
    return Dish.getMenu()[dishID].price * quantity;
  }

  LineItem({@required int dishID, int quantity = 0})
      : assert(dishID != null, dishID >= 0 && dishID < Dish.getMenu().length),
        _dishID = dishID,
        _quantity = quantity;

  String toJson() {
    return '{"dishID": $_dishID, "quantity": $_quantity, "amount": ${amount()}}';
  }

  @override
  String toString() => toJson();
}
