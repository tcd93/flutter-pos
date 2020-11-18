import '../dish.dart';
import '../immutable/order.dart';
import '../line_item.dart';

/// State object base class
class StateObject {
  int _orderID;

  DateTime checkoutTime;

  /// The lineItems associated with a table
  List<LineItem> lineItems;

  /// The incremental unique ID (for reporting), should be generated when [checkout]
  int get orderID => _orderID;
  set orderID(int orderID) {
    assert(orderID != null, orderID > 0);
    _orderID = orderID;
  }

  /// Total price of all line items in this order
  int get totalPrice => lineItems
      .where(
        (entry) => entry.quantity > 0,
      )
      .fold(0, (prev, order) => prev + order.amount);

  StateObject()
      : lineItems = Dish.getMenu()
            .map(
              (dish) => LineItem(
                dishID: dish.id,
                quantity: 0,
              ),
            )
            .toList();

  StateObject.createFrom(Order order) {
    _orderID = order.orderID;
    checkoutTime = order.checkoutTime;
    lineItems = order.lineItems;
  }
}
