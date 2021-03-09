import 'dart:io';
import '../src.dart';

class LineItem {
  int _quantity = 0;

  final Dish associatedDish;

  int addOne() => ++_quantity;

  int get dishID => associatedDish.id;

  String get dishName => associatedDish.dish;

  bool isBeingOrdered() => _quantity > 0;

  double get price => associatedDish.price;

  int get quantity => _quantity;

  /// `WARNING: Only allow setting quantity in TEST mode`
  set quantity(int v) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _quantity = v;
    } else {
      throw 'Only allow setting quantity in TEST mode';
    }
  }

  int substractOne() => _quantity > 0 ? --_quantity : 0;

  LineItem({required this.associatedDish, int quantity = 0}) : _quantity = quantity;

  LineItem.fromJson(Map<String, dynamic> json)
      : associatedDish = Dish(json['dishID'], json['dishName'], json['price']),
        _quantity = json['quantity'];

  Map<String, dynamic> toJson() {
    return {'dishID': dishID, 'dishName': dishName, 'quantity': quantity, 'price': price};
  }

  @override
  String toString() => toJson().toString();
}
