import '../dish.dart';
import '../line_item.dart';
import 'state_object.dart';
import 'status.dart';

/// The separate current "state" of the immutable [TableModel] class
class TableState extends StateObject {
  /// The associated table id
  final int tableID;

  TableStatus status;

  TableStatus previousStatus;

  /// Keep track of state history, overwrite snapshot everytime the confirm
  /// button is clicked
  Map<int, LineItem> previouslineItems;

  TableState(this.tableID) {
    cleanState();
  }

  /// set all line items to 0
  void cleanState() {
    status = TableStatus.empty;
    previousStatus = TableStatus.empty;
    lineItems = {
      for (var dish in Dish.getMenu())
        dish.id: LineItem(
          dishID: dish.id,
          quantity: 0,
        )
    };
    previouslineItems = {
      for (var dish in Dish.getMenu())
        dish.id: LineItem(
          dishID: dish.id,
          quantity: 0,
        )
    };
  }
}
