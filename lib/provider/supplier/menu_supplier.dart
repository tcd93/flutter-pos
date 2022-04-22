import 'dart:async';
import 'dart:typed_data';

// import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../storage_engines/connection_interface.dart';

import '../../storage_engines/firebase/firebase.dart';
import '../src.dart';

class MenuSupplier extends ChangeNotifier {
  List<Dish> _m = [];

  List<Dish> get menu => _m;

  bool _loading = false;
  bool get loading => _loading;

  final RIUDRepository<Dish>? database;

  MenuSupplier({this.database, List<Dish>? mockMenu}) {
    if (mockMenu != null) {
      _m = mockMenu;
      _loading = false;
      return;
    }
    _loading = true;
    Future(() async {
      _m = (await database?.get()) ?? [];
      // retrieve image from storage
      if (database != null && database is MenuFB) {
        for (var element in _m) {
          if (element.storageFileName != null) {
            final bytes = await (database as MenuFB).downloadImage(element.storageFileName!);
            if (bytes != null) element.imgProvider = MemoryImage(bytes);
          }
        }
      }

      if (_m.isEmpty) {
        if (database != null) {
          List<Future<Dish>> tasks = [];
          _defaultMenu().forEach(
            (element) => tasks.add(database!.insert(element)),
          );
          _m = await Future.wait(tasks);
        } else {
          _m = _defaultMenu();
        }
      }
      _loading = false;
      notifyListeners();
    });
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

  Future<Dish> addDish(String name, double price, [Uint8List? image]) async {
    final _t = Dish(name, price, image);
    final newDish = (await database?.insert(_t)) ?? _t;
    _m.add(newDish);
    // upload to storage
    if (newDish.imgProvider is MemoryImage && database is MenuFB) {
      final img = newDish.imgProvider as MemoryImage;
      final fb = database as MenuFB;

      final fileName = '${newDish.dish}_${newDish.id}.jpg'; // storage file name
      newDish.storageFileName = fileName;
      fb.uploadImage(fileName, img.bytes);
    }
    notifyListeners();
    return newDish;
  }

  /// Input value is from current [Menu] instance
  Future<void> updateDish(Dish dish, [String? name, double? price, Uint8List? image]) async {
    assert(_m.contains(dish));
    dish.dish = name ?? dish.dish;
    dish.price = price ?? dish.price;
    // compare, if different then update new image in storage
    if (image != null &&
        dish.imgProvider is MemoryImage &&
        dish.storageFileName != null &&
        database is MenuFB) {
      final fb = database as MenuFB;
      final currentImage = (dish.imgProvider as MemoryImage).bytes;

      if (!listEquals(image, currentImage)) {
        fb.uploadImage(dish.storageFileName!, image);
      }

      dish.imgProvider = MemoryImage(image);
    }
    return database?.update(dish);
  }

  /// Input value is from current [Menu] instance
  Future<void> removeDish(Dish dish) async {
    assert(_m.contains(dish));

    _m.remove(dish);
    notifyListeners();
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
