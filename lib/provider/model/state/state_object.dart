import '../line_item.dart';

/// State object base class
class StateObject {
  int _orderID;

  /// 0 < discount rate <= 1.
  /// discountRate 0.75 means 25% off the total price
  double discountRate = 1.0;

  DateTime checkoutTime;

  /// The lineItems associated with a table
  List<LineItem> lineItems = [];

  /// The incremental unique ID (for reporting), should be generated when [checkout]
  int get orderID => _orderID;
  set orderID(int orderID) {
    assert(orderID != null, orderID > 0);
    _orderID = orderID;
  }

  /// Total price of all line items in this order, pre-discount
  double get totalPrice => lineItems
      .where((entry) => entry.isBeingOrdered())
      .fold(0, (prev, order) => prev + (order.price * order.quantity));

  int get totalQuantity => lineItems.fold(0, (prevValue, item) => prevValue + item.quantity);

  StateObject();

  StateObject.mock(this.lineItems, {orderID = -1, this.checkoutTime, this.discountRate = 1.0})
      : _orderID = orderID,
        assert(discountRate > 0.0 && discountRate <= 1.0);
}
