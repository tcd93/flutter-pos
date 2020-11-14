import 'dart:convert';
import 'package:localstorage/localstorage.dart' as lib;

import '../common/common.dart';

import '../models/dish.dart';
import '../models/line_item.dart';
import '../models/table.dart';

import 'connection_interface.dart';

extension LineItemJson on LineItem {
  String toJson() {
    return '{"dishID": $dishID, "dishName": "${Dish.getMenu()[dishID].dish}", "quantity": $quantity, "amount": $amount}';
  }
}

extension TableStateJson on TableState {
  /// Convert to JSON string object, line items with quantity > 0 are filtered
  ///
  /// @example:
  /// ```
  /// {
  ///   "orderID": 1,
  ///   "checkoutTime": "2020-02-01 00:00:00.000",
  ///   "totalPrice": 100000,
  ///   "lineItems": [{"dishID": 1, "quantity": 5, "amount": 100000}]
  /// }
  /// ```
  String toJson() {
    var lineItemList = lineItems.values
        .where(
          (element) => element.quantity > 0,
        )
        .map((e) => e.toJson())
        .toList();

    return '{"orderID": $orderID, "checkoutTime": "${checkoutTime.toString()}", "totalPrice": ${totalPrice()}, "lineItems": ${lineItemList.toString()}}';
  }
}

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

    var key = '${Common.extractYYYYMMDD(state.checkoutTime)}'; // key by checkout date
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
  List<Order> get(DateTime day) {
    List<dynamic> storageData = ls.getItem(Common.extractYYYYMMDD(day));
    var cache = storageData is List<Map> ? storageData : storageData?.cast<String>();
    return cache?.map((e) {
      var decoded = e is Map<String, dynamic> ? e : json.decode(e) as Map<String, dynamic>;
      List<dynamic> lines = decoded['lineItems'];
      return Order(
        decoded['orderID'],
        DateTime.parse(decoded['checkoutTime']),
        decoded['totalPrice'],
        lines
            .map(
              (e) => OrderItem(
                e['dishID'],
                e['dishName'],
                e['quantity'],
                e['amount'],
              ),
            )
            .toList(),
      );
    })?.toList(growable: false);
  }

  @override
  List<Order> getRange(DateTime start, DateTime end) {
    return List.generate(
      end.difference(start).inDays + 1,
      (i) => get(DateTime(start.year, start.month, start.day + i)) ?? [],
    ).expand((e) => e).toList();
  }

  @override
  Future<void> destroy() => ls.clear();

  @override
  void close() => ls.dispose();
}
