import 'dart:async';
import 'dart:typed_data';

// import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../storage_engines/connection_interface.dart';

import '../src.dart';

class MenuSupplier {
  late List<Dish> _m;

  /// must call [init] beforehand
  List<Dish> get menu => _m;
  final Completer<MenuSupplier> _completer = Completer();

  final RIUDRepository<Dish>? database;

  MenuSupplier({this.database, List<Dish>? mockMenu}) {
    if (mockMenu != null) {
      _m = mockMenu;
      _completer.complete(this);
      return;
    }
    Future(() async {
      _m = (await database?.get()) ?? [];
      if (_m.isEmpty) {
        _m = _defaultMenu();
        if (database != null) _m.forEach(database!.insert);
      }
      // in case getMenu() too fast causing screen rebuilt twice in a row -> weird janky effect ->
      // delay completion by 500 milliseconds
      Future.delayed(const Duration(milliseconds: 500), () => _completer.complete(this));
    });
  }

  Future<MenuSupplier> init() async => await _completer.future;

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

  Future<Dish> addDish(String name, double price, [Uint8List? image]) async {
    final _t = Dish(name, price, image); // _t has no ID yet
    final newDish = (await database?.insert(_t)) ?? _t; // now it has
    _m.add(newDish);
    return newDish;
  }

  /// Input value is from current [Menu] instance
  Future<void> updateDish(Dish dish, [String? name, double? price, Uint8List? image]) async {
    assert(_m.contains(dish));
    dish.dish = name ?? dish.dish;
    dish.price = price ?? dish.price;
    dish.imgProvider = image != null ? MemoryImage(image) : dish.imgProvider;
    return database?.update(dish);
  }

  /// Input value is from current [Menu] instance
  Future<void> removeDish(Dish dish) async {
    assert(_m.contains(dish));

    _m.remove(dish);
    return database?.delete(dish);
  }
}

List<Dish> _defaultMenu() {
  return [
    Dish.fromAsset(
      'Rice Noodles',
      10000,
      'assets/rice_noodles.png',
    ),
    Dish.fromAsset(
      'Lime Juice',
      20000,
      'assets/lime_juice.png',
    ),
    Dish.fromAsset(
      'Vegan Noodle',
      30000,
      'assets/vegan_noodles.png',
    ),
    Dish.fromAsset(
      'Oatmeal with Berries and Coconut',
      40000,
      'assets/oatmeal_with_berries_and_coconut.png',
    ),
    Dish.fromAsset(
      'Fried Chicken with Egg',
      50000,
      'assets/fried_chicken-with_with_wit_egg.png',
    ),
    Dish.fromAsset(
      'Kimchi',
      60000,
      'assets/kimchi.png',
    ),
    Dish.fromAsset(
      'Coffee',
      70000,
      'assets/coffee.png',
    ),
  ];
}
