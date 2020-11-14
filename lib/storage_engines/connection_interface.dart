import 'package:flutter/foundation.dart';

import '../models/table.dart';

class DatabaseConnectionInterface {
  /// Used in [FutureBuilder]
  Future<dynamic> open() => Future.value(null);

  /// Get next incremental unique ID
  Future<int> nextUID() => Future.value(-1);

  /// Insert stringified version of [TableState] into database
  Future<void> insert(TableState state) => Future.microtask(() => null);

  List<Order> get(DateTime day) => null;

  List<Order> getRange(DateTime from, DateTime to) => null;

  /// Removes all items from database, should be wrapped in try/catch block
  Future<void> destroy() => Future.microtask(() => null);

  /// Close connection
  void close() => null;
}

@immutable
class Order {
  final int orderID;
  final DateTime checkoutTime;
  final int price;
  final List<OrderItem> lineItems;

  const Order(this.orderID, this.checkoutTime, this.price, this.lineItems);

  @override
  String toString() {
    return '$orderID: {$price, ${checkoutTime.toString()}, $lineItems}';
  }
}

@immutable
class OrderItem {
  final int dishID;
  final String dishName;
  final int quantity;
  final int amount;

  const OrderItem(this.dishID, this.dishName, this.quantity, this.amount);

  @override
  String toString() {
    return '[$dishID, $dishName, $quantity, $amount]';
  }
}
