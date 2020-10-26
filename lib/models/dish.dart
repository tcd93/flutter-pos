import 'dart:collection';

import 'package:flutter/foundation.dart';

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
  static UnmodifiableListView<Dish> getMenu() => UnmodifiableListView([
        Dish(0, 'Sample'),
        Dish(1, 'Fish Tuna'),
        Dish(2, 'Sushi Salmon'),
        Dish(3, 'An armpit'),
      ]);
}
