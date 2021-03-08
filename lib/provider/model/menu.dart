import '../src.dart';

class Menu extends Iterable<Dish> {
  late final List<Dish> _list;

  Menu([List<Dish>? fromList]) {
    _list = fromList ?? [];
  }

  void add(Dish dish) => _list.add(dish);

  void set(Dish dish) => _list[_list.indexOf(dish)] = dish;

  void remove(Dish dish) => _list.remove(dish);

  Menu.fromJson(Map<String, dynamic> json)
      : _list = (json['list'] as List<dynamic>).map((d) => Dish.fromJson(d)).toList();

  // will be called implicitly
  // ignore: unused_element
  Map<String, dynamic> toJson() {
    return {'list': _list};
  }

  @override
  Iterator<Dish> get iterator => _list.iterator;
}
