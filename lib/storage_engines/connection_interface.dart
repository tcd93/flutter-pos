import '../provider/src.dart';

class DatabaseConnectionInterface {
  /// Used in [FutureBuilder]
  Future<dynamic> open() => Future.value(null);

  /// Get next incremental unique ID
  Future<int> nextUID() => Future.value(-1);

  /// Insert stringified version of [TableState] into database
  Future<void> insert(StateObject state) => Future.microtask(() => null);

  List<Order> get(DateTime day) => [];

  List<Order> getRange(DateTime from, DateTime to) => [];

  /// Get menu from storage
  Map<String, Dish>? getMenu() => null;

  /// Overrides current menu in storage with new menu object
  Future<void> setMenu(Map<String, Dish> newMenu) => Future.value();

  /// Soft deletes an order in specified date
  Future<Order> delete(DateTime day, int orderID) => Future.value();

  /// Removes all items from database, should be wrapped in try/catch block
  Future<void> destroy() => Future.microtask(() => null);

  /// Saves the table node's position on lobby screen to storage
  Future<void> setCoordinate(int tableID, double x, double y) => Future.value();

  /// Get position X of table node on screen
  double getX(int tableID) => 0;

  /// Get position Y of table node on screen
  double getY(int tableID) => 0;

  List<int> tableIDs() => [];

  Future<List<int>> addTable(int tableID) => Future.value();

  Future<List<int>> removeTable(int tableID) => Future.value();

  /// Close connection
  void close() => null;
}
