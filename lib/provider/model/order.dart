import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../src.dart';

/// The order model to use in reporting screens, includes a [isDeleted] property
/// which marks it as "soft-deleted"
@immutable
class Order implements StateObject {
  final int tableID;

  final bool isDeleted;

  @override
  final int orderID;

  @override
  final double discountRate;

  @override
  final DateTime checkoutTime;

  @override
  final List<LineItem> lineItems;

  Order(
    this.tableID,
    this.orderID,
    this.checkoutTime,
    this.lineItems, {
    this.discountRate = 1.0,
    this.isDeleted = false,
  });

  @override
  set lineItems(List<LineItem> _lineItems) => throw 'Can not set LineItem from an Order instance';

  @override
  double get totalPrice => lineItems
      .where((entry) => entry.isBeingOrdered())
      .fold(0, (prev, order) => prev + (order.price * order.quantity));

  @override
  int get totalQuantity => lineItems.fold(0, (prevValue, item) => prevValue + item.quantity);

  @override
  String toString() {
    return '$orderID: {$totalPrice, $discountRate, ${checkoutTime.toString()}, $lineItems, isDeleted: $isDeleted}';
  }

  @override
  set checkoutTime(_) => 'Can not set checkoutTime from an Order instance';

  @override
  set orderID(int orderID) => 'Can not set orderID from an Order instance';

  @override
  set discountRate(double _discountRate) => 'Can not set discountRate from an Order instance';
}
