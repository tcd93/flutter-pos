import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

const Map<int, Tuple3<String, String, int>> menu = {
  0: Tuple3(
    'Rice Noodles',
    'assets/rice_noodles.jpg',
    10000,
  ),
  1: Tuple3(
    'Lime Juice',
    'assets/lime_juice.jpg',
    20000,
  ),
  2: Tuple3(
    'Vegan Noodle',
    'assets/vegan_noodles.jpg',
    30000,
  ),
  3: Tuple3(
    'Oatmeal with Berries and Coconut',
    'assets/oatmeal_with_berries_and_coconut.jpg',
    40000,
  ),
  4: Tuple3(
    'Fried Chicken with Egg',
    'assets/fried_chicken-with_with_wit_egg.jpg',
    50000,
  ),
  5: Tuple3(
    'Kimchi',
    'assets/kimchi.jpg',
    60000,
  ),
  6: Tuple3(
    'Coffee',
    'assets/coffee.jpg',
    70000,
  ),
};

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

  /// Index of menu is the unique ID of associated [Dish]
  static UnmodifiableListView<Dish> getMenu() => UnmodifiableListView(
        List.generate(
          menu.length,
          (index) => Dish(
            index,
            menu[index].item1,
            menu[index].item2,
            menu[index].item3,
          ),
          growable: false,
        ),
      );
}
