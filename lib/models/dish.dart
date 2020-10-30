import 'dart:collection';

import 'package:flutter/foundation.dart';

const menu = {
  0: 'Sample',
  1: 'Fish Tuna',
  2: 'Sushi Salmon',
  3: 'An armpit',
  4: 'Broken rice',
  5: 'Beef Noddle',
  6: 'Naruto-kun',
  7: '@@@@@@@@@@',
  8: 'Banh Mi',
  9: 'Pho',
  10: 'A very long text like lorem ipsum that should be three-dotted',
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

  const Dish(this.id, this.dish, [this.imagePath = 'assets/default.png']);

  /// Index of menu is the unique ID of associated [Dish]
  static UnmodifiableListView<Dish> getMenu() => UnmodifiableListView(
        List.generate(
          menu.length - 1,
          (index) => Dish(index, menu[index]),
          growable: false,
        ),
      );
}
