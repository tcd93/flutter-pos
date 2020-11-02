import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

const Map<int, Tuple2<String, String>> menu = {
  0: Tuple2(
    'Rice Noodles',
    'assets/rice_noodles.jpg',
  ),
  1: Tuple2(
    'Lime Juice',
    'assets/lime_juice.jpg',
  ),
  2: Tuple2(
    'Vegan Noodle',
    'assets/vegan_noodles.jpg',
  ),
  3: Tuple2(
    'Oatmeal with Berries and Coconut',
    'assets/oatmeal_with_berries_and_coconut.jpg',
  ),
  4: Tuple2(
    'Fried Chicken with Egg',
    'assets/fried_chicken-with_with_wit_egg.jpg',
  ),
  5: Tuple2(
    'Kimchi',
    'assets/kimchi.jpg',
  ),
  6: Tuple2(
    'Coffee',
    'assets/coffee.jpg',
  ),
};

@immutable
class Dish {
  /// Unique id of [Dish]
  final int id;

  /// Dish name
  final String dish;

  /// Path to image, located under `/assets/`
  final String imagePath;

  // ignore: type_annotate_public_apis
  operator ==(other) => other is Dish && other.id == id;
  int get hashCode => id;

  const Dish(this.id, this.dish, [this.imagePath]);

  /// Index of menu is the unique ID of associated [Dish]
  static UnmodifiableListView<Dish> getMenu() => UnmodifiableListView(
        List.generate(
          menu.length - 1,
          (index) => Dish(index, menu[index].item1, menu[index].item2),
          growable: false,
        ),
      );
}
