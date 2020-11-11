import 'dart:convert';
import 'package:localstorage/localstorage.dart' as lib;

import '../models/table.dart';
import 'connection_interface.dart';

class LocalStorage implements DatabaseConnectionInterface {
  final lib.LocalStorage ls;

  LocalStorage(String name, [String path, Map<String, dynamic> initialData])
      : ls = lib.LocalStorage(name, path, initialData);

  @override
  Future<bool> open() => ls.ready;

  @override
  Future<int> nextUID() async {
    int current = ls.getItem('order_id_highkey') ?? -1;
    await ls.setItem('order_id_highkey', ++current);
    return current;
  }

  @override
  Future<void> insert(TableState state) {
    if (state == null) throw '`state` is required for localstorage';
    if (state.orderID == null || state.orderID < 0) throw 'Invalid `orderID`';

    var key = '${extractYYYYMMDD(state.checkoutTime)}'; // key by checkout date
    var newOrder = state.toJson(); // new order in json format

    // current orders of the day that have been saved
    // if this is first order then create it as an List
    List<dynamic> orders = ls.getItem(key);
    if (orders != null) {
      orders.add(newOrder);
    } else {
      orders = [newOrder];
    }

    return ls.setItem(key, orders);
  }

  @override
  List<Map<String, dynamic>> get(String key) {
    List<dynamic> cache = ls.getItem(key);
    return cache
        ?.cast<String>()
        ?.map((e) => json.decode(e) as Map<String, dynamic>)
        ?.toList(growable: false);
  }

  @override
  Future<void> destroy() => ls.clear();

  @override
  void close() => ls.dispose();

  String extractYYYYMMDD(DateTime dateTime) =>
      "${dateTime.year.toString()}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}";
}
