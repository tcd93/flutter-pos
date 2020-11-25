import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../database_factory.dart';

class _Menu {
  // just simply use local-storage for this
  final storage = DatabaseFactory().create('local-storage');

  /// A `Map<String, Dish>`, where the String key is the dishID.
  /// Note that the key must be a string for `encode/decode` to work
  Map<String, Dish> list;

  _Menu() {
    // return from local storage or return a basic menu set
    list = storage.getMenu() ??
        {
          '0': Dish(
            0,
            'Rice Noodles',
            'assets/rice_noodles.png',
            10000,
          ),
          '1': Dish(
            1,
            'Lime Juice',
            'assets/lime_juice.png',
            20000,
          ),
          '2': Dish(
            2,
            'Vegan Noodle',
            'assets/vegan_noodles.png',
            30000,
          ),
          '3': Dish(
            3,
            'Oatmeal with Berries and Coconut',
            'assets/oatmeal_with_berries_and_coconut.png',
            40000,
          ),
          '4': Dish(
            4,
            'Fried Chicken with Egg',
            'assets/fried_chicken-with_with_wit_egg.png',
            50000,
          ),
          '5': Dish(
            5,
            'Kimchi',
            'assets/kimchi.png',
            60000,
          ),
          '6': Dish(
            6,
            'Coffee',
            'assets/coffee.png',
            70000,
          ),
        };
  }
}

@immutable
class Dish {
  /// Unique id of [Dish]
  final int id;

  final int price;

  /// Dish name
  final String dish;

  /// Path to image, located under `/assets/`
  final String imagePath;

  // ignore: type_annotate_public_apis
  operator ==(other) => other is Dish && other.id == id;
  int get hashCode => id;

  const Dish(this.id, this.dish, [this.imagePath, this.price]);

  static _Menu menu;

  /// Index of menu is the unique ID of associated [Dish]
  static UnmodifiableListView<Dish> getMenu() {
    if (menu == null) {
      menu = _Menu();
    }

    return UnmodifiableListView(
      List.generate(
        menu.list.length,
        (index) => Dish(
          index,
          menu.list[index.toString()].dish,
          menu.list[index.toString()].imagePath,
          menu.list[index.toString()].price,
        ),
        growable: false,
      ),
    );
  }

  static void setMenu(Dish dish) async {
    // update the single menu item, then overwrite the entire menu to dish
    menu.list.update(
      dish.id.toString(),
      (value) => Dish(dish.id, dish.dish, dish.imagePath, dish.price),
    );
    await menu.storage.setMenu(menu.list);
  }
}
