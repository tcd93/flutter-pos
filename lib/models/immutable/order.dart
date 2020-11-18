import 'package:flutter/foundation.dart';
import '../line_item.dart';
import '../state/state_object.dart';

/// The order that has been persisted on disk, used in [History screen]
@immutable
class Order implements StateObject {
  @override
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

  set checkoutTime(DateTime _checkoutTime) =>
      throw 'Can not set checkoutTime from an Order instance';

  set orderID(int orderID) => throw 'Can not change orderID';

  @override
  String toString() {
    return '$orderID: {$price, ${checkoutTime.toString()}, $lineItems, isDeleted: $isDeleted}';
  }

  @override
  set lineItems(List<LineItem> _lineItems) => throw 'Can not set LineItem from an Order instance';

  @override
  int get totalPrice => lineItems
      .where(
        (entry) => entry.quantity > 0,
      )
      .fold(0, (prev, order) => prev + order.amount);
}

/// Menu items that have been persisted on disk, used in [History screen]
@immutable
class OrderItem implements LineItem {
  final int dishID;

  final String dishName;

  /// The recorded price (amount * quantity) at the time of checkout
  final int amount;

  final int quantity;

  const OrderItem(this.dishID, this.dishName, this.quantity, this.amount);

  set quantity(int quantity) => throw 'Can not set quantity from an OrderItem instance';

  @override
  String toString() {
    return '[$dishID, $dishName, $quantity, $amount]';
  }
}
