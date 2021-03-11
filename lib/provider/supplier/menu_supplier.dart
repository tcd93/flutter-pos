import 'dart:math';

// import 'package:flutter/material.dart';
import '../../storage_engines/connection_interface.dart';

import '../src.dart';

class MenuSupplier {
  Menu _m = Menu();
  Menu get menu => _m;

  final DatabaseConnectionInterface? database;

  MenuSupplier({this.database, Menu? mockMenu}) {
    _m = mockMenu ?? database?.getMenu() ?? _defaultMenu();
  }

  Dish getDish(int index) {
    return _m.elementAt(index);
  }

  /// returns null if invalid ID
  Dish? find(int id) {
    if (_m.any((d) => d.id == id)) {
      return _m.firstWhere((d) => d.id == id);
    }
    return null;
  }

  int nextID() {
    return _m.map<int>((d) => d.id).reduce(max) + 1;
  }

  Future<void>? addDish(Dish newDish) {
    assert(newDish.dish != '');
    assert(newDish.price > 0);
    assert(!_m.contains(newDish));

    _m.add(newDish);
    return database?.setMenu(_m);
  }

  Future<void>? updateDish(Dish dish) async {
    assert(dish.dish != '');
    assert(dish.price > 0);
    assert(_m.contains(dish));

    _m.set(dish);
    return database?.setMenu(_m);
  }

  Future<void>? removeDish(Dish dish) {
    assert(_m.contains(dish));

    _m.remove(dish);
    return database?.setMenu(_m);
  }
}

Menu _defaultMenu() {
  return Menu([
    Dish.fromAsset(
      0,
      'Rice Noodles',
      10000,
      'assets/rice_noodles.png',
    ),
    Dish.fromAsset(
      1,
      'Lime Juice',
      20000,
      'assets/lime_juice.png',
    ),
    Dish.fromAsset(
      2,
      'Vegan Noodle',
      30000,
      'assets/vegan_noodles.png',
    ),
    Dish.fromAsset(
      3,
      'Oatmeal with Berries and Coconut',
      40000,
      'assets/oatmeal_with_berries_and_coconut.png',
    ),
    Dish.fromAsset(
      4,
      'Fried Chicken with Egg',
      50000,
      'assets/fried_chicken-with_with_wit_egg.png',
    ),
    Dish.fromAsset(
      5,
      'Kimchi',
      60000,
      'assets/kimchi.png',
    ),
    Dish.fromAsset(
      6,
      'Coffee',
      70000,
      'assets/coffee.png',
    ),
  ]);
}
