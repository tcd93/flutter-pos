import 'dart:typed_data';
import 'package:flutter/foundation.dart';

@immutable
class Dish {
  final int id;

  final double price;

  /// Dish name
  final String dish;

  /// image bytes data
  final Uint8List? imageBytes;

  /// or a string of asset path, if [imageBytes] is not defined
  final String? asset;

  @override
  // ignore: always_declare_return_types, type_annotate_public_apis
  operator ==(other) => other is Dish && other.id == id;
  @override
  int get hashCode => id;

  Dish(this.id, this.dish, [this.price = 0, this.imageBytes])
      : assert(id >= 0),
        assert(dish != ''),
        asset = null;

  Dish.fromAsset(this.id, this.dish, [this.price = 0, this.asset])
      : assert(id >= 0),
        assert(dish != ''),
        imageBytes = null;

  // will be called implicitly
  Dish.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        dish = json['dish'],
        price = json['price'],
        imageBytes = json['imageBytes'] != null
            ? Uint8List.fromList(List.castFrom<dynamic, int>(json['imageBytes']))
            : null,
        asset = json['asset'];

  // will be called implicitly
  // ignore: unused_element
  Map<String, dynamic> toJson() {
    return imageBytes != null
        ? {'id': id, 'dish': dish, 'price': price, 'imageBytes': imageBytes}
        : asset != null
            ? {'id': id, 'dish': dish, 'price': price, 'asset': asset}
            : {'id': id, 'dish': dish, 'price': price};
  }
}
