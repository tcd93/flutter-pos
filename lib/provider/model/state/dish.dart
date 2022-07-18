import 'dart:typed_data';
import 'package:flutter/widgets.dart';

class Dish {
  final int id;

  double price;

  /// Dish name
  String dish;

  /// A "view" to the underlying image (can be from asset or from raw bytes)
  late ImageProvider imgProvider;

  /// or a string of asset path, if [_imageBytes] is not defined
  final String? _asset;

  Dish(this.dish, [this.price = 0, Uint8List? imageBytes])
      : assert(dish != ''),
        id = -1,
        _asset = null {
    _initImgProvider(imageBytes);
  }

  Dish.fromAsset(this.dish, [this.price = 0, this._asset])
      : assert(dish != ''),
        id = -1 {
    _initImgProvider();
  }

  // will be called implicitly
  Dish.fromJson(Map<String, dynamic> json)
      : id = json['ID'] ?? json['dishID'] ?? json['id'],
        dish = json['dish'],
        price = json['price'],
        _asset = json['asset'] {
    _initImgProvider(json['imageBytes'] != null
        ? Uint8List.fromList(List.castFrom<dynamic, int>(json['imageBytes']))
        : null);
  }

  void _initImgProvider([Uint8List? imageBytes]) {
    imgProvider = (imageBytes != null
        ? MemoryImage(imageBytes)
        : _asset != null
            ? AssetImage(_asset!)
            : const AssetImage('assets/coffee.png')) as ImageProvider;
  }

  Map<String, dynamic> toJson() {
    final img = imgProvider;
    return img is MemoryImage
        ? {'ID': id, 'dish': dish, 'price': price, 'imageBytes': img.bytes}
        : _asset != null
            ? {'ID': id, 'dish': dish, 'price': price, 'asset': _asset}
            : {'ID': id, 'dish': dish, 'price': price};
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
