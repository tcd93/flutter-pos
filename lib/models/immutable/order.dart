import 'package:flutter/foundation.dart';

@immutable

/// The order that has been persisted on disk, used in [History screen]
class Order {
  final int orderID;
  final DateTime checkoutTime;
  final int price;
  final List<OrderItem> lineItems;
  final bool isDeleted;

  const Order(
    this.orderID,
    this.checkoutTime,
    this.price,
    this.lineItems, {
    this.isDeleted = false,
  });

  @override
  String toString() {
    return '$orderID: {$price, ${checkoutTime.toString()}, $lineItems, isDeleted: $isDeleted}';
  }
}

@immutable

/// Menu items that have been persisted on disk, used in [History screen]
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
