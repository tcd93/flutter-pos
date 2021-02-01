import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../database_factory.dart';

@immutable
class Dish {
  // singleton
  static _Menu _menu;

  final int id;

  final double price;

  /// Dish name
  final String dish;

  /// Path to image, located under `/assets/` or `PickedFile.path` in `ImagePicker`
  final String imagePath;

  @override
  // ignore: always_declare_return_types, type_annotate_public_apis
  operator ==(other) => other is Dish && other.id == id;
  @override
  int get hashCode => id;

  const Dish(this.id, this.dish, [this.price, this.imagePath])
      : assert(id >= 0),
        assert(dish != null && dish != '');

  /// Index of _menu is the unique ID of associated [Dish].
  /// Return from local storage or return a basic menu set
  static UnmodifiableListView<Dish> getMenu() {
    _menu ??= _Menu();
    return UnmodifiableListView(_menu.list.values);
  }

  static Dish at(int index) {
    _menu ??= _Menu();
    return _menu.list.values.elementAt(index);
  }

  static Dish ofID(int id) {
    _menu ??= _Menu();
    return _menu.list[id.toString()];
  }

  static int newID() {
    _menu ??= _Menu();
    return _menu.list.keys.map(int.parse).reduce(max) + 1;
  }

  static void setMenu(Dish dish) async {
    _menu ??= _Menu();
    assert(dish.id != null);
    assert(dish.dish != '' || dish.dish != null);
    assert(dish.price > 0);

    _menu.list.update(
      dish.id.toString(),
      (_) => dish,
    );
    await _menu.storage.setMenu(_menu.list);
  }

  static void addMenu(Dish dish) async {
    assert(dish.id != null);
    assert(dish.dish != '' || dish.dish != null);
    assert(dish.price > 0);

    _menu.list.addAll({dish.id.toString(): dish});

    await _menu.storage.setMenu(_menu.list);
  }

  static void deleteMenu(Dish dish) async {
    assert(dish.id != null);
    assert(_menu.list.containsKey(dish.id.toString()));

    _menu.list.remove(dish.id.toString());
    await _menu.storage.setMenu(_menu.list);
  }
}

class _Menu {
  final storage = DatabaseFactory().create('local-storage');

  /// A `Map<String, Dish>`, where the String key is the dishID.
  /// Note that the key must be a string for `encode/decode` to work
  Map<String, Dish> list;

  _Menu() {
    list = storage.getMenu() ??
        {
          '0': Dish(
            0,
            'Rice Noodles',
            10000,
            'assets/rice_noodles.png',
          ),
          '1': Dish(
            1,
            'Lime Juice',
            20000,
            'assets/lime_juice.png',
          ),
          '2': Dish(
            2,
            'Vegan Noodle',
            30000,
            'assets/vegan_noodles.png',
          ),
          '3': Dish(
            3,
            'Oatmeal with Berries and Coconut',
            40000,
            'assets/oatmeal_with_berries_and_coconut.png',
          ),
          '4': Dish(
            4,
            'Fried Chicken with Egg',
            50000,
            'assets/fried_chicken-with_with_wit_egg.png',
          ),
          '5': Dish(
            5,
            'Kimchi',
            60000,
            'assets/kimchi.png',
          ),
          '6': Dish(
            6,
            'Coffee',
            70000,
            'assets/coffee.png',
          ),
        };
  }
}
