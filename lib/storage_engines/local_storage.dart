import 'dart:convert';

import 'package:localstorage/localstorage.dart' as lib;

import '../common/common.dart';
import '../provider/src.dart';
import 'connection_interface.dart';

extension on LineItem {
  String toJson() {
    return '{"dishID": $dishID, "dishName": "$dishName", "quantity": $quantity, "price": $price}';
  }
}

extension on StateObject {
  /// Convert to JSON string object, line items with quantity > 0 are filtered
  ///
  /// @example:
  /// ```
  /// {
  ///   "orderID": 1,
  ///   "checkoutTime": "2020-02-01 00:00:00.000",
  ///   "discountRate": 0.75,
  ///   "lineItems": [{"dishID": 1, "quantity": 5, "price": 100000}]
  /// }
  /// ```
  String toJson() {
    var lineItemList = lineItems
        .where((element) => element.isBeingOrdered())
        .map(
          (e) => e.toJson(),
        )
        .toList();

    return '''{"orderID": $orderID, "checkoutTime": "${checkoutTime.toString()}", 
    "discountRate": $discountRate, "lineItems": ${lineItemList.toString()}}''';
  }
}

extension on Order {
  /// Similar to [toJson] from [TableState], with `isDeleted` field implemented
  String toJson() {
    var lineItemList = lineItems
        .where((element) => element.isBeingOrdered())
        .map(
          (e) => e.toJson(),
        )
        .toList();

    return '''{"tableID": $tableID, "orderID": $orderID, "checkoutTime": "${checkoutTime.toString()}", 
    "discountRate": $discountRate, "lineItems": ${lineItemList.toString()}, "isDeleted": $isDeleted}''';
  }
}

extension on Dish {
  // create toJson methods to implicitly work with `encode` (local-storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dish': dish,
      'imageBytes': imageBytes,
      'price': price,
    };
  }
}

class LocalStorage implements DatabaseConnectionInterface {
  final lib.LocalStorage ls;

  LocalStorage(String name, [String? path, Map<String, dynamic>? initialData])
      : ls = lib.LocalStorage(name, path, initialData);

  @override
  Future<bool> open() => ls.ready;

  @override
  Future<int> nextUID() async {
    // if empty, starts from -1
    int current = ls.getItem('order_id_highkey') ?? -1;
    await ls.setItem('order_id_highkey', ++current);
    return current;
  }

  @override
  Future<void> insert(StateObject state) {
    if (state.orderID < 0) throw 'Invalid `orderID`';

    final checkoutTime = Common.extractYYYYMMDD(state.checkoutTime);
    var newOrder = state.toJson(); // new order in json format

    // current orders of the day that have been saved
    // if this is first order then create it as an List
    var orders = ls.getItem(checkoutTime);
    if (orders != null) {
      orders.add(newOrder);
    } else {
      orders = [newOrder];
    }

    return ls.setItem(checkoutTime, orders);
  }

  @override
  List<Order> get(DateTime day) {
    List<dynamic>? storageData = ls.getItem(Common.extractYYYYMMDD(day));
    if (storageData == null) return [];

    var cache = storageData is List<Map> ? storageData : storageData.cast<String>();
    return cache.map((e) {
      var decoded =
          e is Map<String, dynamic> ? e : json.decode(e as String) as Map<String, dynamic>;
      List<dynamic> lines = decoded['lineItems'];
      return Order(
        decoded['tableID'] ?? -1,
        decoded['orderID'] ?? -1,
        DateTime.parse(decoded['checkoutTime']),
        lines
            .map((e) => LineItem(
                  associatedDish: Dish(e['dishID'], e['dishName'], e['price'], e['imageBytes']),
                  quantity: e['quantity'],
                ))
            .toList(),
        discountRate: decoded['discountRate'] ?? -1.0,
        isDeleted: decoded['isDeleted'] ?? false,
      );
    }).toList(growable: false);
  }

  @override
  List<Order> getRange(DateTime start, DateTime end) {
    return List.generate(
      end.difference(start).inDays + 1,
      (i) => get(DateTime(start.year, start.month, start.day + i)),
    ).expand((e) => e).toList();
  }

  @override
  Map<String, Dish>? getMenu() {
    var storageData = ls.getItem('menu');
    if (storageData == null) {
      print('menu not found');
      return null;
    }
    var cache = storageData is Map ? storageData : json.decode(storageData) as Map<String, dynamic>;

    return cache.map((key, v) {
      var decoded = v is Map<String, dynamic> ? v : json.decode(v) as Map<String, dynamic>;
      return MapEntry(
        key.toString(),
        Dish(decoded['id'], decoded['dish'], decoded['price'], decoded['imageBytes']),
      );
    });
  }

  @override
  Future<void> setMenu(Map<String, Dish> newMenu) {
    // to set items to local storage, they must be Map<String, dynamic>
    return ls.setItem('menu', newMenu, (menu) {
      return (menu as Map<String, Dish>).map((key, value) {
        return MapEntry(
          key.toString(),
          value.toJson(),
        );
      });
    });
  }

  @override
  Future<Order> delete(DateTime day, int orderID) async {
    var deletedOrder;

    var rebuiltOrders = get(day).map((order) {
      if (order.orderID == orderID) {
        deletedOrder = Order(
          order.tableID,
          order.orderID,
          order.checkoutTime,
          order.lineItems,
          discountRate: order.discountRate,
          isDeleted: true,
        );
        return deletedOrder;
      } else {
        return order;
      }
    }).toList();

    await ls.setItem(
      Common.extractYYYYMMDD(day),
      rebuiltOrders,
      (orders) {
        return (orders as List)
            .map(
              (e) => (e as Order).toJson(),
            )
            .toList();
      },
    );

    return deletedOrder;
  }

  @override
  Future<void> destroy() => ls.clear();

  @override
  void close() => ls.dispose();

  @override
  Future<void> setCoordinate(int tableID, double x, double y) {
    return Future.wait(
      [ls.setItem('${tableID}_coord_x', x), ls.setItem('${tableID}_coord_y', y)],
      eagerError: true,
    );
  }

  @override
  double getX(int tableID) {
    return ls.getItem('${tableID}_coord_x') ?? 0;
  }

  @override
  double getY(int tableID) {
    return ls.getItem('${tableID}_coord_y') ?? 0;
  }

  @override
  Future<List<int>> addTable(int tableID) async {
    final list = tableIDs();
    list.add(tableID);
    await ls.setItem('table_list', list);
    return list;
  }

  @override
  Future<List<int>> removeTable(int tableID) async {
    final list = tableIDs();
    list.remove(tableID);
    await ls.setItem('table_list', list);
    return list;
  }

  @override
  List<int> tableIDs() {
    final List<dynamic> l = ls.getItem('table_list') ?? [];
    return l.cast<int>();
  }
}
