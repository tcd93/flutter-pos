import 'package:flutter/foundation.dart';

import '../../src.dart';

/// an data class to encapsulate the state of a node
@immutable
class Order extends StateObject {
  final int _id;
  int get id => _id;

  /// The associated table id
  final int tableID;

  final TableStatus status;

  /// "soft-deleted", interactable only in [HistoryScreen]
  final bool isDeleted;

  /// copy to a new instance
  Order.create({
    int? tableID,
    bool? isDeleted,
    TableStatus? status,
    LineItemList? lineItems,
    double? discountRate,
    DateTime? checkoutTime,
    Order? fromBase,
  })  : assert(tableID == null ? fromBase != null : fromBase == null),
        tableID = tableID ?? fromBase?.tableID ?? -1,
        _id = fromBase?.id ?? -1,
        isDeleted = isDeleted ?? fromBase?.isDeleted ?? false,
        status = status ?? fromBase?.status ?? TableStatus.empty,
        super.create(
          LineItemList.copy(lineItems ?? fromBase?.lineItems ?? LineItemList()),
          discountRate ?? fromBase?.discountRate ?? 1.0,
          checkoutTime ?? fromBase?.checkoutTime,
        );

  Order({
    required this.tableID,
    required LineItemList lineItems,
    DateTime? checkoutTime,
    double discountRate = 1.0,
    this.status = TableStatus.empty,
    this.isDeleted = false,
  })  : _id = -1,
        assert(discountRate > 0.0 && discountRate <= 1.0),
        super.create(LineItemList.copy(lineItems), discountRate, checkoutTime);

  Order.fromJson(Map<String, dynamic> json)
      : tableID = json['tableID'] ?? -1,
        _id = json['orderID'] ?? json['ID'] ?? -1,
        isDeleted = json['isDeleted'] ?? false,
        status = TableStatus.empty,
        super.create(
          LineItemList.fromJson(json['lineItems']),
          json['discountRate'],
          DateTime.parse(json['checkoutTime']),
        );

  Map<String, dynamic> toJson() {
    return {
      'ID': _id,
      'tableID': tableID,
      'lineItems': activeLines.toJson(),
      'checkoutTime': checkoutTime.toString(),
      'discountRate': discountRate,
      'isDeleted': isDeleted,
    };
  }

  @override
  String toString() => toJson().toString();

  double saleAmount(bool withDiscount) =>
      isDeleted == true ? 0 : totalPrice * (withDiscount ? discountRate : 1.0);
}
