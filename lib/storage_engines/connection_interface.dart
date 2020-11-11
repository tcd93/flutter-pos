import '../models/table.dart';

class DatabaseConnectionInterface {
  /// Used in [FutureBuilder]
  Future<dynamic> open() => Future.value(null);

  /// Get next incremental unique ID
  Future<int> nextUID() => Future.value(-1);

  /// Insert stringified version of [TableState] into database
  Future<void> insert(TableState state) => Future.microtask(() => null);

  List<Map<String, dynamic>> get(String key) => null;

  /// Removes all items from database
  Future<void> destroy() => Future.microtask(() => null);

  /// Close connection
  void close() => null;
}
