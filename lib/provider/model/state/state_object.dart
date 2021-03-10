import '../line_item_list.dart';

/// State object base class
abstract class StateObject {
  /// The lineItems associated with a table
  LineItemList lineItems = LineItemList();

  /// 0 < discount rate <= 1.
  /// discountRate 0.75 means 25% off the total price
  double discountRate = 1.0;

  DateTime checkoutTime = DateTime.parse('1999-01-01');

  LineItemList get activeLines => LineItemList(lineItems.where((l) => l.isBeingOrdered()));

  /// Total price of all line items in this order, pre-discount
  double get totalPrice =>
      activeLines.fold(0, (prev, order) => prev + (order.price * order.quantity));

  int get totalQuantity => lineItems.fold(0, (prevValue, item) => prevValue + item.quantity);

  StateObject();

  StateObject.create(
    this.lineItems, [
    this.discountRate = 1.0,
    DateTime? checkoutTime,
  ]) : checkoutTime = checkoutTime ?? DateTime.parse('1999-01-01');
}
