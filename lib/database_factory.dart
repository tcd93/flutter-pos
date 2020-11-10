import 'dart:convert';

import 'package:localstorage/localstorage.dart';

import './models/table.dart';

const dbName = 'hembo';

class DatabaseConnectionInterface {
  /// Used in [FutureBuilder]
  Future<dynamic> open() {
    return Future.value(null);
  }

  /// Get next incremental unique ID
  int nextUID() => -1;

  /// Insert stringified version of [TableState] into database
  Future<void> insert(TableState state) => Future.microtask(() => null);

  List<Map<String, dynamic>> get(String key) => null;
}

class _LocalStorage implements DatabaseConnectionInterface {
  final LocalStorage ls;

  _LocalStorage(String name, [String path, Map<String, dynamic> initialData])
      : ls = LocalStorage(name, path, initialData);

  @override
  Future<bool> open() async {
    return ls.ready;
  }

  @override
  int nextUID() {
    int current = ls.getItem('order_id_highkey') ?? -1;
    ls.setItem('order_id_highkey', ++current);
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

  String extractYYYYMMDD(DateTime dateTime) =>
      "${dateTime.year.toString()}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}";
}

class DatabaseFactory {
  static DatabaseFactory _singleton;
  static DatabaseConnectionInterface _interface;

  DatabaseFactory._init();

  /// Returns an [DatabaseConnectionInterface] instance, currently support `local-storage`
  factory DatabaseFactory(String name) {
    if (_singleton == null) {
      _singleton = DatabaseFactory._init();
    }

    if (name == 'local-storage' && _interface == null) {
      _interface = _LocalStorage(dbName);
    }

    if (_interface == null) {
      throw Exception('Must define a storage type name');
    }

    return _singleton;
  }

  DatabaseConnectionInterface storage() => _interface;
}
