import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
class Dish {
  final int id;

  final double price;

  /// Dish name
  final String dish;

  /// A "view" to the underlying image (can be from asset or from raw bytes)
  late final ImageProvider imgProvider;

  /// image bytes data
  final Uint8List? _imageBytes;

  /// or a string of asset path, if [_imageBytes] is not defined
  final String? _asset;

  @override
  // ignore: always_declare_return_types, type_annotate_public_apis
  operator ==(other) => other is Dish && other.id == id;
  @override
  int get hashCode => id;

  Dish(this.id, this.dish, [this.price = 0, this._imageBytes])
      : assert(id >= 0),
        assert(dish != ''),
        _asset = null {
    _initImgProvider();
  }

  Dish.fromAsset(this.id, this.dish, [this.price = 0, this._asset])
      : assert(id >= 0),
        assert(dish != ''),
        _imageBytes = null {
    _initImgProvider();
  }

  // will be called implicitly
  Dish.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        dish = json['dish'],
        price = json['price'],
        _imageBytes = json['imageBytes'] != null
            ? Uint8List.fromList(List.castFrom<dynamic, int>(json['imageBytes']))
            : null,
        _asset = json['asset'] {
    _initImgProvider();
  }

  void _initImgProvider() {
    imgProvider = (_imageBytes != null
        ? MemoryImage(_imageBytes!)
        : _asset != null
            ? AssetImage(_asset!)
            : AssetImage('assets/coffee.png')) as ImageProvider;
  }

  Map<String, dynamic> toJson() {
    return _imageBytes != null
        ? {'id': id, 'dish': dish, 'price': price, 'imageBytes': _imageBytes}
        : _asset != null
            ? {'id': id, 'dish': dish, 'price': price, 'asset': _asset}
            : {'id': id, 'dish': dish, 'price': price};
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
