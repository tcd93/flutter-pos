import 'package:flutter/foundation.dart';

import '../src.dart';

@immutable
class Menu extends Iterable<Dish> {
  final List<Dish> _list;

  Menu([List<Dish>? fromList]) : _list = fromList ?? [];

  void add(Dish dish) => _list.add(dish);

  void set(Dish dish) {
    _list[_list.indexOf(dish)]
      ..dish = dish.dish
      ..price = dish.price
      ..imgProvider = dish.imgProvider;
  }

  void remove(Dish dish) => _list.remove(dish);

  Menu.fromJson(List<dynamic> json) : _list = json.map((e) => Dish.fromJson(e)).toList();

  // will be called implicitly
  List<Dish> toJson() => _list;

  @override
  Iterator<Dish> get iterator => _list.iterator;
}
