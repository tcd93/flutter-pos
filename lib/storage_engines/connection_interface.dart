import '../provider/src.dart';

class SupplierRepository with NodeIO, OrderIO, CoordinateIO {}

/// Represents a storage engine, like "localstorage", "sqlite", or "aws-s3"...
class DatabaseConnectionInterface = SupplierRepository with MenuIO;

/// Specific operations on table nodes, like inserting an order
class OrderIO {
  List<Order> get(DateTime day) => [];

  List<Order> getRange(DateTime from, DateTime to) => [];

  /// Insert stringified version of [TableState] into database
  Future<void> insert(Order order) => Future.value();

  /// Soft deletes an order in specified date
  Future<Order> delete(DateTime day, int orderID) => Future.value();
}

/// Specific CRUD operations on Menu
class MenuIO {
  /// Get menu from storage
  Menu? getMenu() => null;

  /// Overrides current menu in storage with new menu object
  Future<void> setMenu(Menu newMenu) => Future.value();
}

/// Operations on a more generic/global level, like retrieving the list of nodes
class NodeIO {
  Future<dynamic> open() => Future.value();

  void close() => null;

  /// Removes all items from database, should be wrapped in try/catch block
  Future<void> destroy() => Future.value();

  /// Get next incremental unique ID
  Future<int> nextUID() => Future.value(-1);

  List<int> tableIDs() => [];

  Future<List<int>> addTable(int tableID) => Future.value();

  Future<List<int>> removeTable(int tableID) => Future.value();
}

class CoordinateIO {
  /// Saves the table node's position on lobby screen to storage
  Future<void> setCoordinate(int tableID, double x, double y) => Future.value();

  /// Get position X of table node on screen
  double getX(int tableID) => 0;

  /// Get position Y of table node on screen
  double getY(int tableID) => 0;
}
