import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'menu.dart';

@immutable
class Dish {
  // singleton
  static final Menu _menu = Menu();

  final int id;

  final double price;

  /// Dish name
  final String dish;

  /// image bytes data
  final Uint8List? imageBytes;

  @override
  // ignore: always_declare_return_types, type_annotate_public_apis
  operator ==(other) => other is Dish && other.id == id;
  @override
  int get hashCode => id;

  const Dish(this.id, this.dish, [this.price = 0, this.imageBytes])
      : assert(id >= 0),
        assert(dish != '');

  /// Index of _menu is the unique ID of associated [Dish].
  /// Return from local storage or return a basic menu set
  static UnmodifiableListView<Dish> getMenu() {
    return UnmodifiableListView(_menu.list.values);
  }

  static Dish at(int index) {
    return _menu.list.values.elementAt(index);
  }

  static Dish? ofID(int id) {
    return _menu.list[id.toString()];
  }

  static int newID() {
    return _menu.list.keys.map(int.parse).reduce(max) + 1;
  }

  static void setMenu(Dish dish) async {
    assert(dish.dish != '');
    assert(dish.price > 0);

    _menu.list.update(
      dish.id.toString(),
      (_) => dish,
    );
    await _menu.storage.setMenu(_menu.list);
  }

  static void addMenu(Dish dish) async {
    assert(dish.dish != '');
    assert(dish.price > 0);

    _menu.list.addAll({dish.id.toString(): dish});

    await _menu.storage.setMenu(_menu.list);
  }

  static void deleteMenu(Dish dish) async {
    assert(_menu.list.containsKey(dish.id.toString()));

    _menu.list.remove(dish.id.toString());
    await _menu.storage.setMenu(_menu.list);
  }
}
