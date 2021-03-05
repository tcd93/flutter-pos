import 'package:flutter/services.dart';

import '../../database_factory.dart';
import 'dish.dart';

class Menu {
  static final Menu _instance = Menu._internal();
  final storage = DatabaseFactory().create('local-storage');

  /// A `Map<String, Dish>`, where the String key is the dishID.
  /// Note that the key must be a string for `encode/decode` to work
  late Map<String, Dish> list;

  factory Menu() => _instance;

  Menu._internal() {
    load();
  }

  Future<void> load() async {
    list = storage.getMenu() ??
        {
          '0': Dish(
            0,
            'Rice Noodles',
            10000,
            (await rootBundle.load('assets/rice_noodles.png')).buffer.asUint8List(),
          ),
          '1': Dish(
            1,
            'Lime Juice',
            20000,
            (await rootBundle.load('assets/lime_juice.png')).buffer.asUint8List(),
          ),
          '2': Dish(
            2,
            'Vegan Noodle',
            30000,
            (await rootBundle.load('assets/vegan_noodles.png')).buffer.asUint8List(),
          ),
          '3': Dish(
            3,
            'Oatmeal with Berries and Coconut',
            40000,
            (await rootBundle.load('assets/oatmeal_with_berries_and_coconut.png'))
                .buffer
                .asUint8List(),
          ),
          '4': Dish(
            4,
            'Fried Chicken with Egg',
            50000,
            (await rootBundle.load('assets/fried_chicken-with_with_wit_egg.png'))
                .buffer
                .asUint8List(),
          ),
          '5': Dish(
            5,
            'Kimchi',
            60000,
            (await rootBundle.load('assets/kimchi.png')).buffer.asUint8List(),
          ),
          '6': Dish(
            6,
            'Coffee',
            70000,
            (await rootBundle.load('assets/coffee.png')).buffer.asUint8List(),
          ),
        };
  }
}
