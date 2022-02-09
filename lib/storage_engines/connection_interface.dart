import 'package:flutter/foundation.dart';

import '../provider/src.dart';

class NodeIO = TableIO with CoordinateIO;

/// Represents a storage engine, like "localstorage", "sqlite", or "aws-s3"...
class DatabaseConnectionInterface = NodeIO with Control;

/// Readable & Insertable
abstract class RIRepository<T> = Readable<T> with Insertable<T>;
abstract class RIDRepository<T> = RIRepository<T> with Deletable<T>;
abstract class RIUDRepository<T> = RIDRepository<T> with Updatable<T>;

/// Operations on a more generic/global level
class Control {
  Future<dynamic> open() => Future.value();

  Future<void> close() => Future.value();

  /// Removes all items from database, should be wrapped in try/catch block
  Future<void> destroy() => Future.value();

  @visibleForTesting
  Future<void> truncate() => Future.value();
}

typedef QueryKey<C> = Comparable<C>;

abstract class Readable<T> {
  Future<List<T>> get([QueryKey? from, QueryKey? to]);
}

abstract class Insertable<T> {
  Future<T> insert(T value);
}

abstract class Deletable<T> {
  Future<void> delete(T value);
}

abstract class Updatable<T> {
  Future<void> update(T value);
}

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
  Future<List<Journal>> getJournal(DateTime day) => Future.value([]);

  Future<List<Journal>> getJournals(DateTime from, DateTime to) => Future.value([]);

  Future<void> insertJournal(Journal journal) => Future.value();
}

/// Specific CRUD operations on Menu
class MenuIO {
  /// Get menu from storage
  Future<Menu?> getMenu() => throw 'Unimplemented Error';

  /// Overrides current menu in storage with new menu object (localstorage)
  ///
  /// OR upsert a dish into storage (SQL), if [isDelete] is true, then instruct SQL to delete instead
  Future<void> setMenu({Menu? menu, Dish? dish, bool isDelete = false}) => Future.value();
}

class TableIO {
  Future<List<int>> tableIDs() => Future.value([]);

  Future<int> addTable() => Future.value(-1);

  Future<void> removeTable(int tableID) => Future.value();
}

class CoordinateIO {
  /// Saves the table node's position on lobby screen to storage
  Future<void> setCoordinate(int tableID, double x, double y) => Future.value();

  /// Get position X of table node on screen
  Future<double> getX(int tableID) async => 0;

  /// Get position Y of table node on screen
  Future<double> getY(int tableID) async => 0;
}
