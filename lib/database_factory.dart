import 'package:posapp/storage_engines/sqlite.dart';

import 'storage_engines/connection_interface.dart';
import 'storage_engines/local_storage.dart';

const appName = 'posapp';

class DatabaseFactory {
  static final DatabaseFactory _singleton = DatabaseFactory._init();

  DatabaseFactory._init();

  /// Returns an [DatabaseConnectionInterface] instance, currently support `local-storage`, 'sqlite'
  factory DatabaseFactory() {
    return _singleton;
  }

  DatabaseConnectionInterface create(
    String name, [
    String? path,
    Map<String, dynamic>? initialData,
    String? dbName,
  ]) {
    if (name == 'local-storage') {
      return LocalStorage(dbName ?? appName, path, initialData);
    }
    if (name == 'sqlite') {
      return SQLite(dbName ?? appName, path);
    } else {
      throw UnimplementedError('$name is not implemented for database connection');
    }
  }
}
