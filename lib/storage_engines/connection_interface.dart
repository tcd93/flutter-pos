import '../models/dish.dart';

import '../models/immutable/order.dart';
import '../models/state/state_object.dart';

class DatabaseConnectionInterface {
  /// Used in [FutureBuilder]
  Future<dynamic> open() => Future.value(null);

  /// Get next incremental unique ID
  Future<int> nextUID() => Future.value(-1);

  /// Insert stringified version of [TableState] into database
  Future<void> insert(StateObject state) => Future.microtask(() => null);

  List<Order> get(DateTime day) => null;

  List<Order> getRange(DateTime from, DateTime to) => null;

  /// Get menu from storage
  Map<String, Dish> getMenu() => null;

  /// Overrides current menu in storage with new menu object
  Future<void> setMenu(Map<String, Dish> newMenu) => null;

  /// Soft deletes an order in specified date
  Future<Order> delete(DateTime day, int orderID) => Future.microtask(() => null);

  /// Removes all items from database, should be wrapped in try/catch block
  Future<void> destroy() => Future.microtask(() => null);

  /// Close connection
  void close() => null;
}
