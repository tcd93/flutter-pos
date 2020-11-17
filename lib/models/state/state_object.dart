import '../line_item.dart';

/// State object base class
class StateObject {
  int _orderID;

  DateTime checkoutTime;

  /// The lineItems associated with a table.
  /// This is a [Map<int, lineItems>] where the key is the [Dish] item id
  Map<int, LineItem> lineItems;

  /// The incremental unique ID (for reporting), should be generated when [checkout]
  int get orderID => _orderID;
  set orderID(int orderID) {
    assert(orderID != null, orderID > 0);
    _orderID = orderID;
  }

  /// Total price of all line items in this order
  int get totalPrice => lineItems.entries
      .where((entry) => entry.value.quantity > 0)
      .map((entry) => entry.value)
      .fold(0, (prev, order) => prev + order.amount);
}
