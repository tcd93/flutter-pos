import '../provider/src.dart';

class SupplierRepository with NodeIO, OrderIO, CoordinateIO {}

/// Represents a storage engine, like "localstorage", "sqlite", or "aws-s3"...
class DatabaseConnectionInterface = SupplierRepository with MenuIO, JournalIO;

/// Specific operations on table nodes, like inserting an order
class OrderIO {
  Future<List<Order>> get(DateTime day) => Future.value([]);

  Future<List<Order>> getRange(DateTime from, DateTime to) => Future.value([]);

  /// Insert stringified version of [TableState] into database
  Future<void> insert(Order order) => Future.value();

  /// Soft deletes an order in specified date
  Future<void> delete(DateTime day, int orderID) => Future.value();
}

/// Operations with the journal entries
class JournalIO {
  List<Journal> getJournal(DateTime day) => [];

  List<Journal> getJournals(DateTime from, DateTime to) => [];

  Future<void> insertJournal(Journal journal) => Future.value();
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

  void close() {
    return;
  }

  /// Removes all items from database, should be wrapped in try/catch block
  Future<void> destroy() => Future.value();

  List<int> tableIDs() => [];

  Future<List<int>> addTable(int tableID) => Future.value([]);

  Future<List<int>> removeTable(int tableID) => Future.value([]);
}

class CoordinateIO {
  /// Saves the table node's position on lobby screen to storage
  Future<void> setCoordinate(int tableID, double x, double y) => Future.value();

  /// Get position X of table node on screen
  double getX(int tableID) => 0;

  /// Get position Y of table node on screen
  double getY(int tableID) => 0;
}
