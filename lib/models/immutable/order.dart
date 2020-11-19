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
  set lineItems(List<LineItem> _lineItems) => throw 'Can not set LineItem from an Order instance';

  @override
  int get totalPrice => lineItems
      .where((entry) => entry.isBeingOrdered())
      .fold(0, (prev, order) => prev + order.amount);

  @override
  int get totalQuantity => lineItems.fold(0, (prevValue, item) => prevValue + item.quantity);

  @override
  String toString() {
    return '$orderID: {$price, ${checkoutTime.toString()}, $lineItems, isDeleted: $isDeleted}';
  }
}

/// Menu items that have been persisted on disk, used in [History screen]
@immutable
class OrderItem implements LineItem {
  final int dishID;

  final String dishName;

  /// The recorded price (amount * quantity) at the time of checkout
  final int amount;

  final int quantity;

  OrderItem(this.dishID, this.dishName, this.quantity, this.amount);

  @override
  set quantity(int v) => throw 'Can not modify history item';

  @override
  int addOne() => throw 'Can not modify history item';

  @override
  int substractOne() => throw 'Can not modify history item';

  @override
  bool isBeingOrdered() => quantity > 0;

  @override
  String toString() {
    return '[$dishID, $dishName, $quantity, $amount]';
  }
}
